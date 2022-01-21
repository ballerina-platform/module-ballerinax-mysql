# Specification: Ballerina MySQL Library

_Owners_: @daneshk @niveathika  
_Reviewers_: @daneshk  
_Created_: 2022/01/14   
_Updated_: 2022/01/14  
_Issue_: [#2289](https://github.com/ballerina-platform/ballerina-standard-library/issues/2289)

# Introduction

This is the specification for MySQL standard library, which the functionality required to access and manipulate data 
stored in a MySQL database in the [Ballerina programming language](https://ballerina.io/), which is an open-source 
programming language for the cloud that makes it easier to use, combine, and create network services.

# Contents

1. [Overview](#1-overview)
2. [Client](#2-client)  
   2.1. [Connection Pool Handling](#21-connection-pool-handling)  
   2.2. [Closing the Client](#22-closing-the-client)
3. [Queries and Values](#3-queries-and-values)
4. [Database Operations](#4-database-operations)

# 1. Overview

This specification elaborates on usage of MySQL `Client` interface to interface with an MySQL database.

`Client` supports five database operations as follows,
1. Executes the query, which may return multiple results.
2. Executes the query, which is expected to return at most one row of the result.
3. Executes the SQL query. Only the metadata of the execution is returned.
4. Executes the SQL query with multiple sets of parameters in a batch. Only the metadata of the execution is returned.
5. Executes a SQL query, which calls a stored procedure. This can either return results or nil.

All the above operations make use of `sql:ParameterizedQuery` object, backtick surrounded string template to pass
SQL statements to the database. `sql:ParameterizedQuery` supports passing of Ballerina basic types or Typed SQL Values
such as `sql:CharValue`, `sql:BigIntValue`, etc. to indicate parameter types in SQL statements.

# 2. Client

Each client represents a pool of connections to the database. The pool of connections is maintained throughout the
lifetime of the client.

**Initialisation of the Client:**
```ballerina
# Initializes the MySQL Client.
#
# + host - Hostname of the MySQL server
# + user - If the MySQL server is secured, the username
# + password - The password of the MySQL server for the provided username
# + database - The name of the database
# + port - Port number of the MySQL server
# + options - MySQL database options
# + connectionPool - The `sql:ConnectionPool` to be used for the connection. If there is no
#                    `connectionPool` provided, the global connection pool (shared by all 
#                    clients) will be used
# + return - An `sql:Error` if the client creation fails
public isolated function init(string host = "localhost", string? user = (), 
       string? password = (), string? database = (), int port = 3306, Options? options = (), 
       sql:ConnectionPool? connectionPool = ()) returns sql:Error?;
```

**Configurations available for initializing the MySQL client:**
* Connection properties:
  ```ballerina
  # Provides a set of additional configurations related to the MySQL database connection.
  #
  # + ssl - SSL configurations to be used
  # + failoverConfig - Server failover configurations to be used
  # + useXADatasource - Flag to enable or disable XADatasource
  # + connectTimeout - Timeout (in seconds) to be used when establishing a connection to the MySQL server
  # + socketTimeout - Socket timeout (in seconds) to be used during the read/write operations with the MySQL server
  #                   (0 means no socket timeout)
  # + serverTimezone - Configures the connection time zone, which is used by the `Connector/J` if the conversion between
  #                    a Ballerina application and a target time zone is required when preserving instant temporal values
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
  ```
* Server Failover Support
   ```ballerina
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
   ```
* Failover Servers
   ```ballerina
   # Configuration for failover servers
   #
   # + host - Hostname of the secondary server
   # + port - Port of the secondary server
   public type FailoverServer record {|
       string host;
       int port;
   |};
   ```

## 2.1. Connection Pool Handling

Connection Pool Handling is generic and implemented through `sql` module. For more information, see the
[SQL Specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#21-connection-pool-handling)

## 2.2. Closing the Client

Once all the database operations are performed, the client can be closed by invoking the `close()`
operation. This will close the corresponding connection pool if it is not shared by any other database clients.

   ```ballerina
    # Closes the MySQL client and shuts down the connection pool.
    #
    # + return - Possible error when closing the client
    public isolated function close() returns Error?;
   ```

# 3. Queries and Values

All the generic `sql` Queries and Values are supported. For more information, see the
[SQL Specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#3-queries-and-values)

# 4. Database Operations

`Client` supports five database operations as follows,
1. Executes the query, which may return multiple results.
2. Executes the query, which is expected to return at most one row of the result.
3. Executes the SQL query. Only the metadata of the execution is returned.
4. Executes the SQL query with multiple sets of parameters in a batch. Only the metadata of the execution is returned.
5. Executes a SQL query, which calls a stored procedure. This can either return results or nil.

For more information on Database Operations see the [SQL Specification](https://github.com/niveathika/module-ballerina-sql/blob/master/docs/spec/spec.md#4-database-operations)