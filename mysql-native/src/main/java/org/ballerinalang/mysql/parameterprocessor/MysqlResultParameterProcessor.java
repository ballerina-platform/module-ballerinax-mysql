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
package org.ballerinalang.mysql.parameterprocessor;

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.types.StructureType;
import io.ballerina.runtime.api.values.BObject;
import org.ballerinalang.mysql.utils.ModuleUtils;
import org.ballerinalang.sql.Constants;
import org.ballerinalang.sql.parameterprocessor.DefaultResultParameterProcessor;
import org.ballerinalang.sql.utils.ColumnDefinition;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Calendar;
import java.util.List;
import java.util.TimeZone;

/**
 * This class implements methods required convert mysql specific SQL types into ballerina types and
 * other methods that process the parameters of the result.
 *
 * @since 0.7.0
 */
public class MysqlResultParameterProcessor extends DefaultResultParameterProcessor {
    private static final MysqlResultParameterProcessor instance = new MysqlResultParameterProcessor();
    private static volatile BObject iteratorObject = ValueCreator.createObjectValue(
            ModuleUtils.getModule(), "CustomResultIterator", new Object[0]);
    private static final Calendar calendar = Calendar
            .getInstance(TimeZone.getDefault());

    private MysqlResultParameterProcessor(){

    }

    public static MysqlResultParameterProcessor getInstance() {
        return instance;
    }

    @Override
    public BObject createRecordIterator(ResultSet resultSet, Statement statement, Connection connection,
                                        List<ColumnDefinition> columnDefinitions, StructureType streamConstraint) {
        BObject iteratorObject = this.getIteratorObject();
        BObject resultIterator = ValueCreator.createObjectValue(org.ballerinalang.sql.utils.ModuleUtils.getModule(),
                org.ballerinalang.sql.Constants.RESULT_ITERATOR_OBJECT, new Object[]{null, iteratorObject});
        resultIterator.addNativeData(org.ballerinalang.sql.Constants.RESULT_SET_NATIVE_DATA_FIELD, resultSet);
        resultIterator.addNativeData(org.ballerinalang.sql.Constants.STATEMENT_NATIVE_DATA_FIELD, statement);
        resultIterator.addNativeData(org.ballerinalang.sql.Constants.CONNECTION_NATIVE_DATA_FIELD, connection);
        resultIterator.addNativeData(org.ballerinalang.sql.Constants.COLUMN_DEFINITIONS_DATA_FIELD, columnDefinitions);
        resultIterator.addNativeData(org.ballerinalang.sql.Constants.RECORD_TYPE_DATA_FIELD, streamConstraint);
        return resultIterator;
    }

    @Override
    public void populateDate(CallableStatement statement, BObject parameter, int paramIndex) throws SQLException {
        parameter.addNativeData(Constants.ParameterObject.VALUE_NATIVE_DATA, statement.getDate(paramIndex, calendar));
    }

    @Override
    public void populateTime(CallableStatement statement, BObject parameter, int paramIndex) throws SQLException {
        parameter.addNativeData(Constants.ParameterObject.VALUE_NATIVE_DATA, statement.getTime(paramIndex, calendar));
    }

    @Override
    public void populateTimestamp(CallableStatement statement, BObject parameter, int paramIndex) throws SQLException {
        parameter.addNativeData(Constants.ParameterObject.VALUE_NATIVE_DATA,
                statement.getTimestamp(paramIndex, calendar));
    }

    @Override
    public BObject getCustomProcedureCallObject() {
        return this.getIteratorObject();
    }

    @Override
    protected BObject getIteratorObject() {
        return iteratorObject;
    }
}
