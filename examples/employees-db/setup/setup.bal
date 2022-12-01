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
import ballerinax/mysql;
import ballerina/sql;
import ballerinax/mysql.driver as _;

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

public function main() returns error? {
    check createDatabase();
    check createAndPopulateEmployeesTable();
}

function createDatabase() returns error? {
    mysql:Client dbClient = check new (host = HOST, user = USER, password = PASSWORD, port = PORT);
    _ = check dbClient->execute(`DROP DATABASE IF EXISTS EmployeesDB`);
    _ = check dbClient->execute(`CREATE DATABASE EmployeesDB`);
}

function createAndPopulateEmployeesTable() returns error? {
    mysql:Client dbClient = check new (host = HOST, user = USER, password = PASSWORD, port = PORT, database = "EmployeesDB");
    _ = check dbClient->execute(`DROP TABLE IF EXISTS Employees`);

    _ = check dbClient->execute(`
        CREATE TABLE Employees (
            employee_id INTEGER AUTO_INCREMENT PRIMARY KEY,
            first_name  VARCHAR(255) NOT NULL,
            last_name   VARCHAR(255) NOT NULL,
            email       VARCHAR(255) NOT NULL,
            phone       VARCHAR(50) NOT NULL ,
            hire_date   DATE NOT NULL,
            manager_id  INTEGER REFERENCES Employees(employee_id),
            job_title   VARCHAR(255) NOT NULL
        )
    `);

    Employee[] employees = [
        {
            employee_id: 1,
            first_name: "Michael",
            last_name: "Scott",
            email: "michael.scott@example.com",
            phone: "737 299 2772",
            hire_date: {year: 1994, month: 2, day: 29},
            manager_id: (),
            job_title: "CEO"
        },
        {
            employee_id: 2,
            first_name: "Jane",
            last_name: "McIntyre",
            email: "jane.mcintyre@example.com",
            phone: "737 299 1111",
            hire_date: {year: 1996, month: 12, day: 15},
            manager_id: 1,
            job_title: "Vice President - Marketing"
        },
        {
            employee_id: 3,
            first_name: "Tom",
            last_name: "Scott",
            email: "tom.scott@example.com",
            phone: "439 882 099",
            hire_date: {year: 1998, month: 3, day: 23},
            manager_id: 1,
            job_title: "Vice President - Sales"
        },
        {
            employee_id: 4,
            first_name: "Elizabeth",
            last_name: "Queen",
            email: "elizabeth.queen@example.com",
            phone: "881 299 1123",
            hire_date: {year: 1978, month: 8, day: 19},
            manager_id: 2,
            job_title: "Marketing Executive"
        },
        {
            employee_id: 5,
            first_name: "Sam",
            last_name: "Smith",
            email: "sam.smith@example.com",
            phone: "752 479 2991",
            hire_date: {year: 2001, month: 5, day: 29},
            manager_id: 3,
            job_title: "Sales Intern"
        }
    ];

    sql:ParameterizedQuery[] insertQueries =
        from var emp in employees
        select `
            INSERT INTO Employees
                (employee_id, first_name, last_name, email, phone, hire_date, manager_id, job_title)
            VALUES
                (${emp.employee_id}, ${emp.first_name}, ${emp.last_name}, ${emp.email}, ${emp.phone}, ${emp.hire_date},
                ${emp.manager_id}, ${emp.job_title})
            `;

    _ = check dbClient->batchExecute(insertQueries);
}
