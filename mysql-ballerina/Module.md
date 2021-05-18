## Overview

This module provides the functionality required to access and manipulate data stored in a MySQL database.

**Prerequisite:** Add the MySQL driver JAR as a native library dependency in your Ballerina project.
This module uses the database properties from the MySQL version 8.0.13 onwards. Therefore, it is recommended to use a
MySQL driver version greater than 8.0.13. Then, once you build the project by executing the `ballerina build`
command, you should be able to run the resultant by executing the `ballerina run` command.

E.g., The `Ballerina.toml` content.
Change the path to the JDBC driver appropriately.

```toml
[package]
org = "sample"
name = "mysql"
version= "0.1.0"

[[platform.java11.dependency]]
artifactId = "mysql-connector-java"
version = "8.0.17"
path = "/path/to/mysql-connector-java-8.0.17.jar"
groupId = "mysql"
``` 

### Client
To access a database, you must first create a
[mysql:Client](https://ballerina.io/learn/api-docs/ballerina/#/mysql/clients/Client) object.
The examples for creating a MySQL client can be found below.

#### Creating a Client
This example shows the different ways of creating the `mysql:Client`.

The client can be created with an empty constructor, and thereby, the client will be initialized with the default properties.

```ballerina
mysql:Client|sql:Error dbClient = new ();
```

The `dbClient` receives the host, username, and password. Since the properties are passed in the same order as they are defined
in the `jdbc:Client`, you can pass them without named params.

```ballerina
mysql:Client|sql:Error dbClient = new ("localhost", "rootUser", "rooPass", 
                              "information_schema", 3306);
```

The `dbClient` uses the named params to pass the attributes since it is skipping some params in the constructor.
Further, the [`mysql:Options`](https://ballerina.io/learn/api-docs/ballerina/#/mysql/records/Options)
property is passed to configure the SSL and connection timeout in the MySQL client.

```ballerina
mysql:Options mysqlOptions = {
  ssl: {
    mode: mysql:SSL_PREFERRED
  },
  connectTimeout: 10
};
mysql:Client|sql:Error dbClient = new (user = "rootUser", password = "rootPass",
                              options = mysqlOptions);
```

Similarly, the `dbClient` uses the named params and it provides an unshared connection pool of the type of
[sql:ConnectionPool](https://ballerina.io/learn/api-docs/ballerina/#/sql/records/ConnectionPool)
to be used within the client.
For more details about connection pooling, see the [SQL Module](https://ballerina.io/learn/api-docs/ballerina/#/sql).

```ballerina
mysql:Client|sql:Error dbClient = new (user = "rootUser", password = "rootPass",
                              connectionPool = {maxOpenConnections: 5});
```

#### Using SSL
To connect the MySQL database using an SSL connection, you must add the SSL configurations to the `mysql:Options` when creating the `dbClient`.
For the SSL Mode, you can select one of the modes: `mysql:SSL_PREFERRED`, `mysql:SSL_REQUIRED`, `mysql:SSL_VERIFY_CA`, or `mysql:SSL_VERIFY_IDENTITY` according to the requirement.
For the key and cert files, you must provide the files in the `.p12` format.

```ballerina
string clientStorePath = "/path/to/keystore.p12";
string turstStorePath = "/path/to/truststore.p12";

mysql:Options mysqlOptions = {
  ssl: {
    mode: mysql:SSL_PREFERRED,
    key: {
        path: clientStorePath,
        password: "password"
    },
    cert: {
        path: turstStorePath,
        password: "password"
    }
  }
};
```
#### Connection Pool Handling

All database modules share the same connection pooling concept and there are three possible scenarios for 
connection pool handling.  For its properties and possible values, see the `sql:ConnectionPool`.  

1. Global, shareable, default connection pool

    If you do not provide the `poolOptions` field when creating the database client, a globally-shareable pool will be 
    created for your database unless a connection pool matching with the properties you provided already exists. 
    The JDBC module example below shows how the global connection pool is used. 

    ```ballerina
    jdbc:Client|sql:Error dbClient = 
                               new ("jdbc:mysql://localhost:3306/testdb", 
                                "root", "root");
    ```

2. Client owned, unsharable connection pool

    If you define the `connectionPool` field inline when creating the database client with the `sql:ConnectionPool` type, 
    an unsharable connection pool will be created. The JDBC module example below shows how the global 
    connection pool is used.

    ```ballerina
    jdbc:Client|sql:Error dbClient = 
                               new (url = "jdbc:mysql://localhost:3306/testdb", 
                               connectionPool = { maxOpenConnections: 5 });
    ```

3. Local, shareable connection pool

    If you create a record of type `sql:ConnectionPool` and reuse that in the configuration of multiple clients, 
    for each set of clients that connects to the same database instance with the same set of properties, a shared 
    connection pool will be created. The JDBC module example below shows how the global connection pool is used.

    ```ballerina
    sql:ConnectionPool connPool = {maxOpenConnections: 5};
    
    jdbc:Client|sql:Error dbClient1 =       
                               new (url = "jdbc:mysql://localhost:3306/testdb",
                               connectionPool = connPool);
    jdbc:Client|sql:Error dbClient2 = 
                               new (url = "jdbc:mysql://localhost:3306/testdb",
                               connectionPool = connPool);
    jdbc:Client|sql:Error dbClient3 = 
                               new (url = "jdbc:mysql://localhost:3306/testdb",
                               connectionPool = connPool);
    ```
   
For more details about each property, see the [`mysql:Client`](https://ballerina.io/learn/api-docs/ballerina/#/mysql/clients/Client) constructor.


The [mysql:Client](https://ballerina.io/learn/api-docs/ballerina/#/mysql/clients/Client) references
[sql:Client](https://ballerina.io/learn/api-docs/ballerina/#/sql/abstractObjects/Client) and all the operations
defined by the `sql:Client` will be supported by the `mysql:Client` as well.
 
#### Closing the Client

Once all the database operations are performed, you can close the database client you have created by invoking the `close()`
operation. This will close the corresponding connection pool if it is not shared by any other database clients. 

```ballerina
error? e = dbClient.close();
```
or
```ballerina
check dbClient.close();
```

### Database Operations

Once the client is created, database operations can be executed through that client. This module defines the interface 
and common properties that are shared among multiple database clients.  It also supports querying, inserting, deleting, 
updating, and batch updating data.  

#### Creating Tables

This sample creates a table with two columns. One column is of type `int` and the other is of type `varchar`.
The `CREATE` statement is executed via the `execute` remote function of the client.

```ballerina
// Create the ‘Students’ table with the  ‘id’, 'name', and ‘age’ fields.
sql:ExecutionResult ret = check dbClient->execute("CREATE TABLE student(id INT AUTO_INCREMENT, " +
                         "age INT, name VARCHAR(255), PRIMARY KEY (id))");
//A value of the`sql:ExecutionResult` type is returned for 'ret'. 
```

#### Inserting Data

This sample shows three examples of data insertion by executing an `INSERT` statement using the `execute` remote function 
of the client.

In the first example, the query parameter values are passed directly into the query statement of the `execute` 
remote function.

```ballerina
sql:ExecutionResult ret = check dbClient->execute("INSERT INTO student(age, name) " +
                         "values (23, 'john')");
```

In the second example, the parameter values, which are in local variables are used to parameterize the SQL query in 
the `execute` remote function. This type of a parameterized SQL query can be used with any primitive Ballerina type 
like `string`, `int`, `float`, or `boolean` and in that case, the corresponding SQL type of the parameter is derived 
from the type of the Ballerina variable that is passed in. 

```ballerina
string name = "Anne";
int age = 8;

sql:ParameterizedQuery query = `INSERT INTO student(age, name)
                                values (${age}, ${name})`;
sql:ExecutionResult ret = check dbClient->execute(query);
```

In the third example, the parameter values are passed as an `sql:TypedValue` to the `execute` remote function. Use the 
corresponding subtype of the `sql:TypedValue` such as `sql:Varchar`, `sql:Char`, `sql:Integer`, etc. when you need to 
provide more details such as the exact SQL type of the parameter.

```ballerina
sql:VarcharValue name = new ("James");
sql:IntegerValue age = new (10);

sql:ParameterizedQuery query = `INSERT INTO student(age, name)
                                values (${age}, ${name})`;
sql:ExecutionResult ret = check dbClient->execute(query);
```

#### Inserting Data With Auto-generated Keys

This example demonstrates inserting data while returning the auto-generated keys. It achieves this by using the 
`execute` remote function to execute the `INSERT` statement.

```ballerina
int age = 31;
string name = "Kate";

sql:ParameterizedQuery query = `INSERT INTO student(age, name)
                                values (${age}, ${name})`;
sql:ExecutionResultret = check dbClient->execute(query);
//Number of rows affected by the execution of the query.
int? count = ret.affectedRowCount;
//The integer or string generated by the database in response to a query execution.
string|int? generatedKey = ret.lastInsertId;
}
```

#### Querying Data

This sample shows three examples to demonstrate the different usages of the `query` operation to query the
database table and obtain the results. 

This example demonstrates querying data from a table in a database. 
First, a type is created to represent the returned result set. Note the mapping of the database column 
to the returned record's property is case-insensitive (i.e., the `ID` column in the result can be mapped to the `id` 
property in the record). Next, the `SELECT` query is executed via the `query` remote function of the client by passing that 
result set type. Once the query is executed, each data record can be retrieved by looping the result set. The `stream` 
returned by the `SELECT` operation holds a pointer to the actual data in the database and it loads data from the table 
only when it is accessed. This stream can be iterated only once. 

```ballerina
// Define a type to represent the results.
type Student record {
    int id;
    int age;
    string name;
};

// Select the data from the database table. The query parameters are passed 
// directly. Similar to the `execute` examples, parameters can be passed as
// sub types of `sql:TypedValue` as well.
int id = 10;
int age = 12;
sql:ParameterizedQuery query = `SELECT * FROM students
                                WHERE id < ${id} AND age > ${age}`;
stream<Student, sql:Error> resultStream = 
        <stream<Student, sql:Error>> dbClient->query(query, Student);

// Iterating the returned table.
error? e = resultStream.forEach(function(Student student) {
   //Can perform any operations using 'student' and can access any fields in the returned record of type `Student`.
});
```

Defining the return type is optional and you can query the database without providing the result type. Hence, 
the above example can be modified as follows with an open record type as the return type. The property name in the open record 
type will be the same as how the column is defined in the database. 

```ballerina
// Select the data from the database table. The query parameters are passed 
// directly. Similar to the `execute` examples, parameters can be passed as 
// sub types of `sql:TypedValue` as well.
int id = 10;
int age = 12;
sql:ParameterizedQuery query = `SELECT * FROM students
                                WHERE id < ${id} AND age > ${age}`;
stream<record{}, sql:Error> resultStream = dbClient->query(query);

// Iterating the returned table.
error? e = resultStream.forEach(function(record{} student) {
    //Can perform any operations using 'student' and can access any fields in the returned record.
});
```

There are situations in which you may not want to iterate through the database and in that case, you may decide
to only use the `next()` operation in the result `stream` and retrieve the first record. In such cases, the returned
result stream will not be closed and you have to invoke the `close` operation explicitly on the 
`sql:Client` to release the connection resources and avoid a connection leak as shown below.

```ballerina
stream<record{}, sql:Error> resultStream = 
            dbClient->query("SELECT count(*) as total FROM students");

record {|record {} value;|}|error? result = resultStream.next();

if result is record {|record {} value;|} {
    //A valid result is returned.
} else if result is error {
    // An error is returned as the result.
} else {
    // The `Student` table must be empty.
}

error? e = resultStream.close();
```

#### Updating Data

This example demonstrates modifying data by executing an `UPDATE` statement via the `execute` remote function of 
the client.

```ballerina
int age = 23;
sql:ParameterizedQuery query = `UPDATE students SET name = 'John' 
                                WHERE age = ${age}`;
sql:ExecutionResult|sql:Error ret = check dbClient->execute(query);
```

#### Deleting Data

This example demonstrates deleting data by executing a `DELETE` statement via the `execute` remote function of 
the client.

```ballerina
string name = "John";
sql:ParameterizedQuery query = `DELETE from students WHERE name = ${name}`;
sql:ExecutionResult|sql:Error ret = check dbClient->execute(query);
```

#### Batch Updating Data

This example demonstrates how to insert multiple records with a single `INSERT` statement that is executed via the 
`batchExecute` remote function of the client. This is done by creating a `table` with multiple records and 
parameterized SQL query as same as the  above `execute` operations.

```ballerina
// Create the table with the records that need to be inserted.
var data = [
  { name: "John", age: 25  },
  { name: "Peter", age: 24 },
  { name: "jane", age: 22 }
];

// Do the batch update by passing the batches.
sql:ParameterizedQuery[] batch = from var row in data
                                 select `INSERT INTO students ('name', 'age')
                                 VALUES (${row.name}, ${row.age})`;
sql:ExecutionResult[] ret = check dbClient->batchExecute(batch);
```

#### Execute SQL Stored Procedures

This example demonstrates how to execute a stored procedure with a single `INSERT` statement that is executed via the 
`call` remote function of the client.

```ballerina
int uid = 10;
sql:IntegerOutParameter insertId = new;

sql:ProcedureCallResult|sql:Error ret = dbClient->call(`call InsertPerson(${uid}, ${insertId})`);
if ret is error {
    //An error returned
} else {
    stream<record{}, sql:Error>? resultStr = ret.queryResult;
    if resultStr is stream<record{}, sql:Error> {
        sql:Error? e = resultStr.forEach(function(record{} result) {
        //can perform operations using 'result'.
      });
    }
    check ret.close();
}
```

Note that you have to invoke the close operation on the `sql:ProcedureCallResult` explicitly to release the connection resources and avoid a connection leak as shown above.

>**Note:** The default thread pool size used in Ballerina is the number of processors available * 2. You can configure
the thread pool size by using the `BALLERINA_MAX_POOL_SIZE` environment variable.
> 
