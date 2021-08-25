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

import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.mysql.Constants;
import io.ballerina.stdlib.mysql.Utils;
import io.ballerina.stdlib.sql.datasource.SQLDatasource;

import java.util.Properties;

/**
 * This class contains the utility methods for the mysql clients.
 *
 * @since 1.2.0
 */
public class ClientProcessor {

    public static Object createClient(BObject client, BMap<BString, Object> clientConfig,
                                      BMap<BString, Object> globalPool) {
        String url = "jdbc:mysql://" + clientConfig.getStringValue(Constants.ClientConfiguration.HOST);
        Long portValue = clientConfig.getIntValue(Constants.ClientConfiguration.PORT);
        if (portValue > 0) {
            url += ":" + portValue.intValue();
        }
        BString userVal = clientConfig.getStringValue(Constants.ClientConfiguration.USER);
        String user = userVal == null ? null : userVal.getValue();
        BString passwordVal = clientConfig.getStringValue(Constants.ClientConfiguration.PASSWORD);
        String password = passwordVal == null ? null : passwordVal.getValue();
        BString databaseVal = clientConfig.getStringValue(Constants.ClientConfiguration.DATABASE);
        String database = databaseVal == null ? null : databaseVal.getValue();
        if (database != null && !database.isEmpty()) {
            url += "/" + database;
        }
        BMap options = clientConfig.getMapValue(Constants.ClientConfiguration.OPTIONS);
        BMap properties = null;
        Properties poolProperties = null;
        if (options != null) {
            properties = Utils.generateOptionsMap(options);
            Object connectTimeout = properties.get(Constants.DatabaseProps.CONNECT_TIMEOUT);
            if (connectTimeout != null) {
                poolProperties = new Properties();
                poolProperties.setProperty(Constants.POOL_CONNECT_TIMEOUT, connectTimeout.toString());
            }
        }

        BMap connectionPool = clientConfig.getMapValue(Constants.ClientConfiguration.CONNECTION_POOL_OPTIONS);

        String datasourceName = Constants.MYSQL_DATASOURCE_NAME;
        if (options != null && options.getBooleanValue(Constants.Options.USE_XA_DATASOURCE)) {
            datasourceName = Constants.MYSQL_XA_DATASOURCE_NAME;
        }

        SQLDatasource.SQLDatasourceParams sqlDatasourceParams = new SQLDatasource.SQLDatasourceParams()
                .setUrl(url).setUser(user)
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
