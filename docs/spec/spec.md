# Specification: Ballerina MySQL Library

_Owners_: @daneshk @niveathika  
_Reviewers_: @daneshk  
_Created_: 2022/01/14   
_Updated_: 2022/04/25  
_Edition_: Swan Lake  

## Introduction

This is the specification for the MySQL standard library of [Ballerina language](https://ballerina.io/), which the functionality required to access and manipulate data stored in a MySQL database.  

The MySQL library specification has evolved and may continue to evolve in the future. The released versions of the specification can be found under the relevant GitHub tag. 

If you have any feedback or suggestions about the library, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/ballerina-standard-library/issues) or in the [Discord server](https://discord.gg/ballerinalang). Based on the outcome of the discussion, the specification and implementation can be updated. Community feedback is always welcome. Any accepted proposal, which affects the specification is stored under `/docs/proposals`. Proposals under discussion can be found with the label `type/proposal` in GitHub.

The conforming implementation of the specification is released to Ballerina Central. Any deviation from the specification is considered a bug.

## Contents

- [Specification: Ballerina MySQL Library](#specification-ballerina-mysql-library)
  - [Introduction](#introduction)
  - [Contents](#contents)
- [1. Overview](#1-overview)
- [2. Client](#2-client)
  - [2.1. Handle connection pools](#21-handle-connection-pools)
  - [2.2. Close the client](#22-close-the-client)
- [3. Queries and values](#3-queries-and-values)
- [4. Database operations](#4-database-operations)
- [5. Change Data Capture Listener](#5-change-data-capture-listener)
  - [5.1. Create a listener](#51-create-a-listener)
  - [5.2. Implement a service to handle CDC events](#52-implement-a-service-to-handle-cdc-events)

# 1. Overview

This specification elaborates on the usage of the MySQL `Client` interface to interface with a MySQL database.

`Client` supports five database operations as follows,
1. Executes the query, which may return multiple results.
2. Executes the query, which is expected to return at most one row of the result.
3. Executes the SQL query. Only the metadata of the execution is returned.
4. Executes the SQL query with multiple sets of parameters in a batch. Only the metadata of the execution is returned.
5. Executes a SQL query, which calls a stored procedure. This can either return results or nil.

All the above operations make use of `sql:ParameterizedQuery` object, backtick surrounded string template to pass
SQL statements to the database. `sql:ParameterizedQuery` supports passing of Ballerina basic types or typed SQL values
such as `sql:CharValue`, `sql:BigIntValue`, etc. to indicate parameter types in SQL statements.

# 2. Client

Each client represents a pool of connections to the database. The pool of connections is maintained throughout the
lifetime of the client.

**Initialization of the Client:**
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
public isolated function init(string host = "localhost", string? user = "root", 
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
* Server failover support
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
* Failover servers
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

## 2.1. Handle connection pools

Connection pool handling is generic and implemented through `sql` module. For more information, see the
[SQL specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#21-connection-pool-handling)

## 2.2. Close the client

Once all the database operations are performed, the client can be closed by invoking the `close()`
operation. This will close the corresponding connection pool if it is not shared by any other database clients.

   ```ballerina
    # Closes the MySQL client and shuts down the connection pool.
    #
    # + return - Possible error when closing the client
    public isolated function close() returns Error?;
   ```

# 3. Queries and values

All the generic `sql` Queries and Values are supported. For more information, see the
[SQL specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#3-queries-and-values)

# 4. Database operations

`Client` supports five database operations as follows,
1. Executes the query, which may return multiple results.
2. Executes the query, which is expected to return at most one row of the result.
3. Executes the SQL query. Only the metadata of the execution is returned.
4. Executes the SQL query with multiple sets of parameters in a batch. Only the metadata of the execution is returned.
5. Executes a SQL query, which calls a stored procedure. This can either return results or nil.

For more information on database operations, see the [SQL specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#4-database-operations)

# 5. Change Data Capture Listener

To listen for change data capture (CDC) events from a MySQL database, you must create a [`mysql:CdcListener`](https://docs.central.ballerina.io/ballerinax/mysql/latest#CdcListener) object. The listener allows your Ballerina application to react to changes (such as inserts, updates, and deletes) in real time.

## 5.1. Create a listener

You can create a CDC listener by specifying the required configurations such as host, port, username, password, and database name. Additional options can be provided using the [`cdc:Options`](https://docs.central.ballerina.io/ballerinax/mysql/latest#CDCOptions) record.

```ballerina
listener mysql:CdcListener cdcListener = new (database = {
    username: <username>,
    password: <password>
});
```

## 5.2. Implement a service to handle CDC events

You can attach a service to the listener to handle CDC events. The service can define remote methods for different event types such as `onRead`, `onCreate`, `onUpdate`, and `onDelete`.

```ballerina
service on cdcListener {
    remote function onRead(record{} after) returns cdc:Error? {
        io:println("Insert event: ", after);
    }

    remote function onCreate(record{} after) returns cdc:Error? {
        io:println("Insert event: ", after);
    }

    remote function onUpdate(record{} before, record{} after) returns cdc:Error? {
        io:println("Update event - Before: ", before, " After: ", after);
    }

    remote function onDelete(record{} before) returns error? {
        io:println("Delete event: ", before);
    }
}
```
