import ballerina/jballerina.java;

isolated function init() {
    setModule();
}

isolated function setModule() = @java:Method {
    'class: "org.ballerinalang.mysql.utils.ModuleUtils"
} external;
