// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/http;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;

configurable string host = ?;
configurable string username = ?;
configurable string password = ?;
configurable int port = ?;

final string name = "Bella";
final string category = "Cat";
final int price = 3000;

final mysql:Client dbClient = check new (host = host, user = username, password = password, port = port);

isolated service /db on new http:Listener(9092) {
    resource isolated function post .(http:Caller caller) returns error? {
        sql:ParameterizedQuery query = `INSERT INTO petdb.pet (Name, Category, Price)
        VALUES (${name}, ${category}, ${price})`;
        sql:ExecutionResult|error result = dbClient->execute(query);
        http:Response response = new;
        if result is error {
            response.statusCode = 500;
            response.setPayload(result.toString());
        } else {
            response.statusCode = 200;
            response.setPayload("Records inserted succesfully");
        }
        _ = check caller->respond(response);
    }
}