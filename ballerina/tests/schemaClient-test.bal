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

import ballerina/test;
import ballerina/sql;

@test:Config {
    groups: ["schemaClientTest"]
}
function testListTablesWorking() returns error? {
    SchemaClient client1 = check new("localhost", "root", "password", "testDB");
    string [] tableList = check client1->listTables();
    check client1.close();
    test:assertEquals(tableList, ["employees","offices"]);
}

@test:Config {
    groups: ["schemaClientTest"]
}
function testListTablesFail() returns error? {
    SchemaClient client1 = check new("localhost", "root", "password", "testDB1");
    string [] tableList = check client1->listTables();
    check client1.close();
    test:assertEquals(tableList, []);
}

@test:Config {
    groups: ["schemaClientTest"]
}
function testGetTableInfoNoColumns() returns error? {
    SchemaClient client1 = check new("localhost", "root", "password", "testDB");
    sql:TableDefinition 'table = check client1->getTableInfo("employees", include = sql:NO_COLUMNS);
    check client1.close();
    test:assertEquals('table, {"name":"employees","type":"BASE TABLE"});
}

@test:Config {
    groups: ["schemaClientTest"]
}
function testGetTableInfoColumnsOnly() returns error? {
    SchemaClient client1 = check new("localhost", "root", "password", "testDB");
    sql:TableDefinition 'table = check client1->getTableInfo("employees", include = sql:COLUMNS_ONLY);
    check client1.close();
    test:assertEquals('table.name, "employees");
    test:assertEquals('table.'type, "BASE TABLE");
    test:assertEquals((<sql:ColumnDefinition[]>'table.columns).length(), 8);  
}

@test:Config {
    groups: ["schemaClientTest"]
}
function testGetTableInfoColumnsWithConstraints() returns error? {
    SchemaClient client1 = check new("localhost", "root", "password", "testDB");
    sql:TableDefinition 'table = check client1->getTableInfo("employees", include = sql:COLUMNS_WITH_CONSTRAINTS);
    check client1.close();
    test:assertEquals('table.name, "employees");
    test:assertEquals('table.'type, "BASE TABLE");
    test:assertEquals((<sql:ColumnDefinition[]>'table.columns).length(), 8);
}

@test:Config {
    groups: ["schemaClientTest"]
}
function testGetTableInfoFail() returns error? {
    SchemaClient client1 = check new("localhost", "root", "password", "testDB");
    sql:TableDefinition|sql:Error 'table = client1->getTableInfo("employee", include = sql:NO_COLUMNS);
    check client1.close();
    if 'table is sql:Error {
        test:assertEquals('table.message(), "Selected Table does not exist or the user does not have privilages of viewing the Table");
    } else {
        test:assertFail("Expected result not recieved");
    }
}

@test:Config {
    groups: ["schemaClientTest"]
}
function testListRoutinesWorking() returns error? {
    SchemaClient client1 = check new("localhost", "root", "password", "testDB");
    string [] routineList = check client1->listRoutines();
    check client1.close();
    test:assertEquals(routineList, ["getEmpsName"]);
}

@test:Config {
    groups: ["schemaClientTest"]
}
function testListRoutinesFail() returns error? {
    SchemaClient client1 = check new("localhost", "root", "password", "testDB1");
    string [] routineList = check client1->listRoutines();
    check client1.close();
    test:assertEquals(routineList, []);
}

@test:Config {
    groups: ["schemaClientTest"]
}
function testGetRoutineInfoWorking() returns error? {
    SchemaClient client1 = check new("localhost", "root", "password", "testDB");
    sql:RoutineDefinition routine = check client1->getRoutineInfo("getEmpsName");
    check client1.close();
    test:assertEquals(routine.name, "getEmpsName");
    test:assertEquals(routine.'type, "PROCEDURE");
    test:assertEquals((<sql:ParameterDefinition[]>routine.parameters).length(), 2);
}

@test:Config {
    groups: ["schemaClientTest"]
}
function testGetRoutineInfoFail() returns error? {
    SchemaClient client1 = check new("localhost", "root", "password", "testDB");
    sql:RoutineDefinition|sql:Error routine = client1->getRoutineInfo("getEmpsNames");
    check client1.close();
    if routine is sql:Error {
        test:assertEquals(routine.message(), "Selected Routine does not exist or the user does not have privilages of viewing it");
    } else {
        test:assertFail("Expected result not recieved");
    }
}