// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/lang.runtime;
import ballerina/test;
import ballerinax/cdc;

@test:Config {
    groups: ["liveness"]
}
function testLivenessBeforeListenerStart() returns error? {
    CdcListener mysqlListener = new ({
        database: {
            username: cdcUsername,
            password: cdcPassword,
            port: cdcPort
        },
        options: {
            snapshotMode: cdc:NO_DATA
        }
    });
    check mysqlListener.attach(testService);
    boolean liveness = check cdc:isLive(mysqlListener);
    test:assertFalse(liveness, "Liveness check passes even before listener starts");
}

@test:Config {
    groups: ["liveness"]
}
function testLivenessWithStartedListener() returns error? {
    CdcListener mysqlListener = new ({
        database: {
            username: cdcUsername,
            password: cdcPassword,
            port: cdcPort
        },
        options: {
            snapshotMode: cdc:NO_DATA
        }
    });
    check mysqlListener.attach(testService);
    check mysqlListener.'start();
    boolean liveness = check cdc:isLive(mysqlListener);
    test:assertTrue(liveness, "Liveness fails for a started listener");
    check mysqlListener.gracefulStop();
}

@test:Config {
    groups: ["liveness"]
}
function testLivenessAfterListenerStop() returns error? {
    CdcListener mysqlListener = new ({
        database: {
            username: cdcUsername,
            password: cdcPassword,
            port: cdcPort
        },
        options: {
            snapshotMode: cdc:NO_DATA
        }
    });
    check mysqlListener.attach(testService);
    check mysqlListener.'start();
    check mysqlListener.gracefulStop();
    boolean liveness = check cdc:isLive(mysqlListener);
    test:assertFalse(liveness, "Liveness check passes after the listener has stopped");
}

@test:Config {
    groups: ["liveness"]
}
function testLivenessWithoutReceivingEvents() returns error? {
    CdcListener mysqlListener = new ({
        database: {
            username: cdcUsername,
            password: cdcPassword,
            port: cdcPort
        },
        options: {
            snapshotMode: cdc:NO_DATA
        },
        livenessInterval: 5.0
    });
    check mysqlListener.attach(testService);
    check mysqlListener.'start();
    runtime:sleep(10);
    boolean liveness = check cdc:isLive(mysqlListener);
    test:assertFalse(liveness, "Liveness check passes even after not receiving events within the liveness interval");
    check mysqlListener.gracefulStop();
}
