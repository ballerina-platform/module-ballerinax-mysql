// Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

const string MYSQL_DATABASE_SERVER_ID = "database.server.id";
const string MYSQL_DATABASE_INCLUDE_LIST = "database.include.list";
const string MYSQL_DATABASE_EXCLUDE_LIST = "database.exclude.list";

// Populates MySQL-specific configurations
isolated function populateMySqlConfigurations(MySqlDatabaseConnection connection, map<string> configMap) {
    configMap[MYSQL_DATABASE_SERVER_ID] = connection.databaseServerId.toString();

    string|string[]? includedDatabases = connection.includedDatabases;
    if includedDatabases !is () {
        configMap[MYSQL_DATABASE_INCLUDE_LIST] = includedDatabases is string ? includedDatabases : string:'join(",", ...includedDatabases);
    }

    string|string[]? excludedDatabases = connection.excludedDatabases;
    if excludedDatabases !is () {
        configMap[MYSQL_DATABASE_EXCLUDE_LIST] = excludedDatabases is string ? excludedDatabases : string:'join(",", ...excludedDatabases);
    }
}
