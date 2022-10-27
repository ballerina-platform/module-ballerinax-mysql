# Copyright (c) 2020, WSO2 Inc. (http://wso2.com) All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM mysql:8.0.21

# Connection test case
COPY sql-scripts/connection/connections-test-data.sql /docker-entrypoint-initdb.d/
COPY sql-scripts/connection/secureSocket-test-data.sql /docker-entrypoint-initdb.d/

# Pool test case
COPY sql-scripts/pool/connection-pool-test-data.sql /docker-entrypoint-initdb.d/

# Execute test case
COPY sql-scripts/execute/execute-test-data.sql /docker-entrypoint-initdb.d/
COPY sql-scripts/execute/execute-params-test-data.sql /docker-entrypoint-initdb.d/

# Batch Execute test case
COPY sql-scripts/batchexecute/batch-execute-test-data.sql /docker-entrypoint-initdb.d/

# Negative test case
COPY sql-scripts/error/error-test-data.sql /docker-entrypoint-initdb.d/

# Query test case
COPY sql-scripts/query/simple-params-test-data.sql /docker-entrypoint-initdb.d/
COPY sql-scripts/query/numerical-test-data.sql /docker-entrypoint-initdb.d/
COPY sql-scripts/query/complex-test-data.sql /docker-entrypoint-initdb.d/

# Procedures test case
COPY sql-scripts/procedures/stored-procedure-test-data.sql /docker-entrypoint-initdb.d/

# Transactions test case
COPY sql-scripts/transaction/local-transaction-test-data.sql /docker-entrypoint-initdb.d/
COPY sql-scripts/transaction/xa-transaction-test-data-1.sql /docker-entrypoint-initdb.d/
COPY sql-scripts/transaction/xa-transaction-test-data-2.sql /docker-entrypoint-initdb.d/

#Schema Client test case
COPY sql-scripts/schema/schema-client-test-data.sql /docker-entrypoint-initdb.d/

RUN mkdir -p /etc/ssl
COPY keystore/server/ /etc/ssl/
RUN chown -R mysql /etc/ssl

COPY my.cnf /etc/

ENV MYSQL_ROOT_PASSWORD Test123#
