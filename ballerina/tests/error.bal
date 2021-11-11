// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/lang.'string as strings;
import ballerina/test;
import ballerina/sql;

string errorDB = "ERROR_DB";

@test:Config {
    groups: ["error"]
}
function TestAuthenticationError() {
    Client|error dbClient = new (host, "user", password, errorDB, port);
    test:assertTrue(dbClient is sql:ApplicationError);
    sql:ApplicationError sqlerror = <sql:ApplicationError> dbClient;
    test:assertTrue(strings:includes(sqlerror.message(), "Access denied for user"), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestLinkFailure() {
    Client|error dbClient = new ("host", user, password, errorDB, port);
    test:assertTrue(dbClient is sql:ApplicationError);
    sql:ApplicationError sqlerror = <sql:ApplicationError> dbClient;
    test:assertTrue(strings:includes(sqlerror.message(), "Error in SQL connector configuration: Failed to " +
             "initialize pool: Communications link failure"), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestInvalidDB() {
    Client|error dbClient = new (host, user, password, "errorD", port);
    test:assertTrue(dbClient is sql:ApplicationError);
    sql:ApplicationError sqlerror = <sql:ApplicationError> dbClient;
    test:assertTrue(strings:includes(sqlerror.message(), "Unknown database 'errorD'"), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestConnectionClose() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 1`;
    Client dbClient = check new (host, user, password, errorDB, port);
    check dbClient.close();
    string|error stringVal = dbClient->queryRow(sqlQuery);
    test:assertTrue(stringVal is sql:ApplicationError);
    sql:ApplicationError sqlerror = <sql:ApplicationError> stringVal;
    test:assertEquals(sqlerror.message(), "SQL Client is already closed, hence further operations are not allowed",
                sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestInvalidTableName() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from Data WHERE row_id = 1`;
    Client dbClient = check new (host, user, password, errorDB, port);
    string|error stringVal = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertTrue(stringVal is sql:DatabaseError);
    error sqlerror = <error> stringVal;
     test:assertEquals(sqlerror.message(), "Error while executing SQL query: SELECT string_type from Data " +
               "WHERE row_id = 1. Table 'ERROR_DB.Data' doesn't exist.", sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestInvalidFieldName() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE id = 1`;
    Client dbClient = check new (host, user, password, errorDB, port);
    string|error stringVal = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertTrue(stringVal is sql:DatabaseError);
    sql:DatabaseError sqlerror = <sql:DatabaseError> stringVal;
    test:assertEquals(sqlerror.message(), "Error while executing SQL query: SELECT string_type from DataTable " +
              "WHERE id = 1. Unknown column 'id' in 'where clause'.", sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestInvalidColumnType() returns error? {
    Client dbClient = check new (host, user, password, errorDB, port);
    sql:ExecutionResult|error result = dbClient->execute(
                                                    `CREATE TABLE TestCreateTable(studentID Point,LastName string)`);
    check dbClient.close();
    sql:DatabaseError sqlerror = <sql:DatabaseError> result;
    test:assertEquals(sqlerror.message(), "Error while executing SQL query: CREATE TABLE " +
           "TestCreateTable(studentID Point,LastName string). You have an error in your SQL syntax; check the " +
           "manual that corresponds to your MySQL server version for the right syntax to use near 'string)' " +
           "at line 1.", sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestNullValue() returns error? {
    Client dbClient = check new (host, user, password, errorDB, port);
    _ = check dbClient->execute(`CREATE TABLE TestCreateTable(studentID int not null, LastName VARCHAR(50))`);
    sql:ParameterizedQuery insertQuery = `Insert into TestCreateTable (studentID, LastName) values (null,'asha')`;
    sql:ExecutionResult|error insertResult = dbClient->execute(insertQuery);
    check dbClient.close();
    test:assertTrue(insertResult is sql:DatabaseError);
    sql:DatabaseError sqlerror = <sql:DatabaseError> insertResult;
    test:assertTrue(strings:includes(sqlerror.message(), "Error while executing SQL query: Insert into " +
             "TestCreateTable (studentID, LastName) values (null,'asha'). Column 'studentID' cannot be null."),
             sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestNoDataRead() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 5`;
    Client dbClient = check new (host, user, password, errorDB, port);
    record {}|error queryResult = dbClient->queryRow(sqlQuery);
    test:assertTrue(queryResult is sql:NoRowsError);
    sql:NoRowsError sqlerror = <sql:NoRowsError> queryResult;
    test:assertEquals(sqlerror.message(), "Query did not retrieve any rows.", sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestUnsupportedTypeValue() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 1`;
    Client dbClient = check new (host, user, password, errorDB, port);
    json|error stringVal = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertTrue(stringVal is sql:ConversionError);
    sql:ConversionError sqlerror = <sql:ConversionError> stringVal;
    test:assertEquals(sqlerror.message(), "Retrieved column 1 result '{\"\"q}' could not be converted to 'JSON', " +
            "expected ':' at line: 1 column: 4.", sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestConversionError() returns error? {
    sql:DateValue value = new("hi");
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = ${value}`;
    Client dbClient = check new (host, user, password, errorDB, port);
    string|error stringVal = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertTrue(stringVal is sql:ConversionError);
    sql:ConversionError sqlError = <sql:ConversionError> stringVal;
    test:assertEquals(sqlError.message(), "Unsupported value: hi for Date Value", sqlError.message());
}

@test:Config {
    groups: ["error"]
}
function TestConversionError1() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 1`;
    Client dbClient = check new (host, user, password, errorDB, port);
    json|error queryResult = dbClient->queryRow(sqlQuery);
    test:assertTrue(queryResult is sql:ConversionError);
    sql:ConversionError sqlError = <sql:ConversionError> queryResult;
    test:assertTrue(strings:includes(sqlError.message(), "Retrieved column 1 result '{\"\"q}' could not be converted"),
                sqlError.message());
}

type data record {|
    int row_id;
    int string_type;
|};

@test:Config {
    groups: ["error"]
}
function TestTypeMismatchError() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 1`;
    Client dbClient = check new (host, user, password, errorDB, port);
    data|error queryResult = dbClient->queryRow(sqlQuery);
    test:assertTrue(queryResult is sql:TypeMismatchError);
    sql:TypeMismatchError sqlError = <sql:TypeMismatchError> queryResult;
    test:assertEquals(sqlError.message(), "The field 'string_type' of type int cannot be mapped to the " +
              "column 'string_type' of SQL type 'VARCHAR'", sqlError.message());
}

type stringValue record {|
    int row_id1;
    string string_type1;
|};

@test:Config {
    groups: ["error"]
}
function TestFieldMismatchError() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 1`;
    Client dbClient = check new (host, user, password, errorDB, port);
    stringValue|error queryResult = dbClient->queryRow(sqlQuery);
    test:assertTrue(queryResult is sql:FieldMismatchError);
    sql:FieldMismatchError sqlError = <sql:FieldMismatchError> queryResult;
    test:assertTrue(strings:includes(sqlError.message(), "No mapping field found for SQL table column 'string_type' " +
          "in the record type 'stringValue'"), sqlError.message());
}

@test:Config {
    groups: ["error"]
}
function TestTableDefinitionIncorrect() returns error? {
    Client dbClient = check new (host, user, password, errorDB, port);
    sql:ExecutionResult|error result = dbClient->execute(`DROP TABLE IF EXISTS Student`);
    result = dbClient->execute(`CREATE TABLE Student(id INT AUTO_INCREMENT, age INT)`);
    check dbClient.close();
    test:assertTrue(result is sql:DatabaseError);
    sql:DatabaseError sqlerror = <sql:DatabaseError> result;
    test:assertTrue(strings:includes(sqlerror.message(), "Error while executing SQL query: CREATE TABLE " +
            "Student(id INT AUTO_INCREMENT, age INT). Incorrect table definition; there can be only one auto column " +
            "and it must be defined as a key."), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestIntegrityConstraintViolation() returns error? {
    Client dbClient = check new (host, user, password, errorDB, port);
    sql:ExecutionResult|error result = check  dbClient->execute(`CREATE TABLE employees( employee_id int (20) not null,
                                                        employee_name varchar (75) not null,supervisor_name varchar(75),
                                                        CONSTRAINT employee_pk PRIMARY KEY (employee_id))`);
    result = check  dbClient->execute(`CREATE TABLE departments( department_id int (20) not null,employee_id int not
                                       null,CONSTRAINT fk_employee FOREIGN KEY (employee_id)
                                       REFERENCES employees (employee_id))`);
    sql:ExecutionResult|error result1 = dbClient->execute(
                                    `INSERT INTO departments(department_id, employee_id) VALUES (250, 600)`);
    check dbClient.close();
    sql:DatabaseError sqlerror = <sql:DatabaseError> result1;
    test:assertTrue(strings:includes(sqlerror.message(), "Error while executing SQL query: INSERT INTO " +
                "departments(department_id, employee_id) VALUES (250, 600). Cannot add or update a child row: " +
                "a foreign key constraint fails (`ERROR_DB`.`departments`, CONSTRAINT " +
                "`fk_employee` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`))."),
                sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function testCreateProceduresWithMissingParams() returns error? {
    Client dbClient = check new (host, user, password, errorDB, port);
    _ = check dbClient->execute(`DROP TABLE IF EXISTS call_procedure`);
    _ = check dbClient->execute(`CREATE TABLE call_procedure(id INT , data boolean)`);
    _ = check dbClient->execute(`CREATE PROCEDURE InsertData (IN pId INT,
                                 IN pData BOOLEAN) BEGIN INSERT INTO call_procedure(id,
                                 data) VALUES (pId, pData); END`);
    sql:ProcedureCallResult|error result = dbClient->call(`call InsertData(1);`);
    check dbClient.close();
    sql:DatabaseError sqlError = <sql:DatabaseError> result;
    test:assertEquals(sqlError.message(), "Error while executing SQL query: call InsertData(1);. " +
                "Incorrect number of arguments for PROCEDURE ERROR_DB.InsertData; expected 2, got 1.",
                sqlError.message());
}

@test:Config {
    groups: ["error"],
    dependsOn: [testCreateProceduresWithMissingParams]
}
function testCreateProceduresWithParameterTypeMismatch() returns error? {
    Client dbClient = check new (host, user, password, errorDB, port);
    sql:ProcedureCallResult|error result = dbClient->call(`call InsertData(1, 'value');`);
    check dbClient.close();
    sql:DatabaseError sqlError = <sql:DatabaseError> result;
    test:assertEquals(sqlError.message(), "Error while executing SQL query: call InsertData(1, 'value');. " +
                "Incorrect integer value: 'value' for column 'pData' at row 1.", sqlError.message());
}

@test:Config {
    groups: ["error"]
}
function TestDuplicateKey() returns error? {
    Client dbClient = check new (host, user, password, errorDB, port);
    _ = check dbClient->execute(`CREATE TABLE Details(id INT AUTO_INCREMENT, age INT, PRIMARY KEY (id))`);
    sql:ParameterizedQuery insertQuery = `Insert into Details (id, age) values (1,10)`;
    sql:ExecutionResult|error insertResult = dbClient->execute(insertQuery);
    insertResult = dbClient->execute(insertQuery);
    check dbClient.close();
    test:assertTrue(insertResult is sql:DatabaseError);
    sql:DatabaseError sqlerror = <sql:DatabaseError> insertResult;
    test:assertTrue(strings:includes(sqlerror.message(), "Error while executing SQL query: Insert into " +
                        "Details (id, age) values (1,10). Duplicate entry '1' for key 'Details.PRIMARY'."),
                        sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function testCreateProceduresWithInvalidArgument() returns error? {
    Client dbClient = check new (host, user, password, errorDB, port);
    sql:ExecutionResult|error result = dbClient->execute(
            `CREATE PROCEDURE InsertData (IN_OUT pName VARCHAR(255) MODIFIES SQL DATA INSERT INTO DataTable(row_id) VALUES (pAge);`);
    check dbClient.close();
    sql:DatabaseError sqlError = <sql:DatabaseError> result;
    test:assertEquals(sqlError.message(), "Error while executing SQL query: CREATE PROCEDURE InsertData " +
                    "(IN_OUT pName VARCHAR(255) MODIFIES SQL DATA INSERT INTO DataTable(row_id) VALUES (pAge);. " +
                    "You have an error in your SQL syntax; check the manual that corresponds to your MySQL server " +
                    "version for the right syntax to use near 'pName VARCHAR(255) MODIFIES SQL DATA INSERT INTO " +
                    "DataTable(row_id) VALUES (pAge)' at line 1.", sqlError.message());
}
