// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/test;

string batchExecuteDB = "BATCH_EXECUTE_DB";

@test:Config {
    groups: ["batch-execute"]
}
function batchInsertIntoDataTable() returns error? {
    var data = [
        {intVal: 3, longVal: 9223372036854774807, floatVal: 123.34}, 
        {intVal: 4, longVal: 9223372036854774807, floatVal: 123.34}, 
        {intVal: 5, longVal: 9223372036854774807, floatVal: 123.34}
    ];
    sql:ParameterizedQuery[] sqlQueries = 
        from var row in data
        select `INSERT INTO DataTable (int_type, long_type, float_type) VALUES (${row.intVal}, ${row.longVal}, ${row.floatVal})`;
    validateBatchExecutionResult(check batchExecuteQueryMySQLClient(sqlQueries), [1, 1, 1], [2,3,4]);
}

@test:Config {
    groups: ["batch-execute"],
    dependsOn: [batchInsertIntoDataTable]
}
function batchInsertIntoDataTable2() returns error? {
    int intType = 6;
    sql:ParameterizedQuery sqlQuery = `INSERT INTO DataTable (int_type) VALUES(${intType})`;
    sql:ParameterizedQuery[] sqlQueries = [sqlQuery];
    validateBatchExecutionResult(check batchExecuteQueryMySQLClient(sqlQueries), [1], [5]);
}

@test:Config {
    groups: ["batch-execute"],
    dependsOn: [batchInsertIntoDataTable2]
}
function batchInsertIntoDataTableFailure() {
    var data = [
        {intVal: 7, longVal: 9223372036854774807, floatVal: 123.34}, 
        {intVal: 1, longVal: 9223372036854774807, floatVal: 123.34}, 
        {intVal: 9, longVal: 9223372036854774807, floatVal: 123.34}
    ];
    sql:ParameterizedQuery[] sqlQueries = 
        from var row in data
        select `INSERT INTO DataTable (int_type, long_type, float_type) VALUES (${row.intVal}, ${row.longVal}, ${row.floatVal})`;
    sql:ExecutionResult[]|error result = batchExecuteQueryMySQLClient(sqlQueries);
    test:assertTrue(result is error);

    if result is sql:BatchExecuteError {
        sql:BatchExecuteErrorDetail errorDetails = result.detail();
        test:assertEquals(errorDetails.executionResults.length(), 3);
        test:assertEquals(errorDetails.executionResults[0].affectedRowCount, 1);
        test:assertEquals(errorDetails.executionResults[1].affectedRowCount, -3);
        test:assertEquals(errorDetails.executionResults[2].affectedRowCount, 1);
    } else {
        test:assertFail("Database Error expected.");
    }
}

isolated function validateBatchExecutionResult(sql:ExecutionResult[] results, int[] rowCount, int[] lastId) {
    test:assertEquals(results.length(), rowCount.length());

    int i = 0;
    while i < results.length() {
        test:assertEquals(results[i].affectedRowCount, rowCount[i]);
        int|string? lastInsertIdVal = results[i].lastInsertId;
        if lastId[i] == -1 {
            test:assertNotEquals(lastInsertIdVal, ());
        } else if lastInsertIdVal is int {
            test:assertTrue(lastInsertIdVal > 1, "Last Insert Id is nil.");
        } else {
            test:assertFail("The last insert id should be an integer.");
        }
        i = i + 1;
    }
}

function batchExecuteQueryMySQLClient(sql:ParameterizedQuery[] sqlQueries) returns sql:ExecutionResult[]|error {
    Client dbClient = check new (host, user, password, batchExecuteDB, port);
    sql:ExecutionResult[] result = check dbClient->batchExecute(sqlQueries);
    check dbClient.close();
    return result;
}
