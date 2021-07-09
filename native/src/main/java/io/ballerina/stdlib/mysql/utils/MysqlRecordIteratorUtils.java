/*
 *  Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
package io.ballerina.stdlib.mysql.utils;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.stdlib.mysql.parameterprocessor.MysqlResultParameterProcessor;
import org.ballerinalang.sql.utils.RecordIteratorUtils;

/**
 * This class provides functionality for the `RecordIterator` to iterate through the MySQL result set.
 */
public class MysqlRecordIteratorUtils extends RecordIteratorUtils {

    public static Object nextResult(BObject mysqlRecordIterator, BObject recordIterator) {
        return nextResult(recordIterator, MysqlResultParameterProcessor.getInstance());
    }
}
