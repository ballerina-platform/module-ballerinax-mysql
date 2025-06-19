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

# MySQL database client that enables interaction with MySQL servers and supports standard SQL operations.
public isolated client class Client {
    *sql:Client;

    # Connects to a MySQL database with the specified configuration.
    #
    # + host - MySQL server hostname
    # + user - Database username
    # + password - Database password (optional)
    # + database - Database name to connect to (optional)
    # + port - MySQL server port
    # + options - Advanced connection options (optional)
    # + connectionPool - Connection pool for connection reuse. If not provided, the global connection pool (shared by all clients) will be used
    # + return - `sql:Error` if the client creation fails
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

    # Executes a SQL query and returns multiple results as a stream.
    #
    # + sqlQuery - SQL query with optional parameters (e.g., `SELECT * FROM users WHERE id=${userId}`)
    # + rowType - Record type to map query results to
    # + return - Stream of records matching the query
    remote isolated function query(sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>)
    returns stream<rowType, sql:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.mysql.nativeimpl.QueryProcessor",
        name: "nativeQuery"
    } external;

    # Executes a SQL query expecting a single result row.
    # If the query returns no results, `sql:NoRowsError` is returned.
    #
    # + sqlQuery - The SQL query (e.g., `` `SELECT * FROM Album WHERE name=${albumName}` ``)
    # + returnType - The `typedesc` of the record to which the result should be mapped.
    #                It can be a basic type if the query result contains only one column
    # + return - Result in the `returnType` type or an `sql:Error`
    remote isolated function queryRow(sql:ParameterizedQuery sqlQuery, typedesc<anydata> returnType = <>)
    returns returnType|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.mysql.nativeimpl.QueryProcessor",
        name: "nativeQueryRow"
    } external;

    # Executes a SQL query and returns execution metadata (not the actual query results).
    #
    # + sqlQuery - SQL query with parameters (e.g., `` `DELETE FROM Album WHERE artist=${artistName}` ``)
    # + return - Execution metadata as an `sql:ExecutionResult`, or an `sql:Error` if execution fails
    remote isolated function execute(sql:ParameterizedQuery sqlQuery)
     returns sql:ExecutionResult|sql:Error = @java:Method {
         'class: "io.ballerina.stdlib.mysql.nativeimpl.ExecuteProcessor",
         name: "nativeExecute"
    } external;

    # Executes multiple SQL commands in a single batch operation.
    #
    # + sqlQueries - Array of SQL queries with parameters
    # + return - Array of execution results or an `sql:Error` if the operation fails
    remote isolated function batchExecute(sql:ParameterizedQuery[] sqlQueries) returns sql:ExecutionResult[]|sql:Error {
        if sqlQueries.length() == 0 {
            return error sql:ApplicationError(" Parameter 'sqlQueries' cannot be empty array");
        }
        return nativeBatchExecute(self, sqlQueries);
    }

    # Calls a stored procedure with the given SQL query.
    # Once the results are processed, invoke the `close` method on the `sql:ProcedureCallResult`.
    #
    # + sqlQuery - SQL query to call the procedure (e.g., `` `CALL get_user(${id})` ``)
    # + rowTypes - `typedesc` array of the records to which the results should be mapped
    # + return - Summary of the execution and results as `sql:ProcedureCallResult`, or an `sql:Error` if the call fails
    remote isolated function call(sql:ParameterizedCallQuery sqlQuery, typedesc<record {}>[] rowTypes = [])
    returns sql:ProcedureCallResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.mysql.nativeimpl.CallProcessor",
        name: "nativeCall"
    } external;

    # Closes the MySQL client and shuts down the connection pool.
    # The client should be closed only at the end of the application lifetime, or when performing graceful stops in a service.
    #
    # + return - `sql:Error` if closing the client fails
    public isolated function close() returns sql:Error? = @java:Method {
        'class: "io.ballerina.stdlib.mysql.nativeimpl.ClientProcessor",
        name: "close"
    } external;
}

# MySQL client connection configuration.
#
# + host - MySQL server hostname
# + port - MySQL server port
# + user - Database username
# + password - Database password
# + database - Database name
# + options - Advanced connection options
# + connectionPool - Connection pool configuration
type ClientConfiguration record {|
    string host;
    int port;
    string? user;
    string? password;
    string? database;
    Options? options;
    sql:ConnectionPool? connectionPool;
|};

# Advanced MySQL connection options.
#
# + ssl - SSL/TLS security settings
# + failoverConfig - Server failover configuration
# + useXADatasource - Enable XA transactions
# + connectTimeout - Connection timeout in seconds
# + socketTimeout - Socket read/write timeout in seconds (0 means no timeout)
# + serverTimezone - Server timezone configuration for handling temporal values
# + noAccessToProcedureBodies - Allow procedure calls when metadata access is limited
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
# + failoverServers - Array of `mysql:FailoverServer` configurations for secondary servers
# + timeBeforeRetry - Time to wait before attempting to reconnect to the primary server
# + queriesBeforeRetry - Number of queries to execute before attempting to reconnect to the primary server
# + failoverReadOnly - Open connection to secondary host in READ ONLY mode
public type FailoverConfig record {|
    FailoverServer[] failoverServers;
    int timeBeforeRetry?;
    int queriesBeforeRetry?;
    boolean failoverReadOnly = true;
|};

# Configuration for failover servers.
#
# + host - Secondary server hostname
# + port - Secondary server port
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

# Establish an unencrypted connection to the server. If the server supports encrypted connections, the connection
# attempt fails.
public const SSL_DISABLED = "DISABLED";

# `SSLMode` as a union of available SSL modes.
public type SSLMode SSL_PREFERRED|SSL_REQUIRED|SSL_VERIFY_CA|SSL_VERIFY_IDENTITY|SSL_DISABLED;

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
