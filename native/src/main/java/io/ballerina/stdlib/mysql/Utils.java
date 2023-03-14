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
package io.ballerina.stdlib.mysql;

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import static io.ballerina.stdlib.mysql.Constants.Options.ACCESS_TO_PROCEDURE_BODIES;

/**
 * This class includes utility functions.
 *
 * @since 1.2.0
 */
public class Utils {

    public static void processOptionsMap(BMap mysqlOptions, BMap<BString, Object> options) {
        addSSLOptions(mysqlOptions.getMapValue(Constants.Options.SSL), options);

        long connectTimeout = getTimeout(mysqlOptions.get(Constants.Options.CONNECT_TIMEOUT));
        if (connectTimeout > 0) {
            options.put(Constants.DatabaseProps.CONNECT_TIMEOUT, connectTimeout);
        }

        long socketTimeout = getTimeout(mysqlOptions.get(Constants.Options.SOCKET_TIMEOUT));
        if (socketTimeout > 0) {
            options.put(Constants.DatabaseProps.SOCKET_TIMEOUT, socketTimeout);
        }

        BString serverTimezone = mysqlOptions.getStringValue(Constants.Options.SERVER_TIMEZONE);
        if (serverTimezone != null) {
            options.put(Constants.DatabaseProps.SERVER_TIMEZONE, serverTimezone);
        }

        boolean noAccessToProcedureBodies = mysqlOptions.getBooleanValue(ACCESS_TO_PROCEDURE_BODIES);
        options.put(Constants.DatabaseProps.ACCESS_TO_PROCEDURE_BODIES, noAccessToProcedureBodies);
    }

    public static long getTimeout(Object secondsDecimal) {
        if (secondsDecimal instanceof BDecimal) {
            BDecimal timeoutSec = (BDecimal) secondsDecimal;
            if (timeoutSec.floatValue() > 0) {
                return Double.valueOf(timeoutSec.floatValue() * 1000).longValue();
            }
        }
        return -1;
    }

    public static void addSSLOptions(BMap secureSocket, BMap<BString, Object> options) {
        if (secureSocket == null) {
            options.put(Constants.DatabaseProps.SSL_MODE, Constants.DatabaseProps.SSL_MODE_DISABLED);
        } else {
            BString mode = secureSocket.getStringValue(Constants.SecureSocket.MODE);
            options.put(Constants.DatabaseProps.SSL_MODE, mode);

            BMap clientCertKeystore = secureSocket.getMapValue(Constants.SecureSocket.CLIENT_KEY);
            if (clientCertKeystore != null) {
                options.put(Constants.DatabaseProps.CLIENT_KEYSTORE_URL, StringUtils.fromString(
                        Constants.FILE + clientCertKeystore.getStringValue(
                                Constants.SecureSocket.CryptoKeyStoreRecord.KEY_STORE_RECORD_PATH_FIELD)));
                options.put(Constants.DatabaseProps.CLIENT_KEYSTORE_PASSWORD,
                        clientCertKeystore.getStringValue(
                                Constants.SecureSocket.CryptoKeyStoreRecord.KEY_STORE_RECORD_PASSWORD_FIELD));
                options.put(Constants.DatabaseProps.CLIENT_KEYSTORE_TYPE,
                        Constants.DatabaseProps.KEYSTORE_TYPE_PKCS12);
            }

            BMap trustCertKeystore = secureSocket.getMapValue(Constants.SecureSocket.CLIENT_CERT);
            if (trustCertKeystore != null) {
                options.put(Constants.DatabaseProps.TRUST_KEYSTORE_URL,
                        StringUtils.fromString(Constants.FILE + trustCertKeystore.getStringValue(
                                Constants.SecureSocket.CryptoTrustStoreRecord.TRUST_STORE_RECORD_PATH_FIELD)));
                options.put(Constants.DatabaseProps.TRUST_KEYSTORE_PASSWORD,
                        trustCertKeystore.getStringValue(
                                Constants.SecureSocket.CryptoTrustStoreRecord.TRUST_STORE_RECORD_PASSWORD_FIELD));
                options.put(Constants.DatabaseProps.TRUST_KEYSTORE_TYPE,
                        Constants.DatabaseProps.KEYSTORE_TYPE_PKCS12);
            }

            boolean allowPublicKeyRetrieval = secureSocket.getBooleanValue(
                    Constants.Options.ALLOW_PUBLIC_KEY_RETRIEVAL);
            options.put(Constants.DatabaseProps.ALLOW_PUBLIC_KEY_RETRIEVAL, allowPublicKeyRetrieval);
        }
    }
}
