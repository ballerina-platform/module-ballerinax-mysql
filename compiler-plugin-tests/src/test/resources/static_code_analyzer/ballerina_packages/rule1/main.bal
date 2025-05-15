// Copyright (c) 2025 WSO2 LLC. (http://www.wso2.org)
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
import ballerina/io;

configurable string user = ?;
configurable string host = ?;
configurable int port = ?;
configurable string database = ?;

public function main() {
    mysql:Client|error dbClient = new (host = host,
        user = user,
        password = "",
        port = port,
        database = database
    );
    io:println("Result 1: ", dbClient);
}
