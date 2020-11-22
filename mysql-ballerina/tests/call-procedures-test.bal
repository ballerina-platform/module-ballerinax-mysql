// Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/sql;
import ballerina/test;

string proceduresDb = "PROCEDURES_DB";

type StringDataForCall record {
    string varchar_type;
    string charmax_type;
    string char_type;
    string charactermax_type;
    string character_type;
    string nvarcharmax_type;
};

type StringDataSingle record {
    string varchar_type;
};

@test:Config {
    groups: ["procedures"]
}
function testCallWithStringTypes() returns @tainted record {}|error? {
    Client dbClient = checkpanic new (host, user, password, proceduresDb, port);
    sql:ProcedureCallResult ret = checkpanic dbClient->call("{call InsertStringData(2,'test1', 'test2', 'c', 'test3', 'd', 'test4')};");

    string sqlQuery = "SELECT varchar_type, charmax_type, char_type, charactermax_type, character_type," +
                   "nvarcharmax_type from StringTypes where id = 2";

    StringDataForCall expectedDataRow = {
        varchar_type: "test1",
        charmax_type: "test2",
        char_type: "c",
        charactermax_type: "test3",
        character_type: "d",
        nvarcharmax_type: "test4"
    };
    test:assertEquals(queryMySQLClient(dbClient, sqlQuery), expectedDataRow, "Call procedure insert and query did not match.");
}

@test:Config {
    groups: ["procedures"],
    dependsOn: ["testCallWithStringTypes"]
}
function testCallWithStringTypesInParams() {
    Client dbClient = checkpanic new (host, user, password, proceduresDb, port);
    string varcharType = "test1";
    string charmaxType = "test2";
    string charType = "c";
    string charactermaxType = "test3";
    string characterType = "d";
    string nvarcharmaxType = "test4";

    var ret = checkpanic dbClient->call(`{call InsertStringData(3, ${varcharType}, ${charmaxType}, ${charType},
                            ${charactermaxType}, ${characterType}, ${nvarcharmaxType})}`);

    string sqlQuery = "SELECT varchar_type, charmax_type, char_type, charactermax_type, character_type," +
                   "nvarcharmax_type from StringTypes where id = 2";

    StringDataForCall expectedDataRow = {
        varchar_type: "test1",
        charmax_type: "test2",
        char_type: "c",
        charactermax_type: "test3",
        character_type: "d",
        nvarcharmax_type: "test4"
    };
    test:assertEquals(queryMySQLClient(dbClient, sqlQuery), expectedDataRow, "Call procedure insert and query did not match.");
}

@test:Config {
    groups: ["procedures"],
    dependsOn: ["testCallWithStringTypesInParams"]
}
function testCallWithStringTypesReturnsData() {
    Client dbClient = checkpanic new (host, user, password, proceduresDb, port);
    sql:ProcedureCallResult ret = checkpanic dbClient->call("{call SelectStringData()}", [StringDataForCall]);
    stream<record{}, sql:Error>? qResult = ret.queryResult;
    if (qResult is ()) {
        test:assertFail("Empty result set returned.");
    } else {
        record {|record {} value;|}? data = checkpanic qResult.next();
        record {}? value = data?.value;
        StringDataForCall expectedDataRow = {
            varchar_type: "test0",
            charmax_type: "test1",
            char_type: "a",
            charactermax_type: "test2",
            character_type: "b",
            nvarcharmax_type: "test3"
        };        
        test:assertEquals(value, expectedDataRow, "Call procedure insert and query did not match.");
        checkpanic qResult.close();
        checkpanic ret.close();
        
    }
    checkpanic dbClient.close();
}

@test:Config {
    groups: ["procedures"],
    dependsOn: ["testCallWithStringTypesReturnsData"]
}
function testCallWithStringTypesReturnsDataMultiple() {
    Client dbClient = checkpanic new (host, user, password, proceduresDb, port);
    sql:ProcedureCallResult ret = checkpanic dbClient->call("{call SelectStringDataMultiple()}", [StringDataForCall, StringDataSingle]);

    stream<record{}, sql:Error>? qResult = ret.queryResult;
    if (qResult is ()) {
        test:assertFail("First result set is empty.");
    } else {
        record {|record {} value;|}? data = checkpanic qResult.next();
        checkpanic qResult.close();
        record {}? result1 = data?.value;
        StringDataForCall expectedDataRow = {
            varchar_type: "test0",
            charmax_type: "test1",
            char_type: "a",
            charactermax_type: "test2",
            character_type: "b",
            nvarcharmax_type: "test3"
        };        
        test:assertEquals(result1, expectedDataRow, "Call procedure first select did not match.");
    }

    var nextResult = checkpanic ret.getNextQueryResult();
    if (!nextResult) {
        test:assertFail("Only 1 result set returned!.");
    }

    qResult = ret.queryResult;
    if (qResult is ()) {
        test:assertFail("Second result set is empty.");
    } else {
        record {|record {} value;|}? data = checkpanic qResult.next();
        record {}? result2 = data?.value;
        StringDataSingle resultSet2 = {
            varchar_type: "test0"
        };
        test:assertEquals(result2, resultSet2, "Call procedure second select did not match.");
        checkpanic qResult.close();
        checkpanic ret.close();
    }
    checkpanic dbClient.close();
}

@test:Config {
    groups: ["procedures"],
    dependsOn: ["testCallWithStringTypesReturnsDataMultiple"]
}
function testCallWithStringTypesOutParams() {
    Client dbClient = checkpanic new (host, user, password, proceduresDb, port);

    sql:IntegerValue paraID = new(1);
    sql:VarcharOutParameter paraVarchar = new;
    sql:CharOutParameter paraCharmax = new;
    sql:CharOutParameter paraChar = new;
    sql:CharOutParameter paraCharactermax = new;
    sql:CharOutParameter paraCharacter = new;
    sql:NVarcharOutParameter paraNvarcharmax = new;

    sql:ProcedureCallResult ret = checkpanic dbClient->call(
        `{call SelectStringDataWithOutParams(${paraID}, ${paraVarchar}, ${paraCharmax}, ${paraChar}, ${paraCharactermax}, ${paraCharacter}, ${paraNvarcharmax})}`);
    checkpanic ret.close();
    checkpanic dbClient.close();

    test:assertEquals(paraVarchar.get(string), "test0", "2nd out parameter of procedure did not match.");
    test:assertEquals(paraCharmax.get(string), "test1", "3rd out parameter of procedure did not match.");
    test:assertEquals(paraChar.get(string), "a", "4th out parameter of procedure did not match.");
    test:assertEquals(paraCharactermax.get(string), "test2", "5th out parameter of procedure did not match.");
    test:assertEquals(paraCharacter.get(string), "b", "6th out parameter of procedure did not match.");
    test:assertEquals(paraNvarcharmax.get(string), "test3", "7th out parameter of procedure did not match.");
}

@test:Config {
    groups: ["procedures"],
    dependsOn: ["testCallWithStringTypesOutParams"]
}
function testCallWithNumericTypesOutParams() {
    Client dbClient = checkpanic new (host, user, password, proceduresDb, port);

    sql:IntegerValue paraID = new(1);
    sql:IntegerOutParameter paraInt = new;
    sql:BigIntOutParameter paraBigInt = new;
    sql:SmallIntOutParameter paraSmallInt = new;
    sql:SmallIntOutParameter paraTinyInt = new;
    sql:BitOutParameter paraBit = new;
    sql:DecimalOutParameter paraDecimal = new;
    sql:NumericOutParameter paraNumeric = new;
    sql:FloatOutParameter paraFloat = new;
    sql:RealOutParameter paraReal = new;
    sql:DoubleOutParameter paraDouble = new;

    var ret = checkpanic dbClient->call(
        `{call SelectNumericDataWithOutParams(${paraID}, ${paraInt}, ${paraBigInt}, ${paraSmallInt}, ${paraTinyInt}, ${paraBit}, ${paraDecimal}, ${paraNumeric}, ${paraFloat}, ${paraReal}, ${paraDouble})}`);
    checkpanic dbClient.close();

    decimal paraDecimalVal= 1234.56;

    test:assertEquals(paraInt.get(int), 2147483647, "2nd out parameter of procedure did not match.");
    test:assertEquals(paraBigInt.get(int), 9223372036854774807, "3rd out parameter of procedure did not match.");
    test:assertEquals(paraSmallInt.get(int), 32767, "4th out parameter of procedure did not match.");
    test:assertEquals(paraTinyInt.get(int), 127, "5th out parameter of procedure did not match.");
    test:assertEquals(paraBit.get(boolean), true, "6th out parameter of procedure did not match.");
    test:assertEquals(paraDecimal.get(decimal), paraDecimalVal, "7th out parameter of procedure did not match.");
    test:assertEquals(paraNumeric.get(decimal), paraDecimalVal, "8th out parameter of procedure did not match.");
    test:assertTrue((checkpanic paraFloat.get(float)) > 1234.0, "9th out parameter of procedure did not match.");
    test:assertTrue((checkpanic paraReal.get(float)) > 1234.0, "10th out parameter of procedure did not match.");
    test:assertEquals(paraDouble.get(float), 1234.56, "11th out parameter of procedure did not match.");
}

function queryMySQLClient(Client dbClient, @untainted string|sql:ParameterizedQuery sqlQuery)
returns @tainted record {} {
    stream<record{}, error> streamData = dbClient->query(sqlQuery);
    record {|record {} value;|}? data = checkpanic streamData.next();
    checkpanic streamData.close();
    record {}? value = data?.value;
    checkpanic dbClient.close();
    if (value is ()) {
        return {};
    } else {
        return value;
    }
}

