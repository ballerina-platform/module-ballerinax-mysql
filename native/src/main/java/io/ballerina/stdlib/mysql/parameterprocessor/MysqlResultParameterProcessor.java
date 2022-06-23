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
package io.ballerina.stdlib.mysql.parameterprocessor;

import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.mysql.utils.ModuleUtils;
import io.ballerina.stdlib.sql.exception.DataError;
import io.ballerina.stdlib.sql.exception.TypeMismatchError;
import io.ballerina.stdlib.sql.parameterprocessor.DefaultResultParameterProcessor;
import io.ballerina.stdlib.sql.utils.Utils;

import java.math.BigDecimal;
import java.math.MathContext;
import java.sql.Time;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.LocalTime;

import static io.ballerina.runtime.api.utils.StringUtils.fromString;
import static io.ballerina.stdlib.time.util.Constants.ANALOG_GIGA;

/**
 * This class implements methods required convert mysql specific SQL types into ballerina types and
 * other methods that process the parameters of the result.
 *
 * @since 0.7.0
 */
public class MysqlResultParameterProcessor extends DefaultResultParameterProcessor {
    private static final MysqlResultParameterProcessor instance = new MysqlResultParameterProcessor();
    private static final BObject iteratorObject = ValueCreator.createObjectValue(
            ModuleUtils.getModule(), "CustomResultIterator");

    private MysqlResultParameterProcessor(){
    }

    public static MysqlResultParameterProcessor getInstance() {
        return instance;
    }

    @Override
    public Object convertTime(java.util.Date time, int sqlType, Type type) throws DataError {
        Utils.validatedInvalidFieldAssignment(sqlType, type, "SQL Date/Time");
        if (time instanceof Time) {
            Time sqlTime = (Time) time;
            switch (type.getTag()) {
                case TypeTags.STRING_TAG:
                    return fromString(sqlTime.toString());
                case TypeTags.OBJECT_TYPE_TAG:
                case TypeTags.RECORD_TYPE_TAG:
                    if (type.getName().equals(io.ballerina.stdlib.time.util.Constants.TIME_OF_DAY_RECORD)) {
                        LocalTime timeObj = sqlTime.toLocalTime();
                        BMap<BString, Object> timeMap = ValueCreator.createRecordValue(
                            io.ballerina.stdlib.time.util.ModuleUtils.getModule(),
                            io.ballerina.stdlib.time.util.Constants.TIME_OF_DAY_RECORD);
                        timeMap.put(StringUtils.fromString(io.ballerina.stdlib.time.util.Constants
                            .TIME_OF_DAY_RECORD_HOUR), timeObj.getHour());
                        timeMap.put(StringUtils.fromString(io.ballerina.stdlib.time.util.Constants
                            .TIME_OF_DAY_RECORD_MINUTE) , timeObj.getMinute());
                        BigDecimal second = new BigDecimal(timeObj.getSecond());
                        second = second.add(new BigDecimal(timeObj.getNano())
                            .divide(ANALOG_GIGA, MathContext.DECIMAL128));
                        timeMap.put(StringUtils.fromString(io.ballerina.stdlib.time.util.Constants
                            .TIME_OF_DAY_RECORD_SECOND), ValueCreator.createDecimalValue(second));
                        return timeMap;
                    } else {
                        throw new TypeMismatchError("SQL Time", type.getName(), "time:TimeOfDay");
                    }
                case TypeTags.INT_TAG:
                    return sqlTime.getTime();
            }
        }
        return null;
    }

    @Override
    public Object convertTimeStamp(java.util.Date timestamp, int sqlType, Type type) throws DataError {
        Utils.validatedInvalidFieldAssignment(sqlType, type, "SQL Date/Time");
        if (timestamp instanceof Timestamp) {
            Timestamp sqlTimestamp = (Timestamp) timestamp;
            switch (type.getTag()) {
                case TypeTags.STRING_TAG:
                    return fromString(sqlTimestamp.toString());
                case TypeTags.OBJECT_TYPE_TAG:
                case TypeTags.RECORD_TYPE_TAG:
                    if (type.getName().equalsIgnoreCase(io.ballerina.stdlib.time.util.Constants.CIVIL_RECORD)) {
                        LocalDateTime dateTimeObj = sqlTimestamp.toLocalDateTime();
                        BMap<BString, Object> civilMap = ValueCreator.createRecordValue(
                                io.ballerina.stdlib.time.util.ModuleUtils.getModule(),
                                io.ballerina.stdlib.time.util.Constants.CIVIL_RECORD);
                        civilMap.put(StringUtils.fromString(
                                io.ballerina.stdlib.time.util.Constants.DATE_RECORD_YEAR), dateTimeObj.getYear());
                        civilMap.put(StringUtils.fromString(
                                io.ballerina.stdlib.time.util.Constants.DATE_RECORD_MONTH),
                                dateTimeObj.getMonthValue());
                        civilMap.put(StringUtils.fromString(
                                io.ballerina.stdlib.time.util.Constants.DATE_RECORD_DAY),
                                dateTimeObj.getDayOfMonth());
                        civilMap.put(StringUtils.fromString(io.ballerina.stdlib.time.util.Constants
                                .TIME_OF_DAY_RECORD_HOUR), dateTimeObj.getHour());
                        civilMap.put(StringUtils.fromString(io.ballerina.stdlib.time.util.Constants
                                .TIME_OF_DAY_RECORD_MINUTE), dateTimeObj.getMinute());
                        BigDecimal second = new BigDecimal(dateTimeObj.getSecond());
                        second = second.add(new BigDecimal(dateTimeObj.getNano())
                                .divide(ANALOG_GIGA, MathContext.DECIMAL128));
                        civilMap.put(StringUtils.fromString(io.ballerina.stdlib.time.util.Constants
                                .TIME_OF_DAY_RECORD_SECOND), ValueCreator.createDecimalValue(second));
                        return civilMap;
                    } else {
                        throw new TypeMismatchError("SQL Timestamp", type.getName(), "time:Civil");
                    }
                case TypeTags.INT_TAG:
                    return sqlTimestamp.getTime();
                case TypeTags.INTERSECTION_TAG:
                    return Utils.createTimeStruct(timestamp.getTime());
            }
        }
        return null;
    }

    @Override
    public BObject getBalStreamResultIterator() {
        return iteratorObject;
    }

}
