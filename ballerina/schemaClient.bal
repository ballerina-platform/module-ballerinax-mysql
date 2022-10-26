// Copyright (c) 2022 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/sql;

# Represents an SQL metadata client.
isolated client class SchemaClient {
    private final Client dbClient;
    private final string database;

    # Initializes the SchemaClient object
    #
    # + host - The name of where the mysql server is hosted (ex: localhost)
    # + user - The username to access the database
    # + password - The password to access the database
    # + database - The name of the database to be accessed
    # + return - A `sql:Error` or nil
    public function init(string host, string user, string password, string database) returns sql:Error? {
        self.database = database;
        self.dbClient = check new (host, user, password);
    }

    # Retrieves all tables in the database.
    #
    # + return - A string array containing the names of the tables or an `sql:Error`
    isolated remote function listTables() returns string[]|sql:Error {
        string[] tables = [];
        stream<record {|string table_name;|}, sql:Error?> results = self.dbClient->query(
            `SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
             WHERE TABLE_SCHEMA = ${self.database};`
        );

        do {
            check from record {|string table_name;|} result in results
                do {
                    tables.push(result.table_name.toString());
                };
        } on fail error e {
            return error("Error - recieved sql data is of type SQL:Error", cause = e);
        }

        do {
            check results.close();
        } on fail error e {
            return error("Closing of the Stream Failed", cause = e);
        }

        return tables;
    }

    # Retrieves information relevant to the provided table in the database.
    #
    # + tableName - The name of the table
    # + include - Options on whether column and constraint related information should be fetched.
    #             If `NO_COLUMNS` is provided, then no information related to columns will be retrieved.
    #             If `COLUMNS_ONLY` is provided, then columnar information will be retrieved, but not constraint
    #             related information.
    #             If `COLUMNS_WITH_CONSTRAINTS` is provided, then columar information along with constraint related
    #             information will be retrieved
    # + return - An 'sql:TableDefinition' with the relevant table information or an `sql:Error`
    isolated remote function getTableInfo(string tableName, sql:ColumnRetrievalOptions include = sql:COLUMNS_ONLY) returns sql:TableDefinition|sql:Error {
        record {}|sql:Error 'table = self.dbClient->queryRow(
            `SELECT TABLE_TYPE FROM information_schema.tables 
             WHERE (table_schema=${self.database} and table_name = ${tableName});`
        );

        if 'table is sql:NoRowsError {
            return error sql:NoRowsError("Selected Table does not exist or the user does not have privilages of viewing the Table");
        } else if 'table is sql:Error {
            return 'table;
        } else {
            sql:TableDefinition tableDef = {
                name: tableName,
                'type: <sql:TableType>'table["TABLE_TYPE"]
            };

            if !(include == sql:NO_COLUMNS) {
                sql:ColumnDefinition[] columns = [];
                stream<record {}, sql:Error?> colResults = self.dbClient->query(
                    `SELECT COLUMN_NAME, DATA_TYPE, COLUMN_DEFAULT, IS_NULLABLE FROM information_schema.columns 
                     WHERE (table_schema=${self.database} and table_name = ${tableName});`
                );
                do {
                    check from record {} result in colResults
                        do {
                            sql:ColumnDefinition column = {
                                name: <string>result["COLUMN_NAME"],
                                'type: <string>result["DATA_TYPE"],
                                defaultValue: result["COLUMN_DEFAULT"],
                                nullable: (<string>result["IS_NULLABLE"]) == "YES" ? true : false
                            };
                            columns.push(column);
                        };
                } on fail error e {
                    return error("Error - recieved sql data is of type SQL:Error", cause = e);
                }
                check colResults.close();

                tableDef.columns = columns;

                if include == sql:COLUMNS_WITH_CONSTRAINTS {
                    map<sql:CheckConstraint[]> checkConstMap = {};

                    stream<record {}, sql:Error?> checkResults = self.dbClient->query(
                        `SELECT CONSTRAINT_NAME, CHECK_CLAUSE FROM information_schema.check_constraints 
                        WHERE CONSTRAINT_SCHEMA=${self.database};`
                    );
                    do {
                        check from record {} result in checkResults
                            do {
                                sql:CheckConstraint 'check = {
                                    name: <string>result["CONSTRAINT_NAME"],
                                    clause: <string>result["CHECK_CLAUSE"]
                                };

                                string colName = <string>result["COLUMN_NAME"];
                                if checkConstMap[colName] is () {
                                    checkConstMap[colName] = [];
                                }
                                checkConstMap.get(colName).push('check);
                            };
                    } on fail error e {
                        return error("Error - recieved sql data is of type SQL:Error", cause = e);
                    }
                    check checkResults.close();

                    _ = checkpanic from sql:ColumnDefinition col in <sql:ColumnDefinition[]>tableDef.columns
                        do {
                            sql:CheckConstraint[]? checkConst = checkConstMap[col.name];
                            if !(checkConst is ()) && checkConst.length() != 0 {
                                col.checkConstraints = checkConst;
                            }
                        };

                    map<sql:ReferentialConstraint[]> refConstMap = {};

                    stream<record {}, sql:Error?> refResults = self.dbClient->query(
                        `SELECT kcu.CONSTRAINT_NAME, kcu.TABLE_NAME, kcu.COLUMN_NAME, rc.UPDATE_RULE, rc.DELETE_RULE
                        FROM information_schema.referential_constraints rc 
                        JOIN information_schema.key_column_usage as kcu
                        ON kcu.CONSTRAINT_CATALOG = rc.CONSTRAINT_CATALOG 
                        AND kcu.CONSTRAINT_SCHEMA = rc.CONSTRAINT_SCHEMA
                        AND kcu.CONSTRAINT_NAME = rc.CONSTRAINT_NAME
                        WHERE (rc.CONSTRAINT_SCHEMA=${self.database}  and kcu.TABLE_NAME = ${tableName});`
                    );
                    do {
                        check from record {} result in refResults
                            do {
                                sql:ReferentialConstraint ref = {
                                    name: <string>result["CONSTRAINT_NAME"],
                                    tableName: <string>result["TABLE_NAME"],
                                    columnName: <string>result["COLUMN_NAME"],
                                    updateRule: <sql:ReferentialRule>result["UPDATE_RULE"],
                                    deleteRule: <sql:ReferentialRule>result["DELETE_RULE"]
                                };

                                string colName = <string>result["COLUMN_NAME"];
                                if refConstMap[colName] is () {
                                    refConstMap[colName] = [];
                                }
                                refConstMap.get(colName).push(ref);
                            };
                    } on fail error e {
                        return error sql:Error("Error - recieved sql data is of type SQL:Error", cause = e);
                    }

                    _ = checkpanic from sql:ColumnDefinition col in <sql:ColumnDefinition[]>tableDef.columns
                        do {
                            sql:ReferentialConstraint[]? refConst = refConstMap[col.name];
                            if !(refConst is ()) && refConst.length() != 0 {
                                col.referentialConstraints = refConst;
                            }
                        };

                    check refResults.close();
                }
            }

            return tableDef;
        }
    }

    # Retrieves all routines in the database.
    #
    # + return - A string array containing the names of the routines or an `sql:Error`
    isolated remote function listRoutines() returns string[]|sql:Error {
        string[] routines = [];
        stream<record {|string routine_name;|}, sql:Error?> results = self.dbClient->query(
            `SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES
            WHERE ROUTINE_SCHEMA = ${self.database};`
        );

        do {
            check from record {|string routine_name;|} result in results
                do {
                    routines.push(result.routine_name.toString());
                };
        } on fail error e {
            return error("Error - recieved sql data is of type SQL:Error", cause = e);
        }

        do {
            check results.close();
        } on fail error e {
            return error("Closing of the Stream Failed", cause = e);
        }

        return routines;
    }

    # Retrieves information relevant to the provided routine in the database.
    #
    # + name - The name of the routine
    # + return - An 'sql:RoutineDefinition' with the relevant routine information or an `sql:Error`
    isolated remote function getRoutineInfo(string name) returns sql:RoutineDefinition|sql:Error {
        record {}|sql:Error routine = self.dbClient->queryRow(
            `SELECT ROUTINE_TYPE, DATA_TYPE FROM INFORMATION_SCHEMA.ROUTINES 
             WHERE ROUTINE_NAME = ${name};`
        );

        if routine is sql:NoRowsError {
            return error sql:NoRowsError("Selected Routine does not exist or the user does not have privilages of viewing it");
        } else if routine is sql:Error {
            return routine;
        } else {
            sql:ParameterDefinition[] parameterList = [];

            stream<sql:ParameterDefinition, sql:Error?> paramResults = self.dbClient->query(
                `SELECT p.PARAMETER_MODE, p.PARAMETER_NAME, p.DATA_TYPE
                FROM INFORMATION_SCHEMA.PARAMETERS AS p
                JOIN INFORMATION_SCHEMA.ROUTINES AS r
                ON p.SPECIFIC_NAME = r.SPECIFIC_NAME
                WHERE (p.SPECIFIC_SCHEMA = ${self.database} AND r.ROUTINE_NAME = ${name});`
            );
            do {
                check from sql:ParameterDefinition parameters in paramResults
                    do {
                        sql:ParameterDefinition 'parameter = {
                            mode: <sql:ParameterMode>parameters["PARAMETER_MODE"],
                            name: <string>parameters["PARAMETER_NAME"],
                            'type: <string>parameters["DATA_TYPE"]
                        };
                        parameterList.push('parameter);
                    };
            } on fail error e {
                return error sql:Error("Error - recieved sql data is of type SQL:Error", cause = e);
            }
            check paramResults.close();

            sql:RoutineDefinition routineDef = {
                name: name,
                'type: <sql:RoutineType>routine["ROUTINE_TYPE"],
                returnType: <string>routine["DATA_TYPE"],
                parameters: parameterList
            };

            return routineDef;
        }
    }

    public isolated function close() returns error? {
        _ = check self.dbClient.close();
    }
}
