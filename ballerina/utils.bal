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

import ballerinax/cdc;

const string MYSQL_DATABASE_SERVER_ID = "database.server.id";
const string MYSQL_DATABASE_INCLUDE_LIST = "database.include.list";
const string MYSQL_DATABASE_EXCLUDE_LIST = "database.exclude.list";
const string SNAPSHOT_LOCK_TIMEOUT_MS = "snapshot.lock.timeout.ms";
const string INCLUDE_SCHEMA_CHANGES = "include.schema.changes";

// GTID Replication properties
const string GTID_SOURCE_INCLUDES = "gtid.source.includes";
const string GTID_SOURCE_EXCLUDES = "gtid.source.excludes";
const string GTID_NEW_CHANNEL_POSITION = "gtid.new.channel.position";

// Binlog properties
const string BINLOG_BUFFER_SIZE = "binlog.buffer.size";

// Data type properties
const string BIGINT_UNSIGNED_HANDLING_MODE = "bigint.unsigned.handling.mode";
const string ENABLE_TIME_ADJUSTER = "enable.time.adjuster";

// Snapshot properties
const string SNAPSHOT_LOCKING_MODE = "snapshot.locking.mode";
const string SNAPSHOT_NEW_TABLES = "snapshot.new.tables";

// Populates MySQL GTID replication configuration
isolated function populateReplicationConfiguration(ReplicationConfiguration config, map<string> configMap) {
    string|string[]? gtidSourceIncludes = config.gtidSourceIncludes;
    if gtidSourceIncludes !is () {
        configMap[GTID_SOURCE_INCLUDES] = gtidSourceIncludes is string ? gtidSourceIncludes : string:'join(",", ...gtidSourceIncludes);
    }

    string|string[]? gtidSourceExcludes = config.gtidSourceExcludes;
    if gtidSourceExcludes !is () {
        configMap[GTID_SOURCE_EXCLUDES] = gtidSourceExcludes is string ? gtidSourceExcludes : string:'join(",", ...gtidSourceExcludes);
    }

    GtidNewChannelPosition? gtidNewChannelPosition = config.gtidNewChannelPosition;
    if gtidNewChannelPosition !is () {
        configMap[GTID_NEW_CHANNEL_POSITION] = gtidNewChannelPosition;
    }
}

// Populates MySQL binlog configuration
isolated function populateBinlogConfiguration(BinlogConfiguration config, map<string> configMap) {
    configMap[BINLOG_BUFFER_SIZE] = config.bufferSize.toString();
}

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

    // Populate MySQL replication configuration
    ReplicationConfiguration? replicationConfig = connection.replicationConfig;
    if replicationConfig is ReplicationConfiguration {
        populateReplicationConfiguration(replicationConfig, configMap);
    }

    // Populate MySQL binlog configuration
    BinlogConfiguration? binlogConfig = connection.binlogConfig;
    if binlogConfig is BinlogConfiguration {
        populateBinlogConfiguration(binlogConfig, configMap);
    }
}

// Populates MySQL-specific data type configuration
isolated function populateDataTypeConfiguration(DataTypeConfiguration config, map<string> configMap) {
    // Populate generic data type options
    cdc:populateDataTypeConfiguration(config, configMap);

    // Populate MySQL-specific data type options
    configMap[BIGINT_UNSIGNED_HANDLING_MODE] = config.bigIntUnsignedHandlingMode;
    configMap[ENABLE_TIME_ADJUSTER] = config.enableTimeAdjuster.toString();
    configMap[INCLUDE_SCHEMA_CHANGES] = config.includeSchemaChanges.toString();
}

// Populates MySQL-specific options
isolated function populateMySqlOptions(MySqlOptions options, map<string> configMap) {
    // Populate common options from cdc module
    cdc:populateOptions(options, configMap);

    // Populate MySQL-specific extended snapshot configuration
    ExtendedSnapshotConfiguration? extendedSnapshot = options.extendedSnapshot;
    if extendedSnapshot is ExtendedSnapshotConfiguration {
        cdc:populateRelationalExtendedSnapshotConfiguration(extendedSnapshot, configMap);
        populateMySqlExtendedSnapshotConfiguration(extendedSnapshot, configMap);
    }

    // Populate MySQL-specific data type configuration
    DataTypeConfiguration? dataTypeConfig = options.dataTypeConfig;
    if dataTypeConfig is DataTypeConfiguration {
        populateDataTypeConfiguration(dataTypeConfig, configMap);
    }
}

// Populates MySQL-specific extended snapshot properties
isolated function populateMySqlExtendedSnapshotConfiguration(ExtendedSnapshotConfiguration config, map<string> configMap) {
    configMap[SNAPSHOT_LOCK_TIMEOUT_MS] = getMillisecondValueOf(config.lockTimeout);

    cdc:SnapshotLockingMode? lockingMode = config.lockingMode;
    if lockingMode !is () {
        configMap[SNAPSHOT_LOCKING_MODE] = lockingMode;
    }

    configMap[SNAPSHOT_NEW_TABLES] = config.newTables;
}

isolated function getMillisecondValueOf(decimal value) returns string {
    string milliSecondVal = (value * 1000).toBalString();
    return milliSecondVal.substring(0, milliSecondVal.indexOf(".") ?: milliSecondVal.length());
}
