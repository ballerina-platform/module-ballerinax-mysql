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

string sslDB = "SSL_CONNECT_DB";

string clientStorePath = checkpanic file:getAbsolutePath("./tests/resources/keystore/client/client-keystore.p12");
string turstStorePath = checkpanic file:getAbsolutePath("./tests/resources/keystore/client/trust-keystore.p12");

@test:Config {
    groups: ["connection","ssl"]
}
function testSSLVerifyCert() {
    Options options = {
        ssl: {
            mode: SSL_VERIFY_CERT,
            clientCertKeystore: {
                path: clientStorePath,
                password: "changeit"
            },
            trustCertKeystore: {
                path: turstStorePath,
                password: "changeit"
            }
        }
    };
    Client dbClient = checkpanic new (user = user, password = password, database = sslDB,
        port = port, options = options);
    test:assertEquals(dbClient.close(), ());
}

@test:Config {
    groups: ["connection","ssl"]
}
function testSSLPreferred() {
    Options options = {
        ssl: {
            mode:  SSL_PREFERRED,
            clientCertKeystore: {
                path: clientStorePath,
                password: "changeit"
            },
            trustCertKeystore: {
                path: turstStorePath,
                password: "changeit"
            }
        }
    };
    Client dbClient = checkpanic new (user = user, password = password, database = sslDB,
        port = port, options = options);
    test:assertEquals(dbClient.close(), ());
}

@test:Config {
    groups: ["connection","ssl"]
}
function testSSLRequiredWithClientCert() {
    Options options = {
        ssl: {
            mode:  SSL_REQUIRED,
            clientCertKeystore: {
                path: clientStorePath,
                password: "changeit"
            }
        }
    };
    Client dbClient = checkpanic new (user = user, password = password, database = sslDB,
        port = port, options = options);
    test:assertEquals(dbClient.close(), ());
}

@test:Config {
    groups: ["connection","ssl"]
}
function testSSLVerifyIdentity() {
    Options options = {
        ssl: {
            mode:  SSL_VERIFY_IDENTITY,
            clientCertKeystore: {
                path: clientStorePath,
                password: "changeit"
            },
            trustCertKeystore: {
                path: turstStorePath,
                password: "changeit"
            }
        }
    };
    Client|sql:Error dbClient = new (user = user, password = password, database = sslDB,
        port = port, options = options);
    test:assertTrue(dbClient is error);
    error dbError = <error> dbClient;
    test:assertTrue(strings:includes(dbError.message(),  "The certificate Common Name 'Server' does not match " +
    "with 'localhost'."), dbError.message());
}
