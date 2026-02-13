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

# Represents GTID channel position modes.
#
# + EARLIEST - Start from the earliest available GTID position
# + LATEST - Start from the latest GTID position
public enum GtidNewChannelPosition {
    EARLIEST = "earliest",
    LATEST = "latest"
}

# Represents BIGINT UNSIGNED handling modes.
#
# + LONG - Represent BIGINT UNSIGNED as long (may lose precision for values > Long.MAX_VALUE)
# + PRECISE - Represent BIGINT UNSIGNED precisely using java.math.BigDecimal
public enum BigIntUnsignedHandlingMode {
    LONG = "long",
    PRECISE = "precise"
}

# Represents snapshot new tables modes.
#
# + OFF - Do not snapshot newly added tables
# + PARALLEL - Snapshot newly added tables in parallel with ongoing streaming
public enum SnapshotNewTables {
    OFF = "off",
    PARALLEL = "parallel"
}

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

# MySQL GTID-based replication configuration.
#
# + gtidSourceIncludes - Comma-separated list of GTID source UUIDs to include
# + gtidSourceExcludes - Comma-separated list of GTID source UUIDs to exclude
# + gtidNewChannelPosition - Position for new GTID channels (earliest or latest)
public type ReplicationConfiguration record {|
    string|string[] gtidSourceIncludes?;
    string|string[] gtidSourceExcludes?;
    GtidNewChannelPosition gtidNewChannelPosition?;
|};

# MySQL binlog configuration.
#
# + bufferSize - Size of binlog buffer in bytes
public type BinlogConfiguration record {|
    int bufferSize = 8192;
|};

# MySQL CDC listener configuration including database connection, storage, and CDC options.
#
# + database - MySQL database connection and capture settings
# + options - MySQL-specific CDC options including snapshot, heartbeat, signals, and data type handling
public type MySqlListenerConfiguration record {|
    MySqlDatabaseConnection database;
    *cdc:ListenerConfiguration;
    MySqlOptions options = {};
|};

# Represents the configuration for the MySQL CDC database connection.
#
# + connectorClass - The class name of the MySQL connector implementation to use
# + hostname - The hostname of the MySQL server
# + port - The port number of the MySQL server
# + databaseServerId - The unique identifier for the MySQL server
# + includedDatabases - A list of regular expressions matching fully-qualified database identifiers to capture changes from (should not be used alongside databaseExclude)
# + excludedDatabases - A list of regular expressions matching fully-qualified database identifiers to exclude from change capture (should not be used alongside databaseInclude)
# + tasksMax - The maximum number of tasks to create for this connector. Because the MySQL connector always uses a single task, changing the default value has no effect
# + secure - The connector establishes an encrypted connection if the server supports secure connections
# + replicationConfig - MySQL GTID-based replication configuration
# + binlogConfig - MySQL binlog configuration
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
    ReplicationConfiguration replicationConfig?;
    BinlogConfiguration binlogConfig?;
|};

# MySQL-specific CDC options for configuring snapshot behavior and data type handling.
#
# + extendedSnapshot - Extended snapshot configuration with MySQL-specific lock timeout and query settings
# + dataTypeConfig - Data type handling configuration including schema change tracking
public type MySqlOptions record {|
    *cdc:Options;
    ExtendedSnapshotConfiguration extendedSnapshot?;
    DataTypeConfiguration dataTypeConfig?;
|};

# MySQL-specific extended snapshot configuration.
# Extends generic relational snapshot configuration with MySQL-specific options.
#
# + lockTimeout - Lock acquisition timeout in seconds
# + lockingMode - MySQL-specific locking mode during snapshots
# + newTables - How to snapshot newly added tables (off or parallel)
public type ExtendedSnapshotConfiguration record {|
    *cdc:RelationalExtendedSnapshotConfiguration;
    decimal lockTimeout = 10;
    cdc:SnapshotLockingMode lockingMode?;
    SnapshotNewTables newTables = OFF;
|};

# MySQL-specific data type handling configuration.
# Extends generic data type configuration with MySQL-specific type handling.
#
# + bigIntUnsignedHandlingMode - How to handle BIGINT UNSIGNED values (long or precise)
# + enableTimeAdjuster - Enable time adjuster for MySQL temporal types
# + includeSchemaChanges - Whether to include schema change events (MySQL supports this)
public type DataTypeConfiguration record {|
    *cdc:DataTypeConfiguration;
    BigIntUnsignedHandlingMode bigIntUnsignedHandlingMode = LONG;
    boolean enableTimeAdjuster = true;
    boolean includeSchemaChanges = true;
|};
