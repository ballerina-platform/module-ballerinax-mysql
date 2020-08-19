// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/system;
import ballerina/test;
import ballerina/filepath;

string absolutePath = check filepath:absolute(<@untainted> "src/mysql/tests/resources");

@test:BeforeSuite
function beforeSuit() returns @tainted system:Error|error? {
    
    system:Process process = check system:exec("docker", {}, absolutePath, "build", "-t", "ballerina-mysql", ".");
    int exitCode = check process.waitForExit();
    test:assertExactEquals(exitCode, 0, msg = "Docker image 'ballerina-mysql' creation failed!");

    process = check system:exec("docker", {}, absolutePath, 
                    "run", "--rm", "-d", "--name", "ballerina-mysql", "-p", "3305:3306", "-t", "ballerina-mysql");
    exitCode = check process.waitForExit();
    test:assertExactEquals(exitCode, 0, msg = "Docker container 'ballerina-mysql' creation failed!");

}

@test:Config {}
function testDocker() {
    io:println("Verify docker commands.");
}

@test:AfterSuite {}
function afterSuite() returns @tainted system:Error|error? {
    system:Process process = check system:exec("docker", {}, absolutePath, "stop", "ballerina-mysql");
    int exitCode = check process.waitForExit();
    test:assertExactEquals(exitCode, 0, msg = "Docker container 'ballerina-mysql' stop failed!");
}
