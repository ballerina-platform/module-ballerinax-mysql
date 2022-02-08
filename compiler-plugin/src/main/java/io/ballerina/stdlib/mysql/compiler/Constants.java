/*
 * Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package io.ballerina.stdlib.mysql.compiler;

/**
 * Constants for MySQL compiler plugin.
 */
public class Constants {
    public static final String BALLERINAX = "ballerinax";
    public static final String MYSQL = "mysql";
    public static final String CONNECTION_POOL_PARAM_NAME = "connectionPool";
    public static final String OPTIONS_PARAM_NAME = "options";

    /**
     * Constants related to Client object.
     */
    public static class Client {
        public static final String CLIENT = "Client";
        public static final String QUERY = "query";
        public static final String QUERY_ROW = "queryRow";
    }

    /**
     * Constants for fields in sql:ConnectionPool.
     */
    public static class ConnectionPool {
        public static final String MAX_OPEN_CONNECTIONS = "maxOpenConnections";
        public static final String MAX_CONNECTION_LIFE_TIME = "maxConnectionLifeTime";
        public static final String MIN_IDLE_CONNECTIONS = "minIdleConnections";
    }

    /**
     * Constants for fields in mysql:Options.
     */
    public static class Options {
        public static final String NAME = "Options";
        public static final String CONNECTION_TIMEOUT = "connectTimeout";
        public static final String SOCKET_TIMEOUT = "socketTimeout";
        public static final String FAILOVER = "failoverConfig";
    }

    /**
     * Constants for fields in mysql:FailoverConfig.
     */
    public static class FailOver {
        public static final String NAME = "FailoverConfig";
        public static final String TIME_BEFORE_RETRY = "timeBeforeRetry";
        public static final String QUERY_BEFORE_RETRY = "queriesBeforeRetry";
    }

    public static final String UNNECESSARY_CHARS_REGEX = "\"|\\n";

}
