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

import ballerina/file;
import ballerina/lang.'string as strings;
import ballerina/sql;
import ballerina/test;

int sslPort = 3307;
string sslDB = "SSL_CONNECT_DB";

string clientStorePath = check file:getAbsolutePath("./tests/resources/keystore/client/client-keystore.p12");
string trustStorePath = check file:getAbsolutePath("./tests/resources/keystore/client/client-truststore.p12");

@test:Config {
    groups: ["connection", "ssl"]
}
function testSSLVerifyCert() returns error? {
    Options options = {
        ssl: {
            mode: SSL_VERIFY_CA,
            key: {
                path: clientStorePath,
                password: "password"
            },
            cert: {
                path: trustStorePath,
                password: "password"
            }
        }
    };
    Client dbClient = check new (user = user, password = password, database = sslDB, 
        port = sslPort, options = options);
    test:assertEquals(dbClient.close(), ());
}

@test:Config {
    groups: ["connection", "ssl"]
}
function testSSLPreferred() returns error? {
    Options options = {
        ssl: {
            mode: SSL_PREFERRED,
            key: {
                path: clientStorePath,
                password: "password"
            },
            cert: {
                path: trustStorePath,
                password: "password"
            }
        }
    };
    Client dbClient = check new (user = user, password = password, database = sslDB, 
        port = sslPort, options = options);
    test:assertEquals(dbClient.close(), ());
}

@test:Config {
    groups: ["connection", "ssl"]
}
function testSSLRequiredWithClientCert() returns error? {
    Options options = {
        ssl: {
            mode: SSL_REQUIRED,
            key: {
                path: clientStorePath,
                password: "password"
            }
        }
    };
    Client dbClient = check new (user = user, password = password, database = sslDB, 
        port = sslPort, options = options);
    test:assertEquals(dbClient.close(), ());
}

@test:Config {
    groups: ["connection", "ssl"]
}
function testSSLVerifyIdentity() {
    Options options = {
        ssl: {
            mode: SSL_VERIFY_IDENTITY,
            key: {
                path: clientStorePath,
                password: "password"
            },
            cert: {
                path: trustStorePath,
                password: "password"
            }
        }
    };
    Client|sql:Error dbClient = new (user = user, password = password, database = sslDB, 
        port = sslPort, options = options);
    test:assertTrue(dbClient is error);
    error dbError = <error>dbClient;
    test:assertTrue(strings:includes(dbError.message(), "The certificate Common Name 'MySQL_Server_8.0.29_Auto_Generated_Server_Certificate'" +
    " does not match " + 
    "with 'localhost'."), dbError.message());
}
