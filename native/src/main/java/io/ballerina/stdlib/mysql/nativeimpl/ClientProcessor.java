/*
 *  Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

package io.ballerina.stdlib.mysql.nativeimpl;

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.mysql.Constants;
import io.ballerina.stdlib.mysql.Utils;
import io.ballerina.stdlib.sql.datasource.SQLDatasource;
import io.ballerina.stdlib.sql.utils.ErrorGenerator;

import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

/**
 * This class contains the utility methods for the mysql clients.
 *
 * @since 1.2.0
 */
public class ClientProcessor {

    public static Object createClient(BObject client, BMap<BString, Object> clientConfig,
                                      BMap<BString, Object> globalPool) {
        boolean serverFailover;
        List<String> secondaryHosts = new ArrayList<>();
        BMap<BString, Object> properties = ValueCreator.createMapValue();
        Properties poolProperties = null;
        String datasourceName = Constants.MYSQL_DATASOURCE_NAME;

        BMap options = clientConfig.getMapValue(Constants.ClientConfiguration.OPTIONS);
        if (options == null) {
            options = ValueCreator.createMapValue();
        }
        if (!options.isEmpty()) {
            properties = Utils.generateOptionsMap(options, properties);
            if (properties.containsKey(Constants.DatabaseProps.CONNECT_TIMEOUT)) {
                poolProperties = new Properties();
                poolProperties.setProperty(Constants.POOL_CONNECT_TIMEOUT,
                        properties.get(Constants.DatabaseProps.CONNECT_TIMEOUT).toString());
            }
            if (options.getBooleanValue(Constants.Options.USE_XA_DATASOURCE)) {
                datasourceName = Constants.MYSQL_XA_DATASOURCE_NAME;
            }
        }
        serverFailover = options.containsKey(Constants.Options.SERVER_FAILOVER);
        if (serverFailover) {
            BMap failover = options.getMapValue(Constants.Options.SERVER_FAILOVER);

            //secondaries is a mandatory param
            BArray secondaries = failover.getArrayValue(Constants.ServerFailover.SECONDARIES);
            if (!secondaries.isEmpty()) {
                for (long i = 0; i < secondaries.getLength(); i++) {
                    BArray tuple = (BArray) secondaries.get(i);
                    secondaryHosts.add(tuple.getBString(0).getValue() + ":" + tuple.getInt(1));
                }
            } else {
                return ErrorGenerator.getSQLApplicationError(
                        "Failover configuration 'secondaries' cannot be an empty array.");
            }

            if (failover.containsKey(Constants.ServerFailover.TIME_BEFORE_RETRY)) {
                properties.put(Constants.DatabaseProps.TIME_BEFORE_RETRY,
                        failover.getIntValue(Constants.ServerFailover.TIME_BEFORE_RETRY));
            }

            if (failover.containsKey(Constants.ServerFailover.QUERIES_BEFORE_RETRY)) {
                properties.put(Constants.DatabaseProps.QUERIES_BEFORE_RETRY,
                        failover.getIntValue(Constants.ServerFailover.QUERIES_BEFORE_RETRY));
            }

        }

        StringBuilder url = new StringBuilder("jdbc:mysql://")
                .append(clientConfig.getStringValue(Constants.ClientConfiguration.HOST));
        Long portValue = clientConfig.getIntValue(Constants.ClientConfiguration.PORT);
        if (portValue > 0) {
            url.append(":").append(portValue.intValue());
        }
        if (serverFailover) {
            url.append(",");
            int hostSize = secondaryHosts.size();
            for (int i = 0; i < hostSize - 1; i++) {
                url.append(secondaryHosts.get(i)).append(",");
            }
            url.append(secondaryHosts.get(hostSize - 1));
        }
        BString databaseVal = clientConfig.getStringValue(Constants.ClientConfiguration.DATABASE);
        String database = databaseVal == null ? null : databaseVal.getValue();
        if (database != null && !database.isEmpty()) {
            url.append("/").append(database);
        }

        BString userVal = clientConfig.getStringValue(Constants.ClientConfiguration.USER);
        String user = userVal == null ? null : userVal.getValue();
        BString passwordVal = clientConfig.getStringValue(Constants.ClientConfiguration.PASSWORD);
        String password = passwordVal == null ? null : passwordVal.getValue();

        BMap connectionPool = clientConfig.getMapValue(Constants.ClientConfiguration.CONNECTION_POOL_OPTIONS);

        SQLDatasource.SQLDatasourceParams sqlDatasourceParams = new SQLDatasource.SQLDatasourceParams()
                .setUrl(url.toString()).setUser(user)
                .setPassword(password)
                .setDatasourceName(datasourceName)
                .setOptions(properties)
                .setConnectionPool(connectionPool, globalPool)
                .setPoolProperties(poolProperties);

        return io.ballerina.stdlib.sql.nativeimpl.ClientProcessor.createClient(client, sqlDatasourceParams, true, true);
    }

    public static Object close(BObject client) {
        return io.ballerina.stdlib.sql.nativeimpl.ClientProcessor.close(client);
    }
}
