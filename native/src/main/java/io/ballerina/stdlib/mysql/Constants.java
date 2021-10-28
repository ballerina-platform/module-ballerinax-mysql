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
package io.ballerina.stdlib.mysql;

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BString;

/**
 * Constants for JDBC client.
 *
 * @since 1.2.0
 */
public final class Constants {

    private Constants(){
    }

    /**
     * Constants for Client Configs.
     */
    public static final class ClientConfiguration {

        private ClientConfiguration() {
        }

        public static final BString HOST = StringUtils.fromString("host");
        public static final BString PORT = StringUtils.fromString("port");
        public static final BString USER = StringUtils.fromString("user");
        public static final BString PASSWORD = StringUtils.fromString("password");
        public static final BString DATABASE = StringUtils.fromString("database");
        public static final BString OPTIONS = StringUtils.fromString("options");
        public static final BString CONNECTION_POOL_OPTIONS = StringUtils.fromString("connectionPool");
    }

    /**
     * Constants for database options.
     */
    public static final class Options {

        private Options() {
        }

        public static final BString SSL = StringUtils.fromString("ssl");
        public static final BString USE_XA_DATASOURCE = StringUtils.fromString("useXADatasource");
        public static final BString CONNECT_TIMEOUT = StringUtils.fromString("connectTimeout");
        public static final BString SOCKET_TIMEOUT = StringUtils.fromString("socketTimeout");
        public static final BString ALLOW_PUBLICKEY_RETRIEVAL = StringUtils.fromString("allowPublicKeyRetrieval");
        public static final BString SERVER_TIMEZONE = StringUtils.fromString("serverTimezone");
        public static final BString ACCESS_TO_PROCEDURE_BODIES = StringUtils.fromString("noAccessToProcedureBodies");
        public static final BString SERVER_FAILOVER = StringUtils.fromString("failover");

    }

    /**
     * Constants for ssl configuration.
     */
    public static final class SecureSocket {

        private SecureSocket() {
        }

        public static final BString MODE = StringUtils.fromString("mode");
        public static final BString CLIENT_KEY = StringUtils.fromString("key");
        public static final BString CLIENT_CERT = StringUtils.fromString("cert");

        /**
        * Constants for processing ballerina `crypto:KeyStore`.
        */
        public static final class CryptoKeyStoreRecord {

            private CryptoKeyStoreRecord() {
            }

            public static final BString KEY_STORE_RECORD_PATH_FIELD = StringUtils.fromString("path");
            public static final BString KEY_STORE_RECORD_PASSWORD_FIELD = StringUtils.fromString("password");
        }

        /**
        * Constants for processing ballerina `crypto:TrustStore`.
        */
        public static final class CryptoTrustStoreRecord {

            private CryptoTrustStoreRecord() {
            }

            public static final BString TRUST_STORE_RECORD_PATH_FIELD = StringUtils.fromString("path");
            public static final BString TRUST_STORE_RECORD_PASSWORD_FIELD = StringUtils.fromString("password");
        }
    }

    /**
     * Constants for Server Failover.
     */
    public static final class ServerFailover {

        private ServerFailover() {
        }

        public static final BString SECONDARIES = StringUtils.fromString("secondaries");
        public static final BString TIME_BEFORE_RETRY = StringUtils.fromString("timeBeforeRetry");
        public static final BString QUERIES_BEFORE_RETRY = StringUtils.fromString("queriesBeforeRetry");
        public static final BString FAILOVER_READ_ONLY = StringUtils.fromString("failOverReadOnly");
    }

    /**
    * Constants for database specific properties.
    */
    public static final class DatabaseProps {

        private DatabaseProps() {
        }

        public static final BString SSL_MODE = StringUtils.fromString("sslMode");
        public static final BString SSL_MODE_DISABLED = StringUtils.fromString("DISABLED");

        public static final BString KEYSTORE_TYPE_PKCS12 = StringUtils.fromString("PKCS12");
        public static final BString CLIENT_KEYSTORE_URL = StringUtils.fromString("clientCertificateKeyStoreUrl");
        public static final BString CLIENT_KEYSTORE_PASSWORD = StringUtils.fromString(
            "clientCertificateKeyStorePassword");
        public static final BString CLIENT_KEYSTORE_TYPE = StringUtils.fromString("clientCertificateKeyStoreType");
        public static final BString TRUST_KEYSTORE_URL = StringUtils.fromString("trustCertificateKeyStoreUrl");
        public static final BString TRUST_KEYSTORE_PASSWORD = StringUtils.fromString(
            "trustCertificateKeyStorePassword");
        public static final BString TRUST_KEYSTORE_TYPE = StringUtils.fromString("trustCertificateKeyStoreType");

        public static final BString CONNECT_TIMEOUT = StringUtils.fromString("connectTimeout");
        public static final BString SOCKET_TIMEOUT = StringUtils.fromString("socketTimeout");
        public static final BString ALLOW_PUBLICKEY_RETRIEVAL = StringUtils.fromString("allowPublicKeyRetrieval");
        public static final BString SERVER_TIMEZONE = StringUtils.fromString("serverTimezone");
        public static final BString ACCESS_TO_PROCEDURE_BODIES = StringUtils.fromString("noAccessToProcedureBodies");
        public static final BString TIME_BEFORE_RETRY = StringUtils.fromString("secondsBeforeRetryMaster");
        public static final BString QUERIES_BEFORE_RETRY = StringUtils.fromString("queriesBeforeRetryMaster");
        public static final BString FAILOVER_READONLY = StringUtils.fromString("failOverReadOnly");

    }

    public static final String MYSQL_DATASOURCE_NAME = "com.mysql.cj.jdbc.MysqlDataSource";
    public static final String MYSQL_XA_DATASOURCE_NAME = "com.mysql.cj.jdbc.MysqlXADataSource";
    public static final String FILE = "file:";
    public static final String POOL_CONNECT_TIMEOUT = "ConnectionTimeout";
}
