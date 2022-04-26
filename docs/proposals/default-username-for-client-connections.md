# Define default username for client connections

_Owners_: @kaneeldias  
_Reviewers_: @daneshk @niveathika  
_Created_: 2022/04/25  
_Updated_: 2022/04/22  
_Edition_: Swan Lake  
_Issues_: [#2397](https://github.com/ballerina-platform/ballerina-standard-library/issues/2397)

## Summary
Define default username to be used when connecting to a MySQL database on client initialization.

## History
The 1.3.x versions and below of the MySQL package defaulted to connecting to the database without a username
attached (i.e. an empty string).

## Goals
- Define the default username to be used when connecting to a MySQL database on client initialization.

## Motivation
The ability to connect to common databases with default credentials (as opposed to manually defining) would make the
developer experience much more quick, simple and user-friendly, especially in testing scenarios.

## Description
For MySQL databases, the default username is `root`[[1]](https://dev.mysql.com/doc/refman/8.0/en/default-privileges.html)

Modify the [client initialization method](https://github.com/ballerina-platform/module-ballerinax-mysql/blob/c2651da46c098ea6ef4a79079dc26cbd4d7cf54b/ballerina/client.bal#L36-L37)
signature to use `root` as the default value for the username instead of `()`.

```ballerina
    public isolated function init(string host = "localhost", string? user = "root", string? password = (), string? database = (),
        int port = 1433, string instance = "", Options? options = (), sql:ConnectionPool? connectionPool = ()) returns sql:Error? {
```

## References
[1] https://dev.mysql.com/doc/refman/8.0/en/default-privileges.html
