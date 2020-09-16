/*
 * Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.ballerinalang.mysql;

import org.ballerinalang.jvm.api.BStringUtils;
import org.ballerinalang.jvm.api.values.BString;

/**
 * Constants for JDBC client.
 *
 * @since 1.2.0
 */
public final class Constants {
    /**
     * Constants for Client Configs.
     */
    public static final class ClientConfiguration {
        static final BString HOST = BStringUtils.fromString("host");
        static final BString PORT = BStringUtils.fromString("port");
        static final BString USER = BStringUtils.fromString("user");
        static final BString PASSWORD = BStringUtils.fromString("password");
        static final BString DATABASE = BStringUtils.fromString("database");
        static final BString OPTIONS = BStringUtils.fromString("options");
        static final BString CONNECTION_POOL_OPTIONS = BStringUtils.fromString("connectionPool");
    }

    /**
     * Constants for database options.
     */
    public static final class Options {
        static final BString SSL = BStringUtils.fromString("ssl");
        static final BString USE_XA_DATASOURCE = BStringUtils.fromString("useXADatasource");
        static final BString CONNECT_TIMEOUT_SECONDS = BStringUtils.fromString("connectTimeoutInSeconds");
        static final BString SOCKET_TIMEOUT_SECONDS = BStringUtils.fromString("socketTimeoutInSeconds");
    }

    /**
     * Constants for ssl configuration.
     */
    static final class SSLConfig {
        static final BString MODE = BStringUtils.fromString("mode");
        static final String VERIFY_CERT_MODE = "VERIFY_CERT";
        static final BString CLIENT_CERT_KEYSTORE = BStringUtils.fromString("clientCertKeystore");
        static final BString TRUST_CERT_KEYSTORE = BStringUtils.fromString("trustCertKeystore");
        // The following constants are used to process ballerina `crypto:KeyStore`
        static final class CryptoKeyStoreRecord {
            static final BString KEY_STORE_RECORD_PATH_FIELD = BStringUtils.fromString("path");
            static final BString KEY_STORE_RECORD_PASSWORD_FIELD = BStringUtils.fromString("password");
        }
    }

    static final class DatabaseProps {
        static final BString SSL_MODE = BStringUtils.fromString("sslMode");
        static final BString SSL_MODE_DISABLED = BStringUtils.fromString("DISABLED");
        static final BString SSL_MODE_VERIFY_CA = BStringUtils.fromString("VERIFY_CA");

        static final BString KEYSTORE_TYPE_PKCS12 = BStringUtils.fromString("PKCS12");
        static final BString CLIENT_KEYSTORE_URL = BStringUtils.fromString("clientCertificateKeyStoreUrl");
        static final BString CLIENT_KEYSTORE_PASSWORD = BStringUtils.fromString("clientCertificateKeyStorePassword");
        static final BString CLIENT_KEYSTORE_TYPE = BStringUtils.fromString("clientCertificateKeyStoreType");
        static final BString TRUST_KEYSTORE_URL = BStringUtils.fromString("trustCertificateKeyStoreUrl");
        static final BString TRUST_KEYSTORE_PASSWORD = BStringUtils.fromString("trustCertificateKeyStorePassword");
        static final BString TRUST_KEYSTORE_TYPE = BStringUtils.fromString("trustCertificateKeyStoreType");

        static final BString CONNECT_TIMEOUT = BStringUtils.fromString("connectTimeout");
        static final BString SOCKET_TIMEOUT = BStringUtils.fromString("socketTimeout");
    }

    static final String MYSQL_DATASOURCE_NAME = "com.mysql.cj.jdbc.MysqlDataSource";
    static final String MYSQL_XA_DATASOURCE_NAME = "com.mysql.cj.jdbc.MysqlXADataSource";
    static final String FILE = "file:";
    static final String POOL_CONNECT_TIMEOUT = "ConnectionTimeout";
}
