import ballerina/file;
import ballerina/test;

@test:AfterSuite
function cleanup() returns error? {
    // delete the tmp directory created for tests
    string tmpDirPath = "./tmp";
    if check file:test(tmpDirPath, file:EXISTS) {
        check file:remove(tmpDirPath, file:RECURSIVE);
    }
}
