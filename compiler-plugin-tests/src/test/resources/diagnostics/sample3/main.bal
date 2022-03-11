// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerinax/mysql;

public function main() {

    int id = 5;

    int|mysql:Options pool1 = 5;

    int|mysql:Options pool2 = {
        connectTimeout: -2,
        socketTimeout: -3
    };

    mysql:Options|int pool3 = {
        connectTimeout: -2,
        socketTimeout: -3
    };

    mysql:Options pool4 = {
        connectTimeout: -2,
        socketTimeout: -3,
        failoverConfig: {
            failoverServers:[],
            timeBeforeRetry: -2,
            queriesBeforeRetry: 0
        }
    };

    mysql:Options pool5 = {
        failoverConfig: {
            failoverServers:[],
            queriesBeforeRetry: 0
        }
    };

    mysql:FailoverConfig pool6 = {
        failoverServers:[],
        queriesBeforeRetry: -2,
        timeBeforeRetry: -4
    };

    mysql:FailoverConfig pool7 = {
        failoverServers:[],
        timeBeforeRetry: -8
    };

}
