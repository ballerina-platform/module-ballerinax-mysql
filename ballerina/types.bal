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

import ballerina/jballerina.java;
import ballerina/random;
import ballerina/sql;
import ballerinax/cdc;

# The iterator for the stream returned in `query` function to be used to override the default behaviour of `sql:ResultIterator`.
public distinct class CustomResultIterator {
    *sql:CustomResultIterator;

    public isolated function nextResult(sql:ResultIterator iterator) returns record {}|sql:Error? = @java:Method {
        'class: "io.ballerina.stdlib.mysql.utils.MysqlRecordIteratorUtils",
        paramTypes: ["io.ballerina.runtime.api.values.BObject", "io.ballerina.runtime.api.values.BObject"]
    } external;

    public isolated function getNextQueryResult(sql:ProcedureCallResult callResult) returns boolean|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.mysql.utils.ProcedureCallResultUtils",
        paramTypes: ["io.ballerina.runtime.api.values.BObject", "io.ballerina.runtime.api.values.BObject"]
    } external;
}

# Represents the configuration for a MySQL CDC connector.
#
# + database - The MySQL database connection configuration
public type MySqlListenerConfiguration record {|
    MySqlDatabaseConnection database;
    *cdc:ListenerConfiguration;
|};

# Represents the configuration for a MySQL database connection.
#
# + connectorClass - The class name of the MySQL connector implementation to use
# + hostname - The hostname of the MySQL server
# + port - The port number of the MySQL server
# + databaseServerId - The unique identifier for the MySQL server
# + includedDatabases - A list of regular expressions matching fully-qualified database identifiers to capture changes from (should not be used alongside databaseExclude)
# + excludedDatabases - A list of regular expressions matching fully-qualified database identifiers to exclude from change capture (should not be used alongside databaseInclude)
# + tasksMax - The maximum number of tasks to create for this connector. Because the MySQL connector always uses a single task, changing the default value has no effect
# + secure - The connector establishes an encrypted connection if the server supports secure connections
public type MySqlDatabaseConnection record {|
    *cdc:DatabaseConnection;
    string connectorClass = "io.debezium.connector.mysql.MySqlConnector";
    string hostname = "localhost";
    int port = 3306;
    string databaseServerId = (checkpanic random:createIntInRange(0, 100000)).toString();
    string|string[] includedDatabases?;
    string|string[] excludedDatabases?;
    int tasksMax = 1;
    cdc:SecureDatabaseConnection secure = {};
|};
