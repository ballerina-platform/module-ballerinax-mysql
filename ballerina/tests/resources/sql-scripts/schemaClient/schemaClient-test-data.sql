DROP DATABASE IF EXISTS `testDB`;
CREATE DATABASE `testDB`;
USE `testDB`;

DROP TABLE IF EXISTS `employees`;
CREATE TABLE `employees` (
  `employeeNumber` int(11) NOT NULL,
  `lastName` varchar(50) NOT NULL,
  `firstName` varchar(50) NOT NULL,
  `extension` varchar(10) NOT NULL,
  `email` varchar(100) NOT NULL,
  `officeCode` varchar(10) NOT NULL,
  `reportsTo` int(11) DEFAULT NULL,
  `jobTitle` varchar(50) NOT NULL,
  PRIMARY KEY (`employeeNumber`),
  KEY `reportsTo` (`reportsTo`),
  KEY `officeCode` (`officeCode`),
  CONSTRAINT `employees_ibfk_1` FOREIGN KEY (`reportsTo`) REFERENCES `employees` (`employeeNumber`),
  CONSTRAINT `employees_ibfk_2` FOREIGN KEY (`officeCode`) REFERENCES `offices` (`officeCode`)
);

DROP TABLE IF EXISTS `offices`;
CREATE TABLE `offices` (
  `officeCode` varchar(10) NOT NULL,
  PRIMARY KEY (`officeCode`)
);

DELIMITER $$
DROP PROCEDURE IF EXISTS getEmpsName $$
CREATE PROCEDURE getEmpsName(IN empNumber INT, OUT fName VARCHAR(20))
BEGIN
   SELECT firstName INTO fName
   FROM employees
   WHERE employeeNumber = empNumber;
END $$
DELIMITER ;