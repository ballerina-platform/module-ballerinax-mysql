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
    groups: ["query","query-simple-params"]
}
function querySingleIntParam() {
    int rowId = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE row_id = ${rowId}`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDoubleIntParam() {
    int rowId = 1;
    int intType = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE row_id = ${rowId} AND int_type =  ${intType}`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryIntAndLongParam() {
    int rowId = 1;
    int longType = 9223372036854774807;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE row_id = ${rowId} AND long_type = ${longType}`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryStringParam() {
    string stringType = "Hello";
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${stringType}`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryIntAndStringParam() {
    string stringType = "Hello";
    int rowId =1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${stringType} AND row_id = ${rowId}`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDoubleParam() {
    float doubleType = 2139095039.0;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE double_type = ${doubleType}`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryFloatParam() {
    float floatType = 123.34;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE FORMAT(float_type,2) = ${floatType}`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDoubleAndFloatParam() {
    float floatType = 123.34;
    float doubleType = 2139095039.0;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE FORMAT(float_type,2) = ${floatType}
                                                                    and double_type = ${doubleType}`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDecimalParam() {
    decimal decimalValue = 23.45;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE decimal_type = ${decimalValue}`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDecimalAnFloatParam() {
    decimal decimalValue = 23.45;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE decimal_type = ${decimalValue}
                                                                    and double_type = 2139095039.0`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeVarcharStringParam() {
    sql:VarcharValue typeVal = new ("Hello");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${typeVal}`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeCharStringParam() {
    sql:CharValue typeVal = new ("Hello");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${typeVal}`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeNCharStringParam() {
    sql:NCharValue typeVal = new ("Hello");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${typeVal}`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeNVarCharStringParam() {
    sql:NVarcharValue typeVal = new ("Hello");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${typeVal}`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeVarCharIntegerParam() {
    sql:VarcharValue typeVal = new ("1");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${typeVal}`;

    decimal decimalVal = 25.45;
    record {}? returnData = queryMysqlClient(sqlQuery);
    test:assertNotEquals(returnData, ());
    if (returnData is ()) {
        test:assertFail("Query returns ()");
    } else {
        test:assertEquals(returnData["int_type"], 1);
        test:assertEquals(returnData["long_type"], 9372036854774807);
        test:assertEquals(returnData["double_type"], <float> 29095039);
        test:assertEquals(returnData["boolean_type"], false);
        test:assertEquals(returnData["decimal_type"], decimalVal);
        test:assertEquals(returnData["string_type"], "1");
        test:assertTrue(returnData["float_type"] is float); 
        test:assertEquals(returnData["row_id"], 3);  
    }
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypBooleanBooleanParam() {
    sql:BooleanValue typeVal = new (true);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE boolean_type = ${typeVal}`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypBitIntParam() {
    sql:BitValue typeVal = new (1);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE boolean_type = ${typeVal}`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypBitStringParam() {
    sql:BitValue typeVal = new (true);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE boolean_type = ${typeVal}`;
    validateDataTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypBitInvalidIntParam() {
    sql:BitValue typeVal = new (12);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE boolean_type = ${typeVal}`;
    record{}|error? returnVal = trap queryMysqlClient(sqlQuery);
    test:assertTrue(returnVal is error);
    error dbError = <error> returnVal;
    test:assertEquals(dbError.message(), "Only 1 or 0 can be passed for BitValue SQL Type, but found :12");
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeIntIntParam() {
    sql:IntegerValue typeVal = new (2147483647);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE int_type = ${typeVal}`;
    validateNumericTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeTinyIntIntParam() {
    sql:SmallIntValue typeVal = new (127);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE tinyint_type = ${typeVal}`;
    validateNumericTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeSmallIntIntParam() {
    sql:SmallIntValue typeVal = new (32767);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE smallint_type = ${typeVal}`;
    validateNumericTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeMediumIntIntParam() {
    sql:IntegerValue typeVal = new (8388607);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE mediumint_type = ${typeVal}`;
    validateNumericTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeBigIntIntParam() {
    sql:BigIntValue typeVal = new (9223372036854774807);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE bigint_type = ${typeVal}`;
    validateNumericTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeDoubleDoubleParam() {
    sql:DoubleValue typeVal = new (1234.567);
    sql:DoubleValue typeVal2 = new (1234.57);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE float_type between ${typeVal} AND ${typeVal2}`;
    validateNumericTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeDoubleIntParam() {
    sql:DoubleValue typeVal = new (1234);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE float_type = ${typeVal}`;
    record{}? returnData = queryMysqlClient(sqlQuery);

    if (returnData is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 11);
        test:assertEquals(returnData["id"], 2);
        test:assertEquals(returnData["real_type"], 1234.0);
    }

}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeDoubleDecimalParam() {
    decimal decimalVal = 1234.567;
    decimal decimalVal2 = 1234.57;
    sql:DoubleValue typeVal = new (decimalVal);
    sql:DoubleValue typeVal2 = new (decimalVal2);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE float_type between ${typeVal} AND ${typeVal2}`;
    validateNumericTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeFloatDoubleParam() {
    sql:DoubleValue typeVal1 = new (1234.567);
    sql:DoubleValue typeVal2 = new (1234.57);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE float_type between ${typeVal1} AND ${typeVal2}`;
    validateNumericTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeRealDoubleParam() {
    sql:RealValue typeVal = new (1234.567);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE real_type = ${typeVal}`;
    validateNumericTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeNumericDoubleParam() {
    sql:NumericValue typeVal = new (1234.567);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE numeric_type = ${typeVal}`;
    validateNumericTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeNumericIntParam() {
    sql:NumericValue typeVal = new (1234);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE numeric_type = ${typeVal}`;
    record{}? returnData = queryMysqlClient(sqlQuery);

    if (returnData is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 11);
        test:assertEquals(returnData["id"], 2);
        test:assertEquals(returnData["real_type"], 1234.0);
    }
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeNumericDecimalParam() {
    decimal decimalVal = 1234.567;
    sql:NumericValue typeVal = new (decimalVal);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE numeric_type = ${typeVal}`;
    validateNumericTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeDecimalDoubleParam() {
    sql:DecimalValue typeVal = new (1234.567);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE decimal_type = ${typeVal}`;
    validateNumericTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeDecimalDecimalParam() {
    decimal decimalVal = 1234.567;
    sql:DecimalValue typeVal = new (decimalVal);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE decimal_type = ${typeVal}`;
    validateNumericTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryByteArrayParam() {
    record {}|error? value = queryMysqlClient("Select * from ComplexTypes where row_id = 1");
    byte[] binaryData = <byte[]>getUntaintedData(value, "binary_type");

    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE binary_type = ${binaryData}`;
    validateComplexTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeBinaryByteParam() {
    record {}|error? value = queryMysqlClient("Select * from ComplexTypes where row_id = 1");
    byte[] binaryData = <byte[]>getUntaintedData(value, "binary_type");
    sql:BinaryValue typeVal = new (binaryData);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE binary_type = ${typeVal}`;
    validateComplexTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeBinaryReadableByteChannelParam() {
    io:ReadableByteChannel byteChannel = getByteColumnChannel();
    sql:BinaryValue typeVal = new (byteChannel);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE binary_type = ${typeVal}`;
    validateComplexTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeVarBinaryReadableByteChannelParam() {
    io:ReadableByteChannel byteChannel = getByteColumnChannel();
    sql:VarBinaryValue typeVal = new (byteChannel);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE var_binary_type = ${typeVal}`;
    validateComplexTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeTinyBlobByteParam() {
    record {}|error? value = queryMysqlClient("Select * from ComplexTypes where row_id = 1");
    byte[] binaryData = <byte[]>getUntaintedData(value, "tinyblob_type");
    sql:BinaryValue typeVal = new (binaryData);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE tinyblob_type = ${typeVal}`;
    validateComplexTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeBlobByteParam() {
    record {}|error? value = queryMysqlClient("Select * from ComplexTypes where row_id = 1");
    byte[] binaryData = <byte[]>getUntaintedData(value, "blob_type");
    sql:BlobValue typeVal = new (binaryData);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE blob_type = ${typeVal}`;
    validateComplexTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeMediumBlobByteParam() {
    record {}|error? value = queryMysqlClient("Select * from ComplexTypes where row_id = 1");
    byte[] binaryData = <byte[]>getUntaintedData(value, "mediumblob_type");
    sql:BlobValue typeVal = new (binaryData);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE mediumblob_type = ${typeVal}`;
    validateComplexTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeLongBlobByteParam() {
    record {}|error? value = queryMysqlClient("Select * from ComplexTypes where row_id = 1");
    byte[] binaryData = <byte[]>getUntaintedData(value, "longblob_type");
    sql:BlobValue typeVal = new (binaryData);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE longblob_type = ${typeVal}`;
    validateComplexTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeBlobReadableByteChannelParam() {
    io:ReadableByteChannel byteChannel = getBlobColumnChannel();
    sql:BlobValue typeVal = new (byteChannel);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE blob_type = ${typeVal}`;
    validateComplexTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeTinyTextStringParam() {
    sql:TextValue typeVal = new ("very long text");
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE tinytext_type = ${typeVal}`;
    validateComplexTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeTextStringParam() {
    sql:TextValue typeVal = new ("very long text");
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE text_type = ${typeVal}`;
    validateComplexTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeMediumTextStringParam() {
    sql:TextValue typeVal = new ("very long text");
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE mediumtext_type = ${typeVal}`;
    validateComplexTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeLongTextStringParam() {
    sql:TextValue typeVal = new ("very long text");
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE longtext_type = ${typeVal}`;
    validateComplexTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeTextReadableCharChannelParam() {
    io:ReadableCharacterChannel clobChannel = getTextColumnChannel();
    sql:ClobValue typeVal = new (clobChannel);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE text_type = ${typeVal}`;
    validateComplexTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeNTextReadableCharChannelParam() {
    io:ReadableCharacterChannel clobChannel = getTextColumnChannel();
    sql:NClobValue typeVal = new (clobChannel);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE text_type = ${typeVal}`;
    validateComplexTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDateStringParam() {
    //Setting this as var char since the test database seems not working with date type.
    sql:VarcharValue typeVal = new ("2017-02-03");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE date_type = ${typeVal}`;
    validateDateTimeTypesTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDateString2Param() {
    sql:VarcharValue typeVal = new ("2017-2-3");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE date_type = ${typeVal}`;
    validateDateTimeTypesTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTimeStringParam() {
    sql:VarcharValue typeVal = new ("11:35:45");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE time_type = ${typeVal}`;
    validateDateTimeTypesTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"],
    enable: false
}
function queryTimeStringInvalidParam() {
    sql:TimeValue typeVal = new ("xx:xx:xx");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE time_type = ${typeVal}`;
    record{}|error? returnVal = trap queryMysqlClient(sqlQuery);
    test:assertTrue(returnVal is error);
    error dbError = <error> returnVal;
    test:assertEquals(dbError.message(), 
        "Error while executing SQL query: SELECT * from DateTimeTypes WHERE time_type =  ? . java.lang.IllegalArgumentException");
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTimestampStringParam() {
    sql:VarcharValue typeVal = new ("2017-02-03 11:53:00");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE timestamp_type = ${typeVal}`;
    validateDateTimeTypesTableResult(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTimestampStringInvalidParam() {
    sql:TimestampValue typeVal = new ("2017/02/0311:53:00");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE timestamp_type = ${typeVal}`;
    record{}|error? returnVal = trap queryMysqlClient(sqlQuery);
    test:assertTrue(returnVal is error);
    error dbError = <error> returnVal;
    test:assertEquals(dbError.message(), "Error while executing SQL query: SELECT * from DateTimeTypes WHERE " +
                "timestamp_type =  ? . Incorrect TIMESTAMP value: '2017/02/0311:53:00'.");
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryEnumStringParam() {
    string enumVal = "doctor";
    sql:ParameterizedQuery sqlQuery = `SELECT * from ENUMTable where enum_type= ${enumVal}`;
    validateEnumTable(queryMysqlClient(sqlQuery));
}

type EnumResult record {|
    int id;
    string enum_type;
|};

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryEnumStringParam2() {
    string enumVal = "doctor";
    sql:ParameterizedQuery sqlQuery = `SELECT * from ENUMTable where enum_type= ${enumVal}`;
    validateEnumTable(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function querySetStringParam() {
    string setType = "a,d";
    sql:ParameterizedQuery sqlQuery = `SELECT * from SetTable where set_type= ${setType}`;
    record{}? returnData = queryMysqlClient(sqlQuery);
    if (returnData is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 2);
        test:assertEquals(returnData["row_id"], 1);
        test:assertEquals(returnData["set_type"].toString(), "a,d");
    }
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryGeoParam() {
    sql:ParameterizedQuery sqlQuery = `SELECT id, ST_AsText(geom) as geomText from GEOTable`;
    validateGeoTable(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryGeoParam2() {
    string geoPoint = "POINT (7 52)";
    sql:ParameterizedQuery sqlQuery =
            `SELECT id, ST_AsText(geom) as geomText from GEOTable where geom = ST_GeomFromText(${geoPoint})`;
    validateGeoTable(queryMysqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryJsonParam() returns @tainted record {}|error? {
    sql:ParameterizedQuery sqlQuery = `SELECT * from JsonTable`;
    validateJsonTableWithoutRequestType(queryMysqlClient(sqlQuery));
}

type JsonResult record {|
    int id;
    json json_type;
|};

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryJsonParam2() returns @tainted record {}|error? {
    sql:ParameterizedQuery sqlQuery = `SELECT * from JsonTable`;
    validateJsonTable(queryMysqlClient(sqlQuery, resultType = JsonResult));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryJsonParam3() returns @tainted record {}|error? {
    int id = 100;
    sql:ParameterizedQuery sqlQuery = `SELECT * from JsonTable where json_type->'$.id'=${id}`;
    validateJsonTable(queryMysqlClient(sqlQuery, resultType = JsonResult));
}

function queryMysqlClient(@untainted string|sql:ParameterizedQuery sqlQuery, typedesc<record {}>? resultType = ())
returns @tainted record {}? {
    Client dbClient = checkpanic new (host, user, password, simpleParamsDb, port);
    stream<record {}, error> streamData = dbClient->query(sqlQuery, resultType);
    record {|record {} value;|}? data = checkpanic streamData.next();
    checkpanic streamData.close();
    record {}? value = data?.value;
    checkpanic dbClient.close();
    return value;
}

isolated function validateDataTableResult(record{}? returnData) {
    decimal decimalVal = 23.45;
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(returnData["row_id"], 1);
        test:assertEquals(returnData["int_type"], 1);
        test:assertEquals(returnData["long_type"], 9223372036854774807);
        test:assertEquals(returnData["double_type"], <float> 2139095039);
        test:assertEquals(returnData["boolean_type"], true);
        test:assertEquals(returnData["decimal_type"], decimalVal);
        test:assertEquals(returnData["string_type"], "Hello");
        test:assertTrue(returnData["float_type"] is float);   
    } 
}

isolated function validateNumericTableResult(record{}? returnData) {
    if (returnData is ()) {
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

isolated function validateComplexTableResult(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 11);
        test:assertEquals(returnData["row_id"], 1);
        test:assertEquals(returnData["text_type"], "very long text");
    }
}

isolated function validateDateTimeTypesTableResult(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 5);
        test:assertEquals(returnData["row_id"], 1);
        test:assertTrue(returnData["date_type"].toString().startsWith("2017-02-03"));
    }
}

isolated function validateEnumTable(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 2);
        test:assertEquals(returnData["id"], 1);
        test:assertEquals(returnData["enum_type"].toString(), "doctor");
    }
}

isolated function validateGeoTable(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 2);
        test:assertEquals(returnData["id"], 1);
        test:assertEquals(returnData["geomText"].toString(), "POINT(7 52)");
    }
}

isolated function validateJsonTable(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 2);
        test:assertEquals(returnData["id"], 1);

        json expected = {
            id: 100,
            name: "Joe",
            groups: [2,5]
        };

        test:assertEquals(returnData["json_type"], expected);
    }
}

isolated function validateJsonTableWithoutRequestType(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Returned data is nil");
    } else {
         test:assertEquals(returnData.length(), 2);
        test:assertEquals(returnData["id"], 1);
        test:assertEquals(returnData["json_type"],"{\"id\": 100, \"name\": \"Joe\", \"groups\": [2, 5]}" );
    }
}
