// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/time;
import ballerina/http;
import ballerinax/mysql;
import ballerina/sql;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;

public type Employee record {
    int employee_id?;
    string first_name;
    string last_name;
    string email;
    string phone;
    time:Date hire_date;
    int? manager_id;
    string job_title;
};

final mysql:Client dbClient = check new (host = HOST, user = USER, password = PASSWORD, port = PORT,
    database = "EmployeesDB", connectionPool = {maxOpenConnections: 3, minIdleConnections: 1});

service /employees on new http:Listener(8080) {

    resource function get .() returns Employee[]|error? {
        Employee[] employees = [];
        stream<Employee, error?> resultStream = dbClient->query(`SELECT * FROM Employees`);
        check resultStream.forEach(function(Employee employee) {
            employees.push(employee);
        });
        check resultStream.close();
        return employees;
    }

    resource function get [int id]() returns Employee|error? {
        Employee employee = check dbClient->queryRow(`SELECT * FROM Employees WHERE employee_id = ${id}`);
        return employee;
    }

    resource function post .(@http:Payload Employee emp) returns string|int|error? {
         sql:ExecutionResult result = check dbClient->execute(`
            INSERT INTO Employees (employee_id, first_name, last_name, email, phone, hire_date, manager_id, job_title)
            VALUES (${emp.employee_id}, ${emp.first_name}, ${emp.last_name}, ${emp.email}, ${emp.phone}, ${emp.hire_date},
                    ${emp.manager_id}, ${emp.job_title})
        `);
        int|string? lastInsertId = result.lastInsertId;
        if lastInsertId is int {
            return lastInsertId;
        } else {
          return error("Unable to obtain last insert ID");
        }
    }

    resource function put .(@http:Payload Employee emp) returns int|error? {
        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE Employees
            SET first_name = ${emp.first_name}, last_name = ${emp.last_name}, email = ${emp.email},
                phone = ${emp.phone}, hire_date = ${emp.hire_date}, manager_id = ${emp.manager_id},
                job_title = ${emp.job_title}
            WHERE employee_id = ${emp.employee_id}
        `);
        int|string? lastInsertId = result.lastInsertId;
        if lastInsertId is int {
            return lastInsertId;
        } else {
          return error("Unable to obtain last insert ID");
        }
    }

    resource function delete [int id]() returns int|error? {
        sql:ExecutionResult result = check dbClient->execute(`DELETE FROM Employees WHERE employee_id = ${id}`);
        return result.affectedRowCount;
    }

    resource function get count() returns int|error? {
        int count = check dbClient->queryRow(`SELECT COUNT(*) FROM Employees`);
        return count;
    }

    resource function get subordinates/[int id]() returns Employee[]|error? {
        Employee[] employees = [];
        stream<Employee, error?> resultStream = dbClient->query(`SELECT * FROM Employees WHERE manager_id = ${id}`);
        check resultStream.forEach(function(Employee employee) {
            employees.push(employee);
        });
        check resultStream.close();
        return employees;
    }
}
