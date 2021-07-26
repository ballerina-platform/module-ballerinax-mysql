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

    # Initializes the MySQL Client.
    #
    # + host - Hostname of the MySQL server to be connected
    # + user - If the MySQL server is secured, the username to be used to connect to the MySQL server
    # + password - The password of provided username of the database
    # + database - The name fo the database to be connected
    # + port - Port number of the mysql server to be connected
    # + options - MySQL database options
    # + connectionPool - The `sql:ConnectionPool` object to be used within the MySQL client.
    #                   If there is no `connectionPool` provided, the global connection pool will be used and it will
    #                   be shared by other clients, which have the same properties
    public isolated function init(string host = "localhost", string? user = (), string? password = (), string? database = (),
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

    # Queries the database with the provided query and returns the result as a stream.
    #
    # + sqlQuery - The query, which needs to be executed as a `string` or  an `sql:ParameterizedQuery` when the SQL query has
    #              params to be passed in
    # + rowType - The `typedesc` of the record that should be returned as a result. If this is not provided, the default
    #             column names of the query result set will be used for the record attributes
    # + return - Stream of records in the type of `rowType`. If the `rowType` is not provided, the column names of     
    #                  the query are used as record fields and all record fields are optional
    remote isolated function query(string|sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>)
    returns stream <rowType, sql:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.mysql.nativeimpl.QueryProcessor",
        name: "nativeQuery"
    } external;

    # Executes the provided DDL or DML SQL queries and returns a summary of the execution.
    #
    # + sqlQuery - The DDL or DML queries such as `INSERT`, `DELETE`, `UPDATE`, etc. as a`string` or an `sql:ParameterizedQuery`
    #              when the query has params to be passed in
    # + return - Summary of the SQL update query as an `sql:ExecutionResult` or `sql:Error`
    #           if any error occurred when executing the query
    remote isolated function execute(string|sql:ParameterizedQuery sqlQuery)
     returns sql:ExecutionResult|sql:Error = @java:Method {
         'class: "io.ballerina.stdlib.mysql.nativeimpl.ExecuteProcessor",
         name: "nativeExecute"
    } external;

    # Executes a batch of parameterized DDL or DML sql query provided by the user,
    # and returns the summary of the execution.
    #
    # + sqlQueries - The DDL or DML query such as `INSERT`, `DELETE`, `UPDATE`, etc. as an `sql:ParameterizedQuery` with an array
    #                of values passed in
    # + return - Summary of the executed SQL queries as an `sql:ExecutionResult[]`, which includes details such as
    #            the `affectedRowCount` and `lastInsertId`. If one of the commands in the batch fails, this function
    #            will return an `sql:BatchExecuteError`. However, the MySQL driver may or may not continue to process the
    #            remaining commands in the batch after a failure. The summary of the executed queries in case of an error
    #            can be accessed as `(<sql:BatchExecuteError> result).detail()?.executionResults`
    remote isolated function batchExecute(sql:ParameterizedQuery[] sqlQueries) returns sql:ExecutionResult[]|sql:Error {
        if (sqlQueries.length() == 0) {
            return error sql:ApplicationError(" Parameter 'sqlQueries' cannot be empty array");
        }
        return nativeBatchExecute(self, sqlQueries);
    }

    # Executes a SQL stored procedure and returns the result as stream and execution summary.
    #
    # + sqlQuery - The query to execute the SQL stored procedure
    # + rowTypes - The array of `typedesc` of the records that should be returned as a result. If this is not provided,
    #               the default column names of the query result set will be used for the record attributes
    # + return - Summary of the execution is returned in an `sql:ProcedureCallResult` or `sql:Error`
    remote isolated function call(string|sql:ParameterizedCallQuery sqlQuery, typedesc<record {}>[] rowTypes = [])
    returns sql:ProcedureCallResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.mysql.nativeimpl.CallProcessor",
        name: "nativeCall"
    } external;

    # Close the SQL client.
    #
    # + return - Possible error during closing the client
    public isolated function close() returns sql:Error? = @java:Method {
        'class: "io.ballerina.stdlib.mysql.nativeimpl.ClientProcessor",
        name: "close"
    } external;
}

# Provides a set of configurations for the mysql client to be passed internally within the module.
#
# + host - URL of the database to connect
# + port - Port of the database to connect
# + user - Username for the database connection
# + password - Password for the database connection
# + database - Name of the database
# + options - MySQL datasource `mysql:Options` to be configured
# + connectionPool - Properties of the `sql:ConnectionPool` for the connection pool configuration.
type ClientConfiguration record {|
    string host;
    int port;
    string? user;
    string? password;
    string? database;
    Options? options;
    sql:ConnectionPool? connectionPool;
|};

# MySQL database options.
#
# + ssl - SSL Configuration to be used
# + useXADatasource - Boolean value to enable XADatasource
# + connectTimeout - Timeout (in seconds) to be used when connecting to the mysql server
# + socketTimeout - Socket timeout (in seconds) during the read/write operations with the MySQL server
#                   (0 means no socket timeout)
# + serverTimezone - Configures the connection time zone, which is used by the `Connector/J` if the conversion between a Ballerina
#                    application and a target time zone is needed when preserving instant temporal values
public type Options record {|
    SecureSocket ssl?;
    boolean useXADatasource = false;
    decimal connectTimeout = 30;
    decimal socketTimeout = 0;
    string serverTimezone?;
|};

# Establish an encrypted connection if the server supports encrypted connections falling back to an unencrypted
# connection if an encrypted connection cannot be established.
public const SSL_PREFERRED = "PREFERRED";
# Establish an encrypted connection if the server supports encrypted connections. The connection attempt fails if
# an encrypted connection cannot be established.
public const SSL_REQUIRED = "REQUIRED";
# Establish an encrypted connection if the server supports encrypted connections. The connection attempt fails if
# an encrypted connection cannot be established. Additionally, verify the server Certificate Authority (CA)
# certificate against the configured CA certificates. The connection attempt fails if no valid matching CA
# certificates are found.
public const SSL_VERIFY_CA = "VERIFY_CA";
# Establish an encrypted connection if the server supports encrypted connections and verify the server
# Certificate Authority (CA) certificate against the configured CA certificates. The connection attempt fails if an
# encrypted connection cannot be established or no valid matching CA certificates are found. Also, perform hostname
# identity verification by checking the hostname the client uses for connecting to the server against the identity
# in the certificate that the server sends to the client.
public const SSL_VERIFY_IDENTITY = "VERIFY_IDENTITY";

# `SSLMode` as a union of available SSL modes.
public type SSLMode SSL_PREFERRED|SSL_REQUIRED|SSL_VERIFY_CA|SSL_VERIFY_IDENTITY;

# SSL Configuration to be used when connecting to mysql server.
#
# + mode - `SSLMode` to be used during the connection
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
