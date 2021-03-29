import ballerina/jballerina.java;
import ballerina/sql;

# The object type that is used as a structure to define a custom class with custom
# implementations for nextResult and getNextQueryResult in the PostgreSQL module.

public distinct class CustomResultIterator {
    *sql:CustomResultIterator;

    public isolated function nextResult(sql:ResultIterator iterator) returns record {}|sql:Error? = @java:Method {
        'class: "org.ballerinalang.mysql.utils.MysqlRecordIteratorUtils",
        paramTypes: ["io.ballerina.runtime.api.values.BObject", "io.ballerina.runtime.api.values.BObject"]
    } external;

    public isolated function getNextQueryResult(sql:ProcedureCallResult callResult) returns boolean|sql:Error = @java:Method {
        'class: "org.ballerinalang.mysql.utils.ProcedureCallResultUtils",
        paramTypes: ["io.ballerina.runtime.api.values.BObject", "io.ballerina.runtime.api.values.BObject"]
        } external;
}
