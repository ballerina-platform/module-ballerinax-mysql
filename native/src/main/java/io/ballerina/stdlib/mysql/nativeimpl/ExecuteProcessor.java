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
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.mysql.nativeimpl;

import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BObject;
import org.ballerinalang.sql.parameterprocessor.DefaultStatementParameterProcessor;

/**
 * This class contains methods for executing SQL queries.
 *
 * @since 1.2.0
 */
public class ExecuteProcessor {
    private ExecuteProcessor() {
    }

    public static Object nativeExecute(BObject client, Object paramSQLString) {
        return org.ballerinalang.sql.nativeimpl.ExecuteProcessor.nativeExecute(client, paramSQLString,
          DefaultStatementParameterProcessor.getInstance());
    }

    public static Object nativeBatchExecute(BObject client, BArray paramSQLStrings) {
        return org.ballerinalang.sql.nativeimpl.ExecuteProcessor.nativeBatchExecute(client, paramSQLStrings,
                DefaultStatementParameterProcessor.getInstance());    
    }
}
