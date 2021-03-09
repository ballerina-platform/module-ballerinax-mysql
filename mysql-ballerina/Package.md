## Package overview

This Package provides the functionality required to access and manipulate data stored in a MySQL database.  

**Prerequisite:** Add the MySQL driver JAR as a native library dependency in your Ballerina project. 
This Package uses database properties from the MySQL version 8.0.x onwards. Therefore, it is recommended to use a 
MySQL driver version greater than 8.0.x. Then, once you build the project by executing the `ballerina build`
command, you should be able to run the resultant by executing the `ballerina run` command.

E.g., The `Ballerina.toml` content.
Change the path to the JDBC driver appropriately.

```toml
[package]
org = "sample"
name = "mysql"
version= "0.1.0"

[[platform.java11.dependency]]
artafactId = "mysql-connector-java"
version = "8.0.17"
path = "/path/to/mysql-connector-java-8.0.17.jar"
groupId = "mysql"
``` 

### Client
To access a database, you must first create a 
[mysql:Client](https://ballerina.io/learn/api-docs/ballerina/#/mysql/clients/Client) object. 
The examples for creating a MySQL client can be found below.

#### Creating a client
This example shows different ways of creating the `mysql:Client`. 

The client can be created with an empty constructor and hence, the client will be initialized with the default properties. 
The first example with the `dbClient1` demonstrates this.

The `dbClient2` receives the host, username, and password. Since the properties are passed in the same order as it is defined 
in the `jdbc:Client`, you can pass it without named params.

The `dbClient3` uses the named params to pass the attributes since it is skipping some params in the constructor. 
Further [mysql:Options](https://ballerina.io/learn/api-docs/ballerina/#/mysql/records/Options) 
is passed to configure the SSL and connection timeout in the MySQL client. 

Similarly, the `dbClient4` uses the named params and it provides an unshared connection pool in the type of 
[sql:ConnectionPool](https://ballerina.io/learn/api-docs/ballerina/#/sql/records/ConnectionPool) 
to be used within the client. 
For more details about connection pooling, see the [SQL Package](https://ballerina.io/learn/api-docs/ballerina/#/sql).

```ballerina
mysql:Client|sql:Error dbClient1 = new ();
mysql:Client|sql:Error dbClient2 = new ("localhost", "rootUser", "rooPass", 
                              "information_schema", 3306);
                              
mysql:Options mysqlOptions = {
  ssl: {
    mode: mysql:SSL_PREFERRED
  },
  connectTimeout: 10
};
mysql:Client|sql:Error dbClient3 = new (user = "rootUser", password = "rootPass",
                              options = mysqlOptions);
mysql:Client|sql:Error dbClient4 = new (user = "rootUser", password = "rootPass",
                              connectionPool = {maxOpenConnections: 5});
```
You can find more details about each property in the
[mysql:Client](https://ballerina.io/learn/api-docs/ballerina/#/mysql/clients/Client) constructor. 

The [mysql:Client](https://ballerina.io/learn/api-docs/ballerina/#/mysql/clients/Client) references 
[sql:Client](https://ballerina.io/learn/api-docs/ballerina/#/sql/abstractObjects/Client) and all the operations 
defined by the `sql:Client` will be supported by the `mysql:Client` as well. 

For more information on all the operations supported by the `mysql:Client`, which include the below, see the [SQL Package](https://ballerina.io/learn/api-docs/ballerina/#/sql).

1. Connection Pooling
2. Querying data
3. Inserting data
4. Updating data
5. Deleting data
6. Batch insert and update data
7. Execute stored procedures
8. Closing client