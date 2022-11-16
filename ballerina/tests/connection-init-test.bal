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
import ballerina/lang.'string as strings;

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
function testWithURLParams() returns error? {
    Client dbClient = check new (host, user, password, connectDB, port);
    error? exitCode = dbClient.close();
    test:assertExactEquals(exitCode, (), "Initialising connection with params fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithoutHost() returns error? {
    Client dbClient = check new (user = user, password = password, database = connectDB, port = port);
    error? exitCode = dbClient.close();
    test:assertExactEquals(exitCode, (), "Initialising connection without host fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithoutUser() returns error? {
    Client dbClient = check new(host = host, port = port, password = password, database = connectDB);
    sql:Error? closeResult = dbClient.close();
    test:assertExactEquals(closeResult, (), "Initialising connection without user fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithOptions() returns error? {
    Options options = {
        connectTimeout: 60
    };
    Client dbClient = check new (user = user, password = password, database = connectDB, 
        port = port, options = options);
    error? exitCode = dbClient.close();
    test:assertExactEquals(exitCode, (), "Initialising connection with options fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithConnectionPool() returns error? {
    sql:ConnectionPool connectionPool = {
        maxOpenConnections: 25
    };
    Client dbClient = check new (user = user, password = password, database = connectDB, 
        port = port, connectionPool = connectionPool);
    error? exitCode = dbClient.close();
    test:assertExactEquals(exitCode, (), "Initialising connection with option max connection pool fails.");
    test:assertEquals(connectionPool.maxOpenConnections, 25, "Configured max connection config is wrong.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithConnectionParams() returns error? {
    sql:ConnectionPool connectionPool = {
        maxOpenConnections: 25
    };
    Options options = {
        connectTimeout: 60
    };
    Client dbClient = check new (host, user, password, connectDB, port, options, connectionPool);
    error? exitCode = dbClient.close();
    test:assertExactEquals(exitCode, (), "Initialising connection with connection params fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testConnectionPoolLimitClient() returns error? {
    sql:ConnectionPool connectionPool = {
        maxOpenConnections: 3
    };
    Options options = {
        connectTimeout: 5
    };
    Client dbClient = check new (host, user, password, connectDB, port, options, connectionPool);
    //Client dbClient2 = check new (host, user, password, connectDB, port, options, connectionPool);

    stream<record {}, error?> streamData = check dbClient->query(`SELECT * FROM Customers`);
    stream<record {}, error?> streamData2 = check dbClient->query(`SELECT * FROM Customers`);
    stream<record {}, error?> streamData3 = check dbClient->query(`SELECT * FROM Customers`);

    record {|record {} value;|}? data = check streamData.next();
    record {|record {} value;|}? data2 = check streamData2.next();
    record {|record {} value;|}|error? data3 = check streamData3.next();

    if data3 is error {
        test:assertTrue(data3.message().indexOf("Connection is not available, request timed out after") != -1);
    } else {
        test:assertFail("Error expected.");
    }

    _ = check streamData.close();
    _ = check streamData2.close();
    _ = check streamData3.close();
    _ = check dbClient.close();
    //_ = check dbClient2.close();
}

@test:Config {
    groups: ["connection", "connection-init2"]
}
function testConnectionServerRejection() returns error? {
    Client dbClient = check new (host, user, password, connectDB, port);
    _ = check dbClient->execute(`SET GLOBAL max_connections = 2`);

    Client dbClient2 = check new (host, user, password, connectDB, port);
    Client dbClient3 = check new (host, user, password, connectDB, port);
    Client dbClient4 = check new (host, user, password, connectDB, port);

    stream<record {}, error?> streamData = dbClient->query(`SELECT * FROM Customers`);
    stream<record {}, error?> streamData2 = dbClient2->query(`SELECT * FROM Customers`);
    stream<record {}, error?> streamData3 = dbClient3->query(`SELECT * FROM Customers`);
    stream<record {}, error?> streamData4 = dbClient4->query(`SELECT * FROM Customers`);

    record {|record {} value;|}? data = check streamData.next();
    record {|record {} value;|}? data2 = check streamData2.next();
    record {|record {} value;|}? data3 = check streamData3.next();
    record {|record {} value;|}|error? data4 = streamData4.next();

    if data4 is error {
        test:assertTrue(strings:includes(data4.message(), "Data source rejected establishment of connection."), data4.message());
    } else {
        test:assertFail("Error expected.");
    }

    _ = check streamData.close();
    _ = check streamData2.close();
    _ = check streamData3.close();
    _ = check streamData4.close();

    _ = check dbClient->execute(`SET GLOBAL max_connections = 200`);

    _ = check dbClient.close();
    _ = check dbClient2.close();
    _ = check dbClient3.close();
    _ = check dbClient4.close();
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testServerFailover() returns error? {
    Options options = {
        failoverConfig: {
            failoverServers: [
                {
                host: "localhost",
                port: 5506
            }, 
                {
                host: "localhost",
                port: 3305
            }
            ],
            timeBeforeRetry: 10,
            queriesBeforeRetry: 10,
            failoverReadOnly: false
        }
    };
    Client dbClient = check new (host, user, password, connectDB, port, options);
    error? exitCode = dbClient.close();
    test:assertExactEquals(exitCode, (), "Initialising connection with server failover params fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testServerFailoverFailure() returns error? {
    Options options = {
        failoverConfig: {
            failoverServers: []
        }
    };
    Client|sql:Error applicationError = new (host, user, password, connectDB, port, options);
    if applicationError is sql:Error {
        test:assertEquals(applicationError.message(), "FailoverConfig's 'failoverServers' field cannot be an empty array.");
    } else {
        test:assertFail("Initialising connection with server failover params failure expected.");
    }
}
