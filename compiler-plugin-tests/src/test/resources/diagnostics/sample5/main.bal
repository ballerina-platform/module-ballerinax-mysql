// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerinax/mysql;
import ballerinax/mysql.driver as _;

# sql:ConnectionPool parameter record with default optimized values
#
# + maxOpenConnections -   The maximum open connections
# + maxConnectionLifeTime - The maximum lifetime of a connection
# + minIdleConnections - The minimum idle time of a connection
type SqlConnectionPoolConfig record {|
    int maxOpenConnections = 10;
    decimal maxConnectionLifeTime = 180;
    int minIdleConnections = 5;
|};

# mysql:Options parameter record with default optimized values
#
# + connectTimeout - Timeout to be used when establishing a connection
type MysqlOptionsConfig record {|
    decimal connectTimeout = 10;
|};

# [Configurable] Allocation MySQL Database
#
# + hostname - database hostname
# + username - database username
# + password - database password
# + database - database name
# + port - database port
# + connectionPool - sql:ConnectionPool configurations, type: SqlConnectionPoolConfig
# + mysqlOptions - mysql:Options configurations, type: MysqlOptionsConfig
type AllocationDatabase record {|
    string hostname;
    string username;
    string password;
    string database;
    int port = 3306;
    SqlConnectionPoolConfig connectionPool;
    MysqlOptionsConfig mysqlOptions;
|};

configurable AllocationDatabase allocationDatabase = ?;

final mysql:Client allocationDbClient = check new (
    host = allocationDatabase.hostname,
    user = allocationDatabase.username,
    password = allocationDatabase.password,
    port = allocationDatabase.port,
    database = allocationDatabase.database,
    connectionPool = {
        ...allocationDatabase.connectionPool
    },
    options = {
        ssl: {
            mode: mysql:SSL_PREFERRED
        },
        connectTimeout: allocationDatabase.mysqlOptions.connectTimeout
    }
);