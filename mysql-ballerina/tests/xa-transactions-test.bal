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

// TODO: Disabling temporarily due to https://github.com/ballerina-platform/ballerina-lang/issues/27061

// import ballerina/test;

// string xaTransactionDB1 = "XA_TRANSACTION_1";
// string xaTransactionDB2 = "XA_TRANSACTION_2";

// type XAResultCount record {
//     int COUNTVAL;
// };

// @test:Config {
//     groups: ["transaction", "xa-transaction"]
// }
// function testXATransactionSuccess() {
//     Client dbClient1 = checkpanic new (host, user, password, xaTransactionDB1, port,
//     connectionPool = {maxOpenConnections: 1});
//     Client dbClient2 = checkpanic new (host, user, password, xaTransactionDB2, port,
//     connectionPool = {maxOpenConnections: 1});

//     transaction {
//         var e1 = checkpanic dbClient1->execute("insert into Customers (customerId, name, creditLimit, country) " +
//                                 "values (1, 'Anne', 1000, 'UK')");
//         var e2 = checkpanic dbClient2->execute("insert into Salary (id, value ) values (1, 1000)");
//         checkpanic commit;
//     }

//     int count1 = checkpanic getCustomerCount(dbClient1, "1");
//     int count2 = checkpanic getSalaryCount(dbClient2, "1");
//     test:assertEquals(count1, 1, "First transaction failed"); 
//     test:assertEquals(count2, 1, "Second transaction failed"); 

//     checkpanic dbClient1.close();
//     checkpanic dbClient2.close();
// }

// @test:Config {
//     groups: ["transaction", "xa-transaction"]
// }
// function testXATransactionSuccessWithDataSource() {
//     Client dbClient1 = checkpanic new (host, user, password, xaTransactionDB1, port);
//     Client dbClient2 = checkpanic new (host, user, password, xaTransactionDB2, port);
    
//     transaction {
//         var e1 = checkpanic dbClient1->execute("insert into Customers (customerId, name, creditLimit, country) " +
//                                 "values (10, 'Anne', 1000, 'UK')");
//         var e2 = checkpanic dbClient2->execute("insert into Salary (id, value ) values (10, 1000)");
//         checkpanic commit;
//     }
    
//     int count1 = checkpanic getCustomerCount(dbClient1, "10");
//     int count2 = checkpanic getSalaryCount(dbClient2, "10");
//     test:assertEquals(count1, 1, "First transaction failed"); 
//     test:assertEquals(count2, 1, "Second transaction failed"); 

//     checkpanic dbClient1.close();
//     checkpanic dbClient2.close();
// }

// function getCustomerCount(Client dbClient, string id) returns @tainted int|error{
//     stream<XAResultCount, error> streamData = <stream<XAResultCount, error>> dbClient->query("Select COUNT(*) as " +
//         "countval from Customers where customerId = "+ id, XAResultCount);
//     return getResult(streamData);
// }

// function getSalaryCount(Client dbClient, string id) returns @tainted int|error{
//     stream<XAResultCount, error> streamData =
//     <stream<XAResultCount, error>> dbClient->query("Select COUNT(*) as countval " +
//     "from Salary where id = "+ id, XAResultCount);
//     return getResult(streamData);
// }

// isolated function getResult(stream<XAResultCount, error> streamData) returns int{
//     record {|XAResultCount value;|}? data = checkpanic streamData.next();
//     checkpanic streamData.close();
//     XAResultCount? value = data?.value;
//     if(value is XAResultCount){
//        return value.COUNTVAL;
//     }
//     return 0;
// }
