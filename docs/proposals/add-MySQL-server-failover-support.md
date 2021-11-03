# Add MySQL Server Failover Support

_Owners_: @daneshk @niveathika  
_Reviewers_: @anupama-pathirage @BuddhiWathsala  
_Created_: 2021/10/15  
_Updated_: 2021/11/03  
_Issues_: [#2053](https://github.com/ballerina-platform/ballerina-standard-library/issues/2053)

## Summary

Currently, the ballerina SQL client can only connect to one MySQL server. The user has to handle connection errors by switching to the secondary replicated database or retrying. We can support MySQL server failovers so that the user does not need to maintain multiple clients to switch between secondary databases.

## Goals
Allow ballerina client to connect to secondary databases in case of connection errors using the MySQL server Failover feature.

## Motivation
The user can easily connect between database replicas without using complex logic.

## Description
`FailoverConfig ` configuration will be introduced to `mysql:Options`.
```ballerina
# Configuration for failover servers
#
# + host - Hostname of the secondary database to be connected
# + port - Port of the secondary database to connect
public type FailoverServer record {|
    string host;
    int port;
|};

# Configuration to be used for Server Failover.
#
# + secondaries - Array of host & port tuple for the secondary databases
# + timeBeforeRetry - Time the driver waits before trying to fall back to the primary host
# + queriesBeforeRetry - Number of queries that are executed before the driver tries to fall back to the primary host
# + failoverReadOnly - Open connection to secondary host with READ ONLY mode.
public type FailoverConfig record {|
    FailoverServer[] failoverServers;
    int timeBeforeRetry?;
    int queriesBeforeRetry?;
    boolean failoverReadOnly = true;
|};

public type Options record {|
    ....
    FailoverConfig failoverConfig?;
|};
```

Failover configuration usage will be,
```ballerina
Options option = {
    failoverConfig: {
        failoverServers: [
            {
                host: "localhost"
                port: 5506
            },
            {
                host: "localhost",
                port: 3305
            }
        ],
        timeBeforeRetry: 10,
        queriesBeforeRetry: 10,
        failoverReadOnly: false
    }
};
Client dbClient = check new (host, "root", "111", "mydb", 4406, option);
```

## Testing

Since a replication MySQL server is needed as a prerequisite for testing, this feature is manually tested. A docker-based MySQL replication is used for testing.  [Prerequisite Reference](https://hackernoon.com/mysql-master-slave-replication-using-docker-3pp3u97)

After the docker images are set up following code can be used for testing,
```ballerina
import ballerina/test;
import ballerina/sql;
import ballerina/io;
import ballerina/lang.runtime;

@test:Config {
    groups: ["query-1"]
}
function queryReplica() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT * from Code;`;

    Options option = {
        failoverConfig: {
            failoverServers: [
                {
                    host: "localhost",
                    port: 5506
                }
            ],
            timeBeforeRetry: 10,
            queriesBeforeRetry: 10,
            failoverReadOnly: false
        }
    };

    Client dbClient = check new (host, "root", "111", "mydb", 4406, option);
    int code = check dbClient->queryRow(sqlQuery);

    test:assertEquals(code, 100);

    io:println("Sleep");
    runtime:sleep(30);

    code = check dbClient->queryRow(sqlQuery);
    test:assertEquals(code, 100);
}
```

While the program is sleeping master node should be shut down to verify the failover.

## Reference

[MySQL Server Failover](https://dev.mysql.com/doc/connector-j/5.1/en/connector-j-config-failover.html)
