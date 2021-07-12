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

string connectDB = "CONNECT_DB";

@test:Config {
    groups: ["connection", "connection-init"]
}
isolated function testConnectionWithNoFields() {
    Client|sql:Error dbClient = new ();
    test:assertTrue(dbClient is sql:Error, "Initialising connection with no fields should fail.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithURLParams() {
    Client dbClient = checkpanic new (host, user, password, connectDB, port);
    var exitCode = dbClient.close();
    test:assertExactEquals(exitCode, (), "Initialising connection with params fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithoutHost() {
    Client dbClient = checkpanic new (user = user, password = password, database = connectDB, port = port);
    var exitCode = dbClient.close();
    test:assertExactEquals(exitCode, (), "Initialising connection without host fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithOptions() {
    Options options = {
        connectTimeout: 60
    };
    Client dbClient = checkpanic new (user = user, password = password, database = connectDB,
        port = port, options = options);
    var exitCode = dbClient.close();
    test:assertExactEquals(exitCode, (), "Initialising connection with options fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithConnectionPool() {
    sql:ConnectionPool connectionPool = {
        maxOpenConnections: 25
    };
    Client dbClient = checkpanic new (user = user, password = password, database = connectDB,
        port = port, connectionPool = connectionPool);
    var exitCode = dbClient.close();
    test:assertExactEquals(exitCode, (), "Initialising connection with option max connection pool fails.");
    test:assertEquals(connectionPool.maxOpenConnections, 25, "Configured max connection config is wrong.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithConnectionParams() {
    sql:ConnectionPool connectionPool = {
        maxOpenConnections: 25
    };
    Options options = {
        connectTimeout: 60
    };
    Client dbClient = checkpanic new (host, user, password, connectDB, port, options, connectionPool);
    var exitCode = dbClient.close();
    test:assertExactEquals(exitCode, (), "Initialising connection with connection params fails.");
}
