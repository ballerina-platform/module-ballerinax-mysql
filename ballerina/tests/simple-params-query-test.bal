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

string simpleParamsDb = "QUERY_SIMPLE_PARAMS_DB";

@test:Config {
    groups: ["query", "query-simple-params"]
}
function querySingleIntParam() returns error? {
    int rowId = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE row_id = ${rowId}`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryDoubleIntParam() returns error? {
    int rowId = 1;
    int intType = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE row_id = ${rowId} AND int_type =  ${intType}`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryIntAndLongParam() returns error? {
    int rowId = 1;
    int longType = 9223372036854774807;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE row_id = ${rowId} AND long_type = ${longType}`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryStringParam() returns error? {
    string stringType = "Hello";
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${stringType}`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryIntAndStringParam() returns error? {
    string stringType = "Hello";
    int rowId = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${stringType} AND row_id = ${rowId}`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryDoubleParam() returns error? {
    float doubleType = 2139095039.0;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE double_type = ${doubleType}`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryFloatParam() returns error? {
    float floatType = 123.34;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE FORMAT(float_type,2) = ${floatType}`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryDoubleAndFloatParam() returns error? {
    float floatType = 123.34;
    float doubleType = 2139095039.0;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE FORMAT(float_type,2) = ${floatType}
                                                                    and double_type = ${doubleType}`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryDecimalParam() returns error? {
    decimal decimalValue = 23.45;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE decimal_type = ${decimalValue}`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryDecimalAnFloatParam() returns error? {
    decimal decimalValue = 23.45;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE decimal_type = ${decimalValue}
                                                                    and double_type = 2139095039.0`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeVarcharStringParam() returns error? {
    sql:VarcharValue typeVal = new ("Hello");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${typeVal}`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeCharStringParam() returns error? {
    sql:CharValue typeVal = new ("Hello");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${typeVal}`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeNCharStringParam() returns error? {
    sql:NCharValue typeVal = new ("Hello");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${typeVal}`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeNVarCharStringParam() returns error? {
    sql:NVarcharValue typeVal = new ("Hello");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${typeVal}`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeVarCharIntegerParam() returns error? {
    sql:VarcharValue typeVal = new ("1");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${typeVal}`;

    decimal decimalVal = 25.45;
    record {}? returnData = check queryMysqlClient(sqlQuery);
    test:assertNotEquals(returnData, ());
    if returnData is () {
        test:assertFail("Query returns ()");
    } else {
        test:assertEquals(returnData["int_type"], 1);
        test:assertEquals(returnData["long_type"], 9372036854774807);
        test:assertEquals(returnData["double_type"], <float>29095039);
        test:assertEquals(returnData["boolean_type"], false);
        test:assertEquals(returnData["decimal_type"], decimalVal);
        test:assertEquals(returnData["string_type"], "1");
        test:assertTrue(returnData["float_type"] is float);
        test:assertEquals(returnData["row_id"], 3);
    }
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypBooleanBooleanParam() returns error? {
    sql:BooleanValue typeVal = new (true);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE boolean_type = ${typeVal}`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypBitIntParam() returns error? {
    sql:BitValue typeVal = new (1);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE boolean_type = ${typeVal}`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypBitStringParam() returns error? {
    sql:BitValue typeVal = new (true);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE boolean_type = ${typeVal}`;
    validateDataTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypBitInvalidIntParam() returns error? {
    sql:BitValue typeVal = new (12);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE boolean_type = ${typeVal}`;
    record {}|error? returnVal = queryMysqlClient(sqlQuery);
    test:assertTrue(returnVal is error);
    error dbError = <error>returnVal;
    test:assertEquals(dbError.message(), "Only 1 or 0 can be passed for BitValue SQL Type, but found :12");
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeIntIntParam() returns error? {
    sql:IntegerValue typeVal = new (2147483647);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE int_type = ${typeVal}`;
    validateNumericTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeTinyIntIntParam() returns error? {
    sql:SmallIntValue typeVal = new (127);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE tinyint_type = ${typeVal}`;
    validateNumericTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeSmallIntIntParam() returns error? {
    sql:SmallIntValue typeVal = new (32767);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE smallint_type = ${typeVal}`;
    validateNumericTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeMediumIntIntParam() returns error? {
    sql:IntegerValue typeVal = new (8388607);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE mediumint_type = ${typeVal}`;
    validateNumericTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeBigIntIntParam() returns error? {
    sql:BigIntValue typeVal = new (9223372036854774807);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE bigint_type = ${typeVal}`;
    validateNumericTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeDoubleDoubleParam() returns error? {
    sql:DoubleValue typeVal = new (1234.567);
    sql:DoubleValue typeVal2 = new (1234.57);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE float_type between ${typeVal} AND ${typeVal2}`;
    validateNumericTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeDoubleIntParam() returns error? {
    sql:DoubleValue typeVal = new (1234);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE float_type = ${typeVal}`;
    record {}? returnData = check queryMysqlClient(sqlQuery);

    if returnData is () {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 11);
        test:assertEquals(returnData["id"], 2);
        test:assertEquals(returnData["real_type"], 1234.0);
    }

}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeDoubleDecimalParam() returns error? {
    decimal decimalVal = 1234.567;
    decimal decimalVal2 = 1234.57;
    sql:DoubleValue typeVal = new (decimalVal);
    sql:DoubleValue typeVal2 = new (decimalVal2);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE float_type between ${typeVal} AND ${typeVal2}`;
    validateNumericTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeFloatDoubleParam() returns error? {
    sql:DoubleValue typeVal1 = new (1234.567);
    sql:DoubleValue typeVal2 = new (1234.57);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE float_type between ${typeVal1} AND ${typeVal2}`;
    validateNumericTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeRealDoubleParam() returns error? {
    sql:RealValue typeVal = new (1234.567);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE real_type = ${typeVal}`;
    validateNumericTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeNumericDoubleParam() returns error? {
    sql:NumericValue typeVal = new (1234.567);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE numeric_type = ${typeVal}`;
    validateNumericTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeNumericIntParam() returns error? {
    sql:NumericValue typeVal = new (1234);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE numeric_type = ${typeVal}`;
    record {}? returnData = check queryMysqlClient(sqlQuery);

    if returnData is () {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 11);
        test:assertEquals(returnData["id"], 2);
        test:assertEquals(returnData["real_type"], 1234.0);
    }
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeNumericDecimalParam() returns error? {
    decimal decimalVal = 1234.567;
    sql:NumericValue typeVal = new (decimalVal);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE numeric_type = ${typeVal}`;
    validateNumericTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeDecimalDoubleParam() returns error? {
    sql:DecimalValue typeVal = new (1234.567);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE decimal_type = ${typeVal}`;
    validateNumericTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeDecimalDecimalParam() returns error? {
    decimal decimalVal = 1234.567;
    sql:DecimalValue typeVal = new (decimalVal);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE decimal_type = ${typeVal}`;
    validateNumericTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryByteArrayParam() returns error? {
    record {}? value = check queryMysqlClient(`Select * from ComplexTypes where row_id = 1`);
    byte[] binaryData = <byte[]>getUntaintedData(value, "binary_type");

    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE binary_type = ${binaryData}`;
    validateComplexTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeBinaryByteParam() returns error? {
    record {}? value = check queryMysqlClient(`Select * from ComplexTypes where row_id = 1`);
    byte[] binaryData = <byte[]>getUntaintedData(value, "binary_type");
    sql:BinaryValue typeVal = new (binaryData);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE binary_type = ${typeVal}`;
    validateComplexTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeBinaryReadableByteChannelParam() returns error? {
    io:ReadableByteChannel byteChannel = check getByteColumnChannel();
    sql:BinaryValue typeVal = new (byteChannel);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE binary_type = ${typeVal}`;
    validateComplexTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeVarBinaryReadableByteChannelParam() returns error? {
    io:ReadableByteChannel byteChannel = check getByteColumnChannel();
    sql:VarBinaryValue typeVal = new (byteChannel);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE var_binary_type = ${typeVal}`;
    validateComplexTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeTinyBlobByteParam() returns error? {
    record {}? value = check queryMysqlClient(`Select * from ComplexTypes where row_id = 1`);
    byte[] binaryData = <byte[]>getUntaintedData(value, "tinyblob_type");
    sql:BinaryValue typeVal = new (binaryData);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE tinyblob_type = ${typeVal}`;
    validateComplexTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeBlobByteParam() returns error? {
    record {}? value = check queryMysqlClient(`Select * from ComplexTypes where row_id = 1`);
    byte[] binaryData = <byte[]>getUntaintedData(value, "blob_type");
    sql:BlobValue typeVal = new (binaryData);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE blob_type = ${typeVal}`;
    validateComplexTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeMediumBlobByteParam() returns error? {
    record {}? value = check queryMysqlClient(`Select * from ComplexTypes where row_id = 1`);
    byte[] binaryData = <byte[]>getUntaintedData(value, "mediumblob_type");
    sql:BlobValue typeVal = new (binaryData);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE mediumblob_type = ${typeVal}`;
    validateComplexTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeLongBlobByteParam() returns error? {
    record {}? value = check queryMysqlClient(`Select * from ComplexTypes where row_id = 1`);
    byte[] binaryData = <byte[]>getUntaintedData(value, "longblob_type");
    sql:BlobValue typeVal = new (binaryData);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE longblob_type = ${typeVal}`;
    validateComplexTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeBlobReadableByteChannelParam() returns error? {
    io:ReadableByteChannel byteChannel = check getBlobColumnChannel();
    sql:BlobValue typeVal = new (byteChannel);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE blob_type = ${typeVal}`;
    validateComplexTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeTinyTextStringParam() returns error? {
    sql:TextValue typeVal = new ("very long text");
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE tinytext_type = ${typeVal}`;
    validateComplexTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeTextStringParam() returns error? {
    sql:TextValue typeVal = new ("very long text");
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE text_type = ${typeVal}`;
    validateComplexTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeMediumTextStringParam() returns error? {
    sql:TextValue typeVal = new ("very long text");
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE mediumtext_type = ${typeVal}`;
    validateComplexTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeLongTextStringParam() returns error? {
    sql:TextValue typeVal = new ("very long text");
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE longtext_type = ${typeVal}`;
    validateComplexTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeTextReadableCharChannelParam() returns error? {
    io:ReadableCharacterChannel clobChannel = check getTextColumnChannel();
    sql:ClobValue typeVal = new (clobChannel);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE text_type = ${typeVal}`;
    validateComplexTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTypeNTextReadableCharChannelParam() returns error? {
    io:ReadableCharacterChannel clobChannel = check getTextColumnChannel();
    sql:NClobValue typeVal = new (clobChannel);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE text_type = ${typeVal}`;
    validateComplexTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryDateStringParam() returns error? {
    //Setting this as var char since the test database seems not working with date type.
    sql:VarcharValue typeVal = new ("2017-02-03");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE date_type = ${typeVal}`;
    validateDateTimeTypesTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryDateString2Param() returns error? {
    sql:VarcharValue typeVal = new ("2017-2-3");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE date_type = ${typeVal}`;
    validateDateTimeTypesTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTimeStringParam() returns error? {
    sql:VarcharValue typeVal = new ("11:35:45");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE time_type = ${typeVal}`;
    validateDateTimeTypesTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTimeStringInvalidParam() returns error? {
    sql:TimeValue typeVal = new ("xx.xx.xx");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE time_type = ${typeVal}`;
    record {}? returnVal = check queryMysqlClient(sqlQuery);
    test:assertTrue(returnVal is ());
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTimestampStringParam() returns error? {
    sql:VarcharValue typeVal = new ("2017-02-03 11:53:00");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE timestamp_type = ${typeVal}`;
    validateDateTimeTypesTableResult(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryTimestampStringInvalidParam() returns error? {
    sql:TimestampValue typeVal = new ("11:53:00 2017/02/03");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE timestamp_type = ${typeVal}`;
    record {}|error? returnVal = queryMysqlClient(sqlQuery);
    test:assertTrue(returnVal is error);
    error dbError = <error>returnVal;
    test:assertEquals(dbError.message(), "Error while executing SQL query: SELECT * from DateTimeTypes WHERE " + 
                    "timestamp_type =  ? . Incorrect TIMESTAMP value: '11:53:00 2017/02/03'.");
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryEnumStringParam() returns error? {
    string enumVal = "doctor";
    sql:ParameterizedQuery sqlQuery = `SELECT * from ENUMTable where enum_type= ${enumVal}`;
    validateEnumTable(check queryMysqlClient(sqlQuery));
}

type EnumResult record {|
    int id;
    string enum_type;
|};

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryEnumStringParam2() returns error? {
    string enumVal = "doctor";
    sql:ParameterizedQuery sqlQuery = `SELECT * from ENUMTable where enum_type= ${enumVal}`;
    validateEnumTable(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function querySetStringParam() returns error? {
    string setType = "a,d";
    sql:ParameterizedQuery sqlQuery = `SELECT * from SetTable where set_type= ${setType}`;
    record {}? returnData = check queryMysqlClient(sqlQuery);
    if returnData is () {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 2);
        test:assertEquals(returnData["row_id"], 1);
        test:assertEquals(returnData["set_type"].toString(), "a,d");
    }
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryGeoParam() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT id, ST_AsText(geom) as geomText from GEOTable`;
    validateGeoTable(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryGeoParam2() returns error? {
    string geoPoint = "POINT (7 52)";
    sql:ParameterizedQuery sqlQuery = 
            `SELECT id, ST_AsText(geom) as geomText from GEOTable where geom = ST_GeomFromText(${geoPoint})`;
    validateGeoTable(check queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryJsonParam() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT * from JsonTable`;
    validateJsonTableWithoutRequestType(check queryMysqlClient(sqlQuery));
}

type JsonResult record {|
    int id;
    json json_type;
|};

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryJsonParam2() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT * from JsonTable`;
    validateJsonTable(check queryMysqlClient(sqlQuery, resultType = JsonResult));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryJsonParam3() returns error? {
    int id = 100;
    sql:ParameterizedQuery sqlQuery = `SELECT * from JsonTable where json_type->'$.id'=${id}`;
    validateJsonTable(check queryMysqlClient(sqlQuery, resultType = JsonResult));
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryRecord() returns sql:Error? {
    int rowId = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE row_id = ${rowId}`;
    Client dbClient = check new (host, user, password, simpleParamsDb, port);
    record {} queryResult = check dbClient->queryRow(sqlQuery);
    check dbClient.close();
    validateDataTableResult(queryResult);
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryRecordNegative() returns sql:Error? {
    int rowId = 999;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE row_id = ${rowId}`;
    Client dbClient = check new (host, user, password, simpleParamsDb, port);
    record {}|sql:Error queryResult = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    if queryResult is sql:Error {
        test:assertTrue(queryResult is sql:NoRowsError);
        test:assertTrue(queryResult.message().endsWith("Query did not retrieve any rows."), "Incorrect error message");
    } else {
        test:assertFail("Expected no rows error with empty query result.");
    }
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryRecordNegative3() returns error? {
    int rowId = 1;
    Client dbClient = check new (host, user, password, simpleParamsDb, port);
    sql:ParameterizedQuery sqlQuery = `SELECT row_id, invalid_column_name from DataTable WHERE row_id = ${rowId}`;
    record {}|error queryResult = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    if queryResult is error {
        test:assertTrue(queryResult.message().endsWith("Unknown column 'invalid_column_name' in 'field list'."), 
                        "Incorrect error message");
    } else {
        test:assertFail("Expected error when querying with invalid column name.");
    }
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryValue() returns error? {
    Client dbClient = check new (host, user, password, simpleParamsDb, port);
    int count = check dbClient->queryRow(`SELECT COUNT(*) FROM DataTable`);
    check dbClient.close();
    test:assertEquals(count, 3);
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryValueNegative1() returns error? {
    Client dbClient = check new (host, user, password, simpleParamsDb, port);
    int rowId = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE row_id = ${rowId}`;
    int|error queryResult = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    if queryResult is error {
        test:assertTrue(queryResult is sql:TypeMismatchError, "Incorrect error type");
        test:assertEquals(queryResult.message(), "Expected type to be 'int' but found 'record{}'.");
    } else {
        test:assertFail("Expected error when query result contains multiple columns.");
    }
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryValueNegative2() returns error? {
    Client dbClient = check new (host, user, password, simpleParamsDb, port);
    int rowId = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = ${rowId}`;
    int|error queryResult = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    if queryResult is error {
        test:assertEquals(queryResult.message(), 
                        "SQL Type 'Retrieved SQL type' cannot be converted to ballerina type 'int'.", 
                        "Incorrect error message");
    } else {
        test:assertFail("Expected error when query returns unexpected result type.");
    }
}

function queryMysqlClient(sql:ParameterizedQuery sqlQuery, typedesc<record {}>? resultType = ()) 
returns record {}|error? {
    Client dbClient = check new (host, user, password, simpleParamsDb, port);
    stream<record {}, error?> streamData;
    if resultType is () {
        streamData = dbClient->query(sqlQuery);
    } else {
        streamData = dbClient->query(sqlQuery, resultType);
    }
    record {|record {} value;|}? data = check streamData.next();
    check streamData.close();
    record {}? value = data?.value;
    check dbClient.close();
    return value;
}

isolated function validateDataTableResult(record {}? returnData) {
    decimal decimalVal = 23.45;
    if returnData is () {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(returnData["row_id"], 1);
        test:assertEquals(returnData["int_type"], 1);
        test:assertEquals(returnData["long_type"], 9223372036854774807);
        test:assertEquals(returnData["double_type"], <float>2139095039);
        test:assertEquals(returnData["boolean_type"], true);
        test:assertEquals(returnData["decimal_type"], decimalVal);
        test:assertEquals(returnData["string_type"], "Hello");
        test:assertTrue(returnData["float_type"] is float);
    }
}

isolated function validateNumericTableResult(record {}? returnData) {
    if returnData is () {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(returnData["id"], 1);
        test:assertEquals(returnData["int_type"], 2147483647);
        test:assertEquals(returnData["bigint_type"], 9223372036854774807);
        test:assertEquals(returnData["smallint_type"], 32767);
        test:assertEquals(returnData["mediumint_type"], 8388607);
        test:assertEquals(returnData["tinyint_type"], 127);
        test:assertEquals(returnData["bit_type"], true);
        test:assertEquals(returnData["real_type"], 1234.567);
        test:assertTrue(returnData["decimal_type"] is decimal);
        test:assertTrue(returnData["numeric_type"] is decimal);
        test:assertTrue(returnData["float_type"] is float);
    }
}

isolated function validateComplexTableResult(record {}? returnData) {
    if returnData is () {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 11);
        test:assertEquals(returnData["row_id"], 1);
        test:assertEquals(returnData["text_type"], "very long text");
    }
}

isolated function validateDateTimeTypesTableResult(record {}? returnData) {
    if returnData is () {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 5);
        test:assertEquals(returnData["row_id"], 1);
        test:assertTrue(returnData["date_type"].toString().startsWith("2017-02-03"));
    }
}

isolated function validateEnumTable(record {}? returnData) {
    if returnData is () {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 2);
        test:assertEquals(returnData["id"], 1);
        test:assertEquals(returnData["enum_type"].toString(), "doctor");
    }
}

isolated function validateGeoTable(record {}? returnData) {
    if returnData is () {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 2);
        test:assertEquals(returnData["id"], 1);
        test:assertEquals(returnData["geomText"].toString(), "POINT(7 52)");
    }
}

isolated function validateJsonTable(record {}? returnData) {
    if returnData is () {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 2);
        test:assertEquals(returnData["id"], 1);

        json expected = {
            id: 100,
            name: "Joe",
            groups: [2, 5]
        };

        test:assertEquals(returnData["json_type"], expected);
    }
}

isolated function validateJsonTableWithoutRequestType(record {}? returnData) {
    if returnData is () {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 2);
        test:assertEquals(returnData["id"], 1);
        test:assertEquals(returnData["json_type"], "{\"id\": 100, \"name\": \"Joe\", \"groups\": [2, 5]}");
    }
}
