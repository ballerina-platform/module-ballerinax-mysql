# Ballerina MySQL Module Example Use Case - Employees Database

## Overview
This example demonstrates how to use the Ballerina `MySQL` module to execute statements and query a MySQL database.

Here, a sample database is used to demonstrate the functionalities of the module. This sample database models a 
company's employees management system. The database contains a single table `Employees` which contains information 
regarding an employee such as their employee ID, name, contact details, hire date, employee ID of their manager, and '
their job title.

This consists of two separate examples, and covers the following features:
* Connection
* Query (`SELECT`)
* Query row
* Execution (`INSERT`, `UPDATE`, `DELETE`)
* Batch Execution

### 1. Setup Example
This example shows how to establish a connection to a MySQL database with the required configurations and connection
parameters, create a database & table, and finally populate the table.

### 2. Service Example
This example shows how an HTTP RESTful service can be created to insert and retrieve data from the MySQL database.

## Prerequisites

### 1. Add the MySQL JDBC driver
Follow one of the following ways to add the MySQL JDBC driver JAR in the `Ballerina.toml` file:

* Download the JAR and update the path
    ```
    [[platform.java11.dependency]]
    path = "PATH"
    ```

* Replace the above path with a maven dependency parameter
    ```
    [[platform.java11.dependency]]
    groupId = "mysql"
    artifactId = "mysql-connector-java"
    version = "8.0.26"
    ```

### 2. Setting the configuration variables
In the `Config.toml` file, set the configuration variables to correspond to your MySQL server.
* `USER`: The username used to connect to the MySQL server
* `PASSWORD`: The password used to connect to the MySQL server
* `HOST`: The hostname of the MySQL server
* `PORT`: The Port number on which the MySQL server is running

### 3. Establishing the connection
* The following can be used to connect to a MySQL server using Ballerina
  ```ballerina
  mysql:Client dbClient = check new (host = HOST, user = USER, password = PASSWORD, port = PORT,
  ```

* If it is required to connect to a database directly, the database parameter may be defined on client intialization
  ```ballerina
  mysql:Client dbClient = check new (host = HOST, user = USER, password = PASSWORD, port = PORT, database = "EmployeesDB");
  ```

After establishing the connection, queries may be executed using the `dbClient` as usual.
```ballerina
_ = check dbClient->execute(`
    INSERT INTO Employees (employee_id, first_name, last_name, email, phone, hire_date, manager_id)
    VALUES (10, 'John', 'Smith', 'john@smith.com', '483 299 111', '2021-08-20', 1, "Software Engineer");
`);

stream<record{}, sql:Error?> streamData = dbClient->query("SELECT * FROM Employees");
_ = check streamData.forEach(function(Employee emp) {
    io:println(emp);
});
```

## Examples

### 1. Setup
This example illustrates the following
* How to establish a connection to your MySQL server
* How to create a database and table
* Populating the table

This example can be run by executing the command `bal run setup`.

### 2. Service
This example creates an HTTP service with the endpoint `/employees` on port 8080 that can be used to interact with the
database

#### 2.1 Get all employee details - method:`GET`
* This would query the Employees table and fetch details of all the employees present in it.
* Example CURL request:
  ```shell
  curl --location --request GET 'localhost:8080/employees'
  ```

#### 2.2 Get details on a single employee - method:`GET`
* This would retrieve the details of a single employee with the given employee ID.
* Example CURL request:
  ```shell
  curl --location --request GET 'localhost:8080/employees/3'
  ```

#### 2.3 Add a new employee - method:`POST`
* This would add a new employee to the table.
* Example CURL request:
  ```shell
  curl --location --request POST 'localhost:8080/employees/' \
  --header 'Content-Type: text/plain' \
  --data-raw '{
    "employee_id": 6,
    "first_name": "test",
    "last_name": "test",
    "email": "test@test.com",
    "phone": "882 771 110",
    "hire_date": {
      "year": 2021,
      "month": 12,
      "day": 16
    },
    "manager_id": 1,
    "job_title": "Sales Intern"
  }'
  ```  

#### 2.4 Update an employee's information - method:`PUT`
* This would update the details of a provided employee on the table.
* Example CURL request:
  ```shell
  curl --location --request PUT 'localhost:8080/employees/' \
  --header 'Content-Type: text/plain' \
  --data-raw '{
    "employee_id": 6,
    "first_name": "test",
    "last_name": "test",
    "email": "test@test.com",
    "phone": "882 771 110",
    "hire_date": {
      "year": 2021,
      "month": 12,
      "day": 16
    },
    "manager_id": 1,
    "job_title": "Sales Manager"
  }'
  ```

#### 2.5 Delete an employee - method:`DELETE`
* This would delete the details of the employee with the provided ID from the table.
* Example CURL request:
  ```shell
  curl --location --request DELETE 'localhost:8080/employees/6'
  ```

### 2.6 Count - method: `GET`
* This would retrieve the total number of employees that are present in the table.
* Example CURL request:
  ```shell
  curl --location --request GET 'localhost:8080/employees/count'
  ```
  
### 2.7 Get subordinates - method: `GET`
* This would retrieve the list of employees that another is responsible for managing.
* Example CURL request:
  ```shell
  curl --location --request GET 'localhost:8080/employees/subordinates/1'
  ```

This example can be run by executing the command `bal run service`.
