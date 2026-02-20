// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.org)
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

import ballerinax/mysql;

configurable string host = ?;
configurable string user = ?;
configurable int port = ?;
configurable string database = ?;

// Case 1: Original Named Argument (Empty string)
public isolated function namedArgEmpty() {
    mysql:Client|error dbClient = new (
        host = host,
        user = user,
        password = "",
        database = database,
        port = port
    );
}

// Case 2: Named Argument at the end (Out of order)
// This proves logic iterates through all arguments to find "password"
public isolated function namedArgLast() {
    mysql:Client|error dbClient = new (
        host = host,
        user = user,
        database = database,
        password = "admin"
    );
}

// Case 3: Mixed Case/Weak Password using 'check'
// This verifies that the strength validator flags "password123"
public isolated function namedArgCheck() returns error? {
    mysql:Client dbClient = check new (
        password = "password123",
        host = host,
        user = user
    );
}

// Case 4: Named Argument with Secure Password (Should NOT be flagged)
// Ensures valid passwords aren't accidentally caught
public isolated function namedArgSecure() {
    mysql:Client|error dbClient = new (
        host = host,
        password = "Secure#Password@2026",
        user = user
    );
}
