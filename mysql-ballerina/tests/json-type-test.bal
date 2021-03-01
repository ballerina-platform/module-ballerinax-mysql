import ballerina/test;

string jsonTypeDB = "JSON_TYPE_DB";

type JsonTable record {|
    int id;
    json json_value;
|};

type JsonTableValue record {
    JsonTable value;
};

@test:Config {
    groups: ["json-type"]
}
function testGetJsonType() {
    Client dbClient = checkpanic new (host, user, password, jsonTypeDB, port);
    stream<record{}, error> streamData =
        dbClient->query("Select * from JSON_TYPE_DB.JsonTable", JsonTable);
    stream<JsonTable, error> jsonStream = <stream<JsonTable, error>> streamData;

    JsonTable expectedData = {
        id: 1,
        json_value: {"key":"value"}
    };

    JsonTable gotValue = {
        id: -1,
        json_value: {"diff-key":"diff-value"}
    };

    record {|JsonTable value;|}|error? accValue = checkpanic jsonStream.next();
    checkpanic streamData.close();
    if accValue is JsonTableValue {
        gotValue = accValue.value;
    }
    checkpanic dbClient.close();

    test:assertEquals(gotValue, expectedData, "Expected data did not match.");
}
