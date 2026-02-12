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

# Represents the Ballerina MySQL CDC Listener.
public isolated class CdcListener {
    *cdc:Listener;

    private final map<anydata> & readonly config;
    private boolean isStarted = false;
    private boolean hasAttachedService = false;

    # Initializes the MySQL listener with the given configuration.
    #
    # + config - The configuration for the MySQL connector
    public isolated function init(*MySqlListenerConfiguration config) {
        map<string> debeziumConfigs = {};
        cdc:populateDebeziumProperties({
                                           engineName: config.engineName,
                                           offsetStorage: config.offsetStorage,
                                           internalSchemaStorage: config.internalSchemaStorage,
                                       }, debeziumConfigs);
        cdc:populateDatabaseConfigurations({
                                               connectorClass: config.database.connectorClass,
                                               hostname: config.database.hostname,
                                               port: config.database.port,
                                               username: config.database.username,
                                               password: config.database.password,
                                               connectTimeout: config.database.connectTimeout,
                                               tasksMax: config.database.tasksMax,
                                               secure: config.database.secure,
                                               includedTables: config.database.includedTables,
                                               excludedTables: config.database.excludedTables,
                                               includedColumns: config.database.includedColumns,
                                               excludedColumns: config.database.excludedColumns
                                           }, debeziumConfigs);
        populateMySqlConfigurations(config.database, debeziumConfigs);
        populateMySqlOptions(config.options, debeziumConfigs);
        map<anydata> listenerConfigs = {
            ...debeziumConfigs
        };
        listenerConfigs["livenessInterval"] = config.livenessInterval;
        self.config = listenerConfigs.cloneReadOnly();
    }

    # Attaches a CDC service to the MySQL listener.
    #
    # + s - The CDC service to attach
    # + name - Attachment points
    # + return - An error if the service cannot be attached, or `()` if successful
    public isolated function attach(cdc:Service s, string[]|string? name = ()) returns cdc:Error? {
        check cdc:externAttach(self, s);
    }

    # Starts the MySQL listener.
    #
    # + return - An error if the listener cannot be started, or `()` if successful
    public isolated function 'start() returns cdc:Error? {
        check cdc:externStart(self, self.config);
    }

    # Detaches a CDC service from the MySQL listener.
    #
    # + s - The CDC service to detach
    # + return - An error if the service cannot be detached, or `()` if successful
    public isolated function detach(cdc:Service s) returns cdc:Error? {
        check cdc:externDetach(self, s);
    }

    # Stops the MySQL listener gracefully.
    #
    # + return - An error if the listener cannot be stopped, or `()` if successful
    public isolated function gracefulStop() returns cdc:Error? {
        check cdc:externGracefulStop(self);
    }

    # Stops the MySQL listener immediately.
    #
    # + return - An error if the listener cannot be stopped, or `()` if successful
    public isolated function immediateStop() returns cdc:Error? {
        check cdc:externImmediateStop(self);
    }
}
