/*
 * Copyright (c) 2023, WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.mysql.parameterprocessor;

import io.ballerina.stdlib.sql.exception.DataError;
import io.ballerina.stdlib.sql.parameterprocessor.DefaultStatementParameterProcessor;

import java.sql.Connection;
import java.sql.PreparedStatement;

/**
 *  This class has implementation of methods required process the MySQL Prepared Statement.
 *  Setters are used to set designated parameters to the PreparedStatement.
 */
public class MysqlStatementParameterProcessor extends DefaultStatementParameterProcessor {
    private static final MysqlStatementParameterProcessor instance = new MysqlStatementParameterProcessor();

    private MysqlStatementParameterProcessor(){
    }

    public static MysqlStatementParameterProcessor getInstance() {
        return instance;
    }

    @Override
    protected void setVarcharArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setCharArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setNVarcharArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setBitArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setBooleanArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setIntegerArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setBigIntArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setSmallIntArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setFloatArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setRealArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setDoubleArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setNumericArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setDecimalArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setBinaryArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setVarBinaryArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setDateTimeArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setTimestampArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setDateArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }

    @Override
    protected void setTimeArray(Connection conn, PreparedStatement preparedStatement, int index, Object value)
            throws DataError {
        throw new DataError("MySQL does not support ARRAY data type.");
    }
}
