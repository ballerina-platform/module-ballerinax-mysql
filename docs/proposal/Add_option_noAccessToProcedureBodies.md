# Add option to set `noAccessToProcedureBodies` driver property

_Owners_: @daneshk @niveathika  
_Reviewers_: @daneshk  
_Created_: 2021/10/15  
_Updated_: 2021/10/15  
_Issues_: [#2048](https://github.com/ballerina-platform/ballerina-standard-library/issues/2048)

## Summary

Only the user who created the MySQL stored procedure can access the procedure's metadata. In case the stored procedure contains out parameters, the metadata is needed to evoke the stored procedure. A lesser privileged user needs to enable MySQL driver property, noAccessToProcedureBodies, to execute a stored procedure with INOUT parameters. From the ballerina SQL client option, this needs to be exposed.

## Motivation

This option allows a lesser privileged user to evoke stored procedures through the ballerina SQL module.

## Description

This feature adds the below option,
```ballerina
public type Options record {|
    .....
    boolean noAccessToProcedureBodies = false;
|};
```

Here the `noAccessToProcedureBodies` can be used to set driver property of the same name.

This can be used as follows,
```ballerina
Options options = {
    noAccessToProcedureBodies: true
};

Client dbClient = check new (user = "newuser", password = "admin", database = "testdb", options = options);
```
