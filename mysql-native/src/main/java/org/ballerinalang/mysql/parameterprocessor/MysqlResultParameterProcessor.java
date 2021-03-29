package org.ballerinalang.mysql.parameterprocessor;

import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import org.ballerinalang.sql.Constants;
import org.ballerinalang.sql.exception.ApplicationError;
import org.ballerinalang.sql.parameterprocessor.DefaultResultParameterProcessor;
import org.ballerinalang.sql.utils.Utils;

import java.math.BigDecimal;
import java.math.MathContext;
import java.sql.Time;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Date;

import static io.ballerina.runtime.api.utils.StringUtils.fromString;
import static org.ballerinalang.stdlib.time.util.Constants.ANALOG_GIGA;

public class MysqlResultParameterProcessor extends DefaultResultParameterProcessor {
    private static final Object lock = new Object();
    private static volatile MysqlResultParameterProcessor instance;

    public MysqlResultParameterProcessor() {
    }
    public static MysqlResultParameterProcessor getInstance() {
        if (instance == null) {
            synchronized(lock) {
                if (instance == null) {
                    instance = new MysqlResultParameterProcessor();
                }
            }
        }

        return instance;
    }

    @Override
    public Object convertTime(Date time, int sqlType, Type type) throws ApplicationError {
        Utils.validatedInvalidFieldAssignment(sqlType, type, "SQL Date/Time");
        if (time != null) {
            switch (type.getTag()) {
                case TypeTags.STRING_TAG:
                    return fromString(time.toString());
                case TypeTags.OBJECT_TYPE_TAG:
                case TypeTags.RECORD_TYPE_TAG:
                    if (time instanceof Time) {
                        LocalTime timeObj = ((Time) time).toLocalTime();
                        BMap<BString, Object> timeMap = ValueCreator.createRecordValue(
                                org.ballerinalang.stdlib.time.util.ModuleUtils.getModule(),
                                org.ballerinalang.stdlib.time.util.Constants.TIME_OF_DAY_RECORD);
                        timeMap.put(StringUtils.fromString(org.ballerinalang.stdlib.time.util.Constants
                                .TIME_OF_DAY_RECORD_HOUR), timeObj.getHour());
                        timeMap.put(StringUtils.fromString(org.ballerinalang.stdlib.time.util.Constants
                                .TIME_OF_DAY_RECORD_MINUTE) , timeObj.getMinute());
                        BigDecimal second = new BigDecimal(timeObj.getSecond());
                        second = second.add(new BigDecimal(timeObj.getNano())
                                .divide(ANALOG_GIGA, MathContext.DECIMAL128));
                        timeMap.put(StringUtils.fromString(org.ballerinalang.stdlib.time.util.Constants
                                .TIME_OF_DAY_RECORD_SECOND), ValueCreator.createDecimalValue(second));
                        return timeMap;
                    } else {
                        return toString();
                    }
                case TypeTags.INT_TAG:
                    return time.getTime();
            }
        }
        return null;
    }

    @Override
    public Object convertTimeStamp(Date timestamp, int sqlType, Type type) throws ApplicationError {
        Utils.validatedInvalidFieldAssignment(sqlType, type, "SQL Date/Time");
        if (timestamp != null) {
            switch (type.getTag()) {
                case TypeTags.STRING_TAG:
                    return fromString(timestamp.toString());
                case TypeTags.OBJECT_TYPE_TAG:
                case TypeTags.RECORD_TYPE_TAG:
                    if (type.getName().equalsIgnoreCase(Constants.SqlTypes.DATETIME)
                            && timestamp instanceof Timestamp) {
                        LocalDateTime dateTimeObj = ((Timestamp) timestamp).toLocalDateTime();
                        BMap<BString, Object> civilMap = ValueCreator.createRecordValue(
                                org.ballerinalang.stdlib.time.util.ModuleUtils.getModule(),
                                org.ballerinalang.stdlib.time.util.Constants.CIVIL_RECORD);
                        civilMap.put(StringUtils.fromString(
                                org.ballerinalang.stdlib.time.util.Constants.DATE_RECORD_YEAR), dateTimeObj.getYear());
                        civilMap.put(StringUtils.fromString(
                                org.ballerinalang.stdlib.time.util.Constants.DATE_RECORD_MONTH),
                                dateTimeObj.getMonthValue());
                        civilMap.put(StringUtils.fromString(
                                org.ballerinalang.stdlib.time.util.Constants.DATE_RECORD_DAY),
                                dateTimeObj.getDayOfMonth());
                        civilMap.put(StringUtils.fromString(org.ballerinalang.stdlib.time.util.Constants
                                .TIME_OF_DAY_RECORD_HOUR), dateTimeObj.getHour());
                        civilMap.put(StringUtils.fromString(org.ballerinalang.stdlib.time.util.Constants
                                .TIME_OF_DAY_RECORD_MINUTE), dateTimeObj.getMinute());
                        BigDecimal second = new BigDecimal(dateTimeObj.getSecond());
                        second = second.add(new BigDecimal(dateTimeObj.getNano())
                                .divide(ANALOG_GIGA, MathContext.DECIMAL128));
                        civilMap.put(StringUtils.fromString(org.ballerinalang.stdlib.time.util.Constants
                                .TIME_OF_DAY_RECORD_SECOND), ValueCreator.createDecimalValue(second));
                        return civilMap;
                    } else {
                        return Utils.createTimeStruct(timestamp.getTime());
                    }
                case TypeTags.INT_TAG:
                    return timestamp.getTime();
            }
        }
        return null;
    }
}
