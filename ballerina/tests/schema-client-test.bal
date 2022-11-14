// Copyright (c) 2022 WSO2 LLC. (https://www.wso2.com) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

import ballerina/test;
import ballerina/sql;

@test:Config {
    groups: ["metadata"]
}
function testListTables() returns error? {
    SchemaClient client1 = check new (host, user, password, "metadataDB", port);
    string[] tableList = check client1->listTables();
    check client1.close();
    test:assertEquals(tableList, ["EMPLOYEES", "OFFICES"]);
}

@test:Config {
    groups: ["metadata"]
}
function testListTablesNegative() returns error? {
    SchemaClient client1 = check new (host, user, password, "metadataEmptyDB", port);
    string[] tableList = check client1->listTables();
    check client1.close();
    test:assertEquals(tableList, []);
}

@test:Config {
    groups: ["metadata"]
}
function testGetTableInfoNoColumns() returns error? {
    SchemaClient client1 = check new (host, user, password, "metadataDB", port);
    TableDefinition 'table = check client1->getTableInfo("EMPLOYEES", include = sql:NO_COLUMNS);
    check client1.close();
    test:assertEquals('table, {"name": "EMPLOYEES", "type": "BASE TABLE"});
}

@test:Config {
    groups: ["metadata"]
}
function testGetTableInfoColumnsOnly() returns error? {
    SchemaClient client1 = check new (host, user, password, "metadataDB", port);
    TableDefinition 'table = check client1->getTableInfo("EMPLOYEES", include = sql:COLUMNS_ONLY);
    check client1.close();
    test:assertEquals('table.name, "EMPLOYEES");
    test:assertEquals('table.'type, "BASE TABLE");

    string tableCol = (<sql:ColumnDefinition[]>'table.columns).toString();
    boolean columnCheck = tableCol.includes("EMPLOYEENUMBER") && tableCol.includes("LASTNAME") &&
                        tableCol.includes("FIRSTNAME") && tableCol.includes("EXTENSION") &&
                        tableCol.includes("EMAIL") && tableCol.includes("OFFICECODE") &&
                        tableCol.includes("REPORTSTO") && tableCol.includes("JOBTITLE");

    test:assertEquals(columnCheck, true);
}

@test:Config {
    groups: ["metadata"]
}
function testGetTableInfoColumnsWithConstraints() returns error? {
    SchemaClient client1 = check new (host, user, password, "metadataDB", port);
    TableDefinition 'table = check client1->getTableInfo("EMPLOYEES", include = sql:COLUMNS_WITH_CONSTRAINTS);
    check client1.close();

    test:assertEquals('table.name, "EMPLOYEES");
    test:assertEquals('table.'type, "BASE TABLE");
    test:assertEquals('table.checkConstraints, [{"name": "CHK_EmpNums", "clause": "((`EMPLOYEENUMBER` > 0) and (`REPORTSTO` > 0))"}]);

    string tableCol = (<sql:ColumnDefinition[]>'table.columns).toString();
    boolean columnCheck = tableCol.includes("EMPLOYEENUMBER") && tableCol.includes("LASTNAME") &&
                        tableCol.includes("FIRSTNAME") && tableCol.includes("EXTENSION") &&
                        tableCol.includes("EMAIL") && tableCol.includes("OFFICECODE") &&
                        tableCol.includes("REPORTSTO") && tableCol.includes("JOBTITLE") &&
                        tableCol.includes("FK_EmployeesOffice") && tableCol.includes("FK_EmployeesManager");

    test:assertEquals(columnCheck, true);
}

@test:Config {
    groups: ["metadata"]
}
function testGetTableInfoNegative() returns error? {
    SchemaClient client1 = check new (host, user, password, "metadataDB", port);
    TableDefinition|sql:Error 'table = client1->getTableInfo("EMPLOYEE", include = sql:NO_COLUMNS);
    check client1.close();
    if 'table is sql:Error {
        test:assertEquals('table.message(), "The selected table does not exist or the user does not have the required privilege level to view the table.");
    } else {
        test:assertFail("Expected result not received");
    }
}

@test:Config {
    groups: ["metadata"]
}
function testListRoutines() returns error? {
    SchemaClient client1 = check new (host, user, password, "metadataDB", port);
    string[] routineList = check client1->listRoutines();
    check client1.close();
    test:assertEquals(routineList, ["getEmpsEmail", "getEmpsName"]);
}

@test:Config {
    groups: ["metadata"]
}
function testListRoutinesNegative() returns error? {
    SchemaClient client1 = check new (host, user, password, "metadataEmptyDB", port);
    string[] routineList = check client1->listRoutines();
    check client1.close();
    test:assertEquals(routineList, []);
}

@test:Config {
    groups: ["metadata"]
}
function testGetRoutineInfo() returns error? {
    SchemaClient client1 = check new (host, user, password, "metadataDB", port);
    sql:RoutineDefinition routine = check client1->getRoutineInfo("getEmpsName");
    check client1.close();
    test:assertEquals(routine.name, "getEmpsName");
    test:assertEquals(routine.'type, "PROCEDURE");

    string routineParams = (<sql:ParameterDefinition[]>routine.parameters).toString();
    boolean paramCheck = routineParams.includes("EMPNUMBER") && routineParams.includes("FNAME");
    test:assertEquals(paramCheck, true);
}

@test:Config {
    groups: ["metadata"]
}
function testGetRoutineInfoNegative() returns error? {
    SchemaClient client1 = check new (host, user, password, "metadataDB", port);
    sql:RoutineDefinition|sql:Error routine = client1->getRoutineInfo("getEmpsNames");
    check client1.close();
    if routine is sql:Error {
        test:assertEquals(routine.message(), "Selected routine does not exist in the database, or the user does not have required privilege level to view it.");
    } else {
        test:assertFail("Expected result not recieved");
    }
}
