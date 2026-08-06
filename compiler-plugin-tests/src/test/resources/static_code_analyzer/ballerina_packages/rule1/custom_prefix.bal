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

import ballerinax/mysql as m;

configurable string host = ?;
configurable string user = ?;
configurable int port = ?;
configurable string database = ?;

// Case 1: Custom prefix 'm' with Named Argument (Empty string)
public isolated function customPrefixNamed() {
    m:Client|error dbClient = new (
        host = host,
        user = user,
        password = "",
        database = database
    );
}

// Case 2: Custom prefix 'm' with Positional Arguments
// This proves that even with an alias, the 3rd index is correctly identified
public isolated function customPrefixPositional() {
    m:Client|error dbClient = new (host, user, "admin123", database);
}

// Case 3: Using 'check' with the custom prefix
// This ensures Semantic API resolves the type during a check expression
public isolated function customPrefixCheck() returns error? {
    m:Client dbClient = check new (host, user, "password", database);
}

// Case 4: Multiple initializations in one function with custom prefix
public isolated function multipleInit() {
    m:Client|error db1 = new (host, user, "", database);
    m:Client|error db2 = new (host = host, user = user, password = "123");
}
