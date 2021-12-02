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

import ballerina/io;
import ballerina/sql;
import ballerina/test;

string executeParamsDb = "EXECUTE_PARAMS_DB";

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoDataTable() returns error? {
    int rowId = 4;
    int intType = 1;
    int longType = 9223372036854774807;
    float floatType = 123.34;
    int doubleType = 2139095039;
    boolean boolType = true;
    string stringType = "Hello";
    decimal decimalType = 23.45;

    sql:ParameterizedQuery sqlQuery =
      `INSERT INTO DataTable (row_id, int_type, long_type, float_type, double_type, boolean_type, string_type, decimal_type)
        VALUES(${rowId}, ${intType}, ${longType}, ${floatType}, ${doubleType}, ${boolType}, ${stringType}, ${decimalType})`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDataTable]
}
function insertIntoDataTable2() returns error? {
    int rowId = 5;
    sql:ParameterizedQuery sqlQuery = `INSERT INTO DataTable (row_id) VALUES(${rowId})`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDataTable2]
}
function insertIntoDataTable3() returns error? {
    int rowId = 6;
    int intType = 1;
    int longType = 9223372036854774807;
    float floatType = 123.34;
    int doubleType = 2139095039;
    boolean boolType = false;
    string stringType = "1";
    decimal decimalType = 23.45;

    sql:ParameterizedQuery sqlQuery =
      `INSERT INTO DataTable (row_id, int_type, long_type, float_type, double_type, boolean_type, string_type, decimal_type)
        VALUES(${rowId}, ${intType}, ${longType}, ${floatType}, ${doubleType}, ${boolType}, ${stringType}, ${decimalType})`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDataTable3]
}
function insertIntoDataTable4() returns error? {
    sql:IntegerValue rowId = new (7);
    sql:IntegerValue intType = new (2);
    sql:BigIntValue longType = new (9372036854774807);
    sql:FloatValue floatType = new (124.34);
    sql:DoubleValue doubleType = new (29095039);
    sql:BooleanValue boolType = new (false);
    sql:VarcharValue stringType = new ("stringvalue");
    decimal decimalVal = 25.45;
    sql:DecimalValue decimalType = new (decimalVal);

    sql:ParameterizedQuery sqlQuery =
      `INSERT INTO DataTable (row_id, int_type, long_type, float_type, double_type, boolean_type, string_type, decimal_type)
        VALUES(${rowId}, ${intType}, ${longType}, ${floatType}, ${doubleType}, ${boolType}, ${stringType}, ${decimalType})`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDataTable4]
}
function deleteDataTable1() returns error? {
    int rowId = 1;
    int intType = 1;
    int longType = 9223372036854774807;
    int doubleType = 2139095039;
    boolean boolType = true;
    string stringType = "Hello";
    decimal decimalType = 23.45;

    sql:ParameterizedQuery sqlQuery =
            `DELETE FROM DataTable where row_id=${rowId} AND int_type=${intType} AND long_type=${longType}
              AND double_type=${doubleType} AND boolean_type=${boolType}
              AND string_type=${stringType} AND decimal_type=${decimalType}`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [deleteDataTable1]
}
function deleteDataTable2() returns error? {
    int rowId = 2;
    sql:ParameterizedQuery sqlQuery = `DELETE FROM DataTable where row_id = ${rowId}`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [deleteDataTable2]
}
function deleteDataTable3() returns error? {
    sql:IntegerValue rowId = new (3);
    sql:IntegerValue intType = new (1);
    sql:BigIntValue longType = new (9372036854774807);
    sql:DoubleValue doubleType = new (29095039);
    sql:BooleanValue boolType = new (false);
    sql:VarcharValue stringType = new ("1");
    decimal decimalVal = 25.45;
    sql:DecimalValue decimalType = new (decimalVal);

    sql:ParameterizedQuery sqlQuery =
            `DELETE FROM DataTable where row_id=${rowId} AND int_type=${intType} AND long_type=${longType}
              AND double_type=${doubleType} AND boolean_type=${boolType}
              AND string_type=${stringType} AND decimal_type=${decimalType}`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [deleteDataTable3]
}
function insertIntoComplexTable() returns error? {
    record {}? value = check queryMysqlClient(`Select * from ComplexTypes where row_id = 1`);
    byte[] binaryData = <byte[]>getUntaintedData(value, "blob_type");
    int rowId = 5;
    string stringType = "very long text";
    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ComplexTypes (row_id, blob_type, text_type, binary_type, var_binary_type) VALUES (
        ${rowId}, ${binaryData}, ${stringType}, ${binaryData}, ${binaryData})`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoComplexTable]
}
function insertIntoComplexTable2() returns error? {
    io:ReadableByteChannel blobChannel = check getBlobColumnChannel();
    io:ReadableCharacterChannel clobChannel = check getClobColumnChannel();
    io:ReadableByteChannel byteChannel = check getByteColumnChannel();

    sql:BlobValue blobType = new (blobChannel);
    sql:TextValue textType = new (clobChannel);
    sql:BlobValue binaryType = new (byteChannel);
    int rowId = 6;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ComplexTypes (row_id, blob_type, text_type, binary_type, var_binary_type) VALUES (
        ${rowId}, ${blobType}, ${textType}, ${binaryType}, ${binaryType})`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoComplexTable2]
}
function insertIntoComplexTable3() returns error? {
    int rowId = 7;
    var nilType = ();
    sql:ParameterizedQuery sqlQuery =
            `INSERT INTO ComplexTypes (row_id, blob_type, text_type, binary_type, var_binary_type) VALUES (
            ${rowId}, ${nilType}, ${nilType}, ${nilType}, ${nilType})`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoComplexTable3]
}
function deleteComplexTable() returns error? {
    record {}? value = check queryMysqlClient(`Select * from ComplexTypes where row_id = 1`);
    byte[] binaryData = <byte[]>getUntaintedData(value, "blob_type");

    int rowId = 2;
    sql:ParameterizedQuery sqlQuery =
            `DELETE FROM ComplexTypes where row_id = ${rowId} AND blob_type= ${binaryData}`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [deleteComplexTable]
}
function deleteComplexTable2() returns error? {
    sql:BlobValue blobType = new ();
    sql:TextValue textType = new ();

    int rowId = 4;
    sql:ParameterizedQuery sqlQuery =
            `DELETE FROM ComplexTypes where row_id = ${rowId} AND blob_type= ${blobType} AND text_type=${textType}`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 0);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [deleteComplexTable2]
}
function insertIntoNumericTable() returns error? {
    sql:BitValue bitType = new (1);
    int rowId = 3;
    int intType = 2147483647;
    int bigIntType = 9223372036854774807;
    int smallIntType = 32767;
    int tinyIntType = 127;
    decimal decimalType = 1234.567;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO NumericTypes (id, int_type, bigint_type, smallint_type, tinyint_type, bit_type, decimal_type,
        numeric_type, float_type, real_type) VALUES(${rowId},${intType},${bigIntType},${smallIntType},${tinyIntType},
        ${bitType},${decimalType},${decimalType},${decimalType},${decimalType})`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1, 2);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoNumericTable]
}
function insertIntoNumericTable2() returns error? {
    int rowId = 4;
    var nilType = ();
    sql:ParameterizedQuery sqlQuery =
            `INSERT INTO NumericTypes (id, int_type, bigint_type, smallint_type, tinyint_type, bit_type, decimal_type,
            numeric_type, float_type, real_type) VALUES(${rowId},${nilType},${nilType},${nilType},${nilType},
            ${nilType},${nilType},${nilType},${nilType},${nilType})`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1, 2);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoNumericTable2]
}
function insertIntoNumericTable3() returns error? {
    sql:IntegerValue id = new (5);
    sql:IntegerValue intType = new (2147483647);
    sql:BigIntValue bigIntType = new (9223372036854774807);
    sql:SmallIntValue smallIntType = new (32767);
    sql:SmallIntValue tinyIntType = new (127);
    sql:BitValue bitType = new (1);
    decimal decimalVal = 1234.567;
    sql:DecimalValue decimalType = new (decimalVal);
    sql:NumericValue numbericType = new (1234.567);
    sql:FloatValue floatType = new (1234.567);
    sql:RealValue realType = new (1234.567);

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO NumericTypes (id, int_type, bigint_type, smallint_type, tinyint_type, bit_type, decimal_type,
        numeric_type, float_type, real_type) VALUES(${id},${intType},${bigIntType},${smallIntType},${tinyIntType},
        ${bitType},${decimalType},${numbericType},${floatType},${realType})`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1, 2);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoNumericTable3]
}
function insertIntoDateTimeTable() returns error? {
    int rowId = 2;
    string dateType = "2017-02-03";
    string timeType = "11:35:45";
    string dateTimeType = "2017-02-03 11:53:00";
    string timeStampType = "2017-02-03 11:53:00";

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO DateTimeTypes (row_id, date_type, time_type, datetime_type, timestamp_type)
        VALUES(${rowId}, ${dateType}, ${timeType}, ${dateTimeType}, ${timeStampType})`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDateTimeTable]
}
function insertIntoDateTimeTable2() returns error? {
    sql:DateValue dateVal = new ("2017-02-03");
    sql:TimeValue timeVal = new ("11:35:45");
    sql:DateTimeValue dateTimeVal = new ("2017-02-03 11:53:00");
    sql:TimestampValue timestampVal = new ("2017-02-03 11:53:00");
    int rowId = 3;

    sql:ParameterizedQuery sqlQuery =
            `INSERT INTO DateTimeTypes (row_id, date_type, time_type, datetime_type, timestamp_type)
            VALUES(${rowId}, ${dateVal}, ${timeVal}, ${dateTimeVal}, ${timestampVal})`;

    validateResult(check executeQueryMysqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDateTimeTable2]
}
function insertIntoDateTimeTable3() returns error? {
    sql:DateValue dateVal = new ();
    sql:TimeValue timeVal = new ();
    sql:DateTimeValue dateTimeVal = new ();
    sql:TimestampValue timestampVal = new ();
    int rowId = 4;

    sql:ParameterizedQuery sqlQuery =
                `INSERT INTO DateTimeTypes (row_id, date_type, time_type, datetime_type, timestamp_type)
                VALUES(${rowId}, ${dateVal}, ${timeVal}, ${dateTimeVal}, ${timestampVal})`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDateTimeTable3]
}
function insertIntoDateTimeTable4() returns error? {
    int rowId = 5;
    var nilType = ();

    sql:ParameterizedQuery sqlQuery =
            `INSERT INTO DateTimeTypes (row_id, date_type, time_type, datetime_type, timestamp_type)
            VALUES(${rowId}, ${nilType}, ${nilType}, ${nilType}, ${nilType})`;
    validateResult(check executeQueryMysqlClient(sqlQuery), 1);
}

function executeQueryMysqlClient(sql:ParameterizedQuery sqlQuery) returns sql:ExecutionResult|error {
    Client dbClient = check new (host, user, password, executeParamsDb, port);
    sql:ExecutionResult result = check dbClient->execute(sqlQuery);
    check dbClient.close();
    return result;
}

isolated function validateResult(sql:ExecutionResult result, int rowCount, int? lastId = ()) {
    test:assertExactEquals(result.affectedRowCount, rowCount, "Affected row count is different.");

    if lastId is () {
        test:assertEquals(result.lastInsertId, (), "Last Insert Id is not nil.");
    } else {
        int|string? lastInsertIdVal = result.lastInsertId;
        if lastInsertIdVal is int {
            test:assertTrue(lastInsertIdVal > 1, "Last Insert Id is nil.");
        } else {
            test:assertFail("The last insert id should be an integer.");
        }
    }

}
