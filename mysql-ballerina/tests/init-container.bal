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
import ballerina/file;
import ballerina/runtime;

string resourcePath = check file:getAbsolutePath("src/mysql/tests/resources");

string host = "localhost";
string user = "root";
string password = "Test123#";
int port = 3305;

@test:BeforeSuite
function beforeSuite() {
    
    system:Process process = checkpanic system:exec("docker", {}, resourcePath, "build", "-t", "ballerina-mysql", ".");
    int exitCode = checkpanic process.waitForExit();
    test:assertExactEquals(exitCode, 0, "Docker image 'ballerina-mysql' creation failed!");
 
    process = checkpanic system:exec("docker", {}, resourcePath, 
                    "run", "--rm", "-d", "--name", "ballerina-mysql", "-p", "3305:3306", "-t", "ballerina-mysql");
    exitCode = checkpanic process.waitForExit();
    test:assertExactEquals(exitCode, 0, "Docker container 'ballerina-mysql' creation failed!");
    runtime:sleep(50000);

    int healthCheck = 1;
    int counter = 0;
    while(healthCheck > 0 && counter < 12) {
        runtime:sleep(10000);
        process = checkpanic system:exec("docker", {}, resourcePath, 
                    "exec", "ballerina-mysql", "mysqladmin", "ping", "-hlocalhost", "-uroot", "-pTest123#", "--silent");
        healthCheck = checkpanic process.waitForExit();
        counter = counter + 1;
    }
    test:assertExactEquals(healthCheck, 0, "Docker container 'ballerina-mysql' health test exceeded timeout!");    
    io:println("Docker container started.");
}

@test:AfterSuite {}
function afterSuite() {
    system:Process process = checkpanic system:exec("docker", {}, resourcePath, "stop", "ballerina-mysql");
    int exitCode = checkpanic process.waitForExit();
    test:assertExactEquals(exitCode, 0, "Docker container 'ballerina-mysql' stop failed!");
}
