// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/crypto;
import ballerina/jballerina.java;
import ballerina/sql;

# Represents a MySQL database client.
public isolated client class Client {
    *sql:Client;

    # Initializes the MySQL Client. It should be kept open throughout the entirety of the application
    # to perform the operations.
    #
    # + host - Hostname of the MySQL server
    # + user - If the MySQL server is secured, the username
    # + password - The password of the MySQL server for the provided username
    # + database - The name of the database
    # + port - Port number of the MySQL server
    # + options - MySQL database options
    # + connectionPool - The `sql:ConnectionPool` to be used for the connection. If there is no
    #                    `connectionPool` provided, the global connection pool (shared by all clients) will be used
    # + return - An `sql:Error` if the client creation fails
    public isolated function init(string host = "localhost", string? user = "root", string? password = (), string? database = (),
        int port = 3306, Options? options = (), sql:ConnectionPool? connectionPool = ()) returns sql:Error? {
        ClientConfiguration clientConfig = {
            host: host,
            port: port,
            user: user,
            password: password,
            database: database,
            options: options,
            connectionPool: connectionPool
        };
        return createClient(self, clientConfig, sql:getGlobalConnectionPool());
    }

    # Executes the query, which may return multiple results.
    # When processing the stream, make sure to consume all fetched data or close the stream.
    #
    # + sqlQuery - The SQL query such as `` `SELECT * from Album WHERE name=${albumName}` ``
    # + rowType - The `typedesc` of the record to which the result needs to be returned
    # + return - Stream of records in the `rowType` type
    remote isolated function query(sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>)
    returns stream<rowType, sql:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.mysql.nativeimpl.QueryProcessor",
        name: "nativeQuery"
    } external;

    # Executes the query, which is expected to return at most one row of the result.
    # If the query does not return any results, `sql:NoRowsError` is returned.
    #
    # + sqlQuery - The SQL query such as `` `SELECT * from Album WHERE name=${albumName}` ``
    # + returnType - The `typedesc` of the record to which the result needs to be returned.
    #                It can be a basic type if the query result contains only one column
    # + return - Result in the `returnType` type or an `sql:Error`
    remote isolated function queryRow(sql:ParameterizedQuery sqlQuery, typedesc<anydata> returnType = <>)
    returns returnType|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.mysql.nativeimpl.QueryProcessor",
        name: "nativeQueryRow"
    } external;

    # Executes the SQL query. Only the metadata of the execution is returned (not the results from the query).
    #
    # + sqlQuery - The SQL query such as `` `DELETE FROM Album WHERE artist=${artistName}` ``
    # + return - Metadata of the query execution as an `sql:ExecutionResult` or an `sql:Error`
    remote isolated function execute(sql:ParameterizedQuery sqlQuery)
     returns sql:ExecutionResult|sql:Error = @java:Method {
         'class: "io.ballerina.stdlib.mysql.nativeimpl.ExecuteProcessor",
         name: "nativeExecute"
    } external;

    # Executes an SQL query with multiple sets of parameters in a batch. Only the metadata of the execution is returned (not results from the query).
    # If one of the commands in the batch fails (except syntax error), the `sql:BatchExecuteError` will be deferred until the remaining commands are completed.
    #
    # + sqlQueries - The SQL query with multiple sets of parameters
    # + return - Metadata of the query execution as an `sql:ExecutionResult[]` or an `sql:Error`
    remote isolated function batchExecute(sql:ParameterizedQuery[] sqlQueries) returns sql:ExecutionResult[]|sql:Error {
        if sqlQueries.length() == 0 {
            return error sql:ApplicationError(" Parameter 'sqlQueries' cannot be empty array");
        }
        return nativeBatchExecute(self, sqlQueries);
    }

    # Executes an SQL query, which calls a stored procedure. This may or may not return results.
    # Once the results are processed, invoke the `close` method on the `sql:ProcedureCallResult`.
    #
    # + sqlQuery - The SQL query such as `` `CALL sp_GetAlbums();` ``
    # + rowTypes - `typedesc` array of the records to which the results need to be returned
    # + return - Summary of the execution and results are returned in an `sql:ProcedureCallResult`, or an `sql:Error`
    remote isolated function call(sql:ParameterizedCallQuery sqlQuery, typedesc<record {}>[] rowTypes = []) 
    returns sql:ProcedureCallResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.mysql.nativeimpl.CallProcessor",
        name: "nativeCall"
    } external;

    # Closes the MySQL client and shuts down the connection pool. The client must be closed only at the end of the
    # application lifetime (or closed for graceful stops in a service).
    #
    # + return - Possible `sql:Error` when closing the client
    public isolated function close() returns sql:Error? = @java:Method {
        'class: "io.ballerina.stdlib.mysql.nativeimpl.ClientProcessor",
        name: "close"
    } external;
}

# Provides a set of configurations for the MySQL client to be passed internally within the module.
#
# + host - Hostname of the MySQL server
# + port - Port number of the MySQL server
# + user - If the MySQL server is secured, the username
# + password - The password of the MySQL server for the provided username
# + database - The name of the database
# + options - MySQL datasource options of `mysql:Options` type to be configured
# + connectionPool - Properties of the `sql:ConnectionPool` for the connection pool configuration
type ClientConfiguration record {|
    string host;
    int port;
    string? user;
    string? password;
    string? database;
    Options? options;
    sql:ConnectionPool? connectionPool;
|};

# Provides a set of additional configurations related to the MySQL database connection.
#
# + ssl - SSL configurations to be used
# + failoverConfig - Server failover configurations to be used
# + useXADatasource - Flag to enable or disable XADatasource
# + connectTimeout - Timeout (in seconds) to be used when establishing a connection to the MySQL server
# + socketTimeout - Socket timeout (in seconds) to be used during the read/write operations with the MySQL server
#                   (0 means no socket timeout)
# + serverTimezone - Configures the connection time zone, which is used by the `Connector/J` if the conversion between a Ballerina
#                    application and a target time zone is required when preserving instant temporal values
# + noAccessToProcedureBodies - With this option the user is allowed to invoke procedures with access to metadata restricted
public type Options record {|
    SecureSocket ssl?;
    FailoverConfig failoverConfig?;
    boolean useXADatasource = false;
    decimal connectTimeout = 30;
    decimal socketTimeout = 0;
    string serverTimezone?;
    boolean noAccessToProcedureBodies = false;
|};

# Configuration to be used for server failover.
#
# + failoverServers - Array of `mysql:FailoverServer` for the secondary servers
# + timeBeforeRetry - Time the driver waits before attempting to fall back to the primary host
# + queriesBeforeRetry - Number of queries that are executed before the driver attempts to fall back to the primary host
# + failoverReadOnly - Open connection to secondary host with READ ONLY mode.
public type FailoverConfig record {|
    FailoverServer[] failoverServers;
    int timeBeforeRetry?;
    int queriesBeforeRetry?;
    boolean failoverReadOnly = true;
|};

# Configuration for failover servers
#
# + host - Hostname of the secondary server
# + port - Port of the secondary server
public type FailoverServer record {|
    string host;
    int port;
|};

# Establish an encrypted connection if the server supports encrypted connections. Falls back to an unencrypted
# connection if an encrypted connection cannot be established.
public const SSL_PREFERRED = "PREFERRED";

# Establish an encrypted connection if the server supports encrypted connections. The connection attempt fails if
# an encrypted connection cannot be established.
public const SSL_REQUIRED = "REQUIRED";

# Establish an encrypted connection if the server supports encrypted connections. The connection attempt fails if
# an encrypted connection cannot be established. Additionally, verifies the server Certificate Authority (CA)
# certificate against the configured CA certificates. The connection attempt fails if no valid matching CA
# certificates are found.
public const SSL_VERIFY_CA = "VERIFY_CA";

# Establish an encrypted connection if the server supports encrypted connections and verifies the server
# Certificate Authority (CA) certificate against the configured CA certificates. The connection attempt fails if an
# encrypted connection cannot be established or no valid matching CA certificates are found. Also, performs hostname
# identity verification by checking the hostname the client uses for connecting to the server against the identity
# in the certificate that the server sends to the client.
public const SSL_VERIFY_IDENTITY = "VERIFY_IDENTITY";

# `SSLMode` as a union of available SSL modes.
public type SSLMode SSL_PREFERRED|SSL_REQUIRED|SSL_VERIFY_CA|SSL_VERIFY_IDENTITY;

# SSL Configuration to be used when connecting to the MySQL server.
#
# + mode - `mysql:SSLMode` to be used during the connection
# + key - Keystore configuration of the client certificates
# + cert - Keystore configuration of the trust certificates
# + allowPublicKeyRetrieval - Boolean value to allow special handshake round-trip to get an RSA public key directly
#                             from server
public type SecureSocket record {|
    SSLMode mode = SSL_PREFERRED;
    crypto:KeyStore key?;
    crypto:TrustStore cert?;
    boolean allowPublicKeyRetrieval = false;
|};

isolated function createClient(Client mysqlClient, ClientConfiguration clientConf, 
    sql:ConnectionPool globalConnPool) returns sql:Error? = @java:Method {
    'class: "io.ballerina.stdlib.mysql.nativeimpl.ClientProcessor"
} external;

isolated function nativeBatchExecute(Client sqlClient, sql:ParameterizedQuery[] sqlQueries) 
returns sql:ExecutionResult[]|sql:Error = @java:Method {
    'class: "io.ballerina.stdlib.mysql.nativeimpl.ExecuteProcessor"
} external;
