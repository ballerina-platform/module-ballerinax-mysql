// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerinax/mysql;

mysql:Client dbClient = check new mysql:Client("url", (), (), (), 120, { connectTimeout: -1 }, { maxOpenConnections: -1 });

public function main() returns error? {

    mysql:Client dbClient1 = check new("url", connectionPool = { maxOpenConnections: -1 });
    check dbClient1.close();

    mysql:Client dbClient2 = check new("url", options = { connectTimeout: -1 });
    check dbClient2.close();

    mysql:Client dbClient3 = check new("url", (), (), (), 120, { connectTimeout: -1 });
    check dbClient3.close();
}
