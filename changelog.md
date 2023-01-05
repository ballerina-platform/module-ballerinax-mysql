# Changelog
This file contains all the notable changes done to the Ballerina SQL package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed
- [Remove SQL_901 diagnostic hint](https://github.com/ballerina-platform/ballerina-standard-library/issues/3609)
- [Enable non-Hikari logs](https://github.com/ballerina-platform/ballerina-standard-library/issues/3763)
- [Improve API docs based on Best practices](https://github.com/ballerina-platform/ballerina-standard-library/issues/3857)

## [1.6.1] - 2022-12-91

### Changed
- [Updated API Docs on `mysql.driver` usages](https://github.com/ballerina-platform/ballerina-standard-library/issues/3710)

## [1.6.0] - 2022-11-29

### Changed
- [Updated API Docs](https://github.com/ballerina-platform/ballerina-standard-library/issues/3463)

## [1.5.0] - 2022-09-08

### Changed
- [Change default username for client initialization to `root`](https://github.com/ballerina-platform/ballerina-standard-library/issues/2397)

## [1.4.1] - 2022-06-27

### Changed
- [Fix incorrect retrieval of time types](https://github.com/ballerina-platform/ballerina-standard-library/issues/3023)
- [Fix NullPointerException when retrieving record with default value](https://github.com/ballerina-platform/ballerina-standard-library/issues/2985)

## [1.4.0] - 2022-05-30

### Added
- [Improve DB columns to Ballerina record Mapping through Annotation](https://github.com/ballerina-platform/ballerina-standard-library/issues/2652)

### Changed
- [Fix incorrect code snippet in SQL api docs](https://github.com/ballerina-platform/ballerina-standard-library/issues/2931) 

## [1.3.1] - 2022-03-01

### Changed
- [Improve API documentation to reflect query usages](https://github.com/ballerina-platform/ballerina-standard-library/issues/2524)

## [1.3.0] - 2022-01-29

### Changed
- [Fix Compiler plugin crash when variable is passed for `sql:ConnectionPool` and `mysql:Options`](https://github.com/ballerina-platform/ballerina-standard-library/issues/2536)

## [1.2.1] - 2022-02-03

### Changed
- [Fix Compiler plugin crash when variable is passed for `sql:connectionPool` and `mysql:Options`](https://github.com/ballerina-platform/ballerina-standard-library/issues/2536)

## [1.2.0] - 2021-12-13

### Changed
- Released module on top of Swan Lake Beta6 distribution

## [1.1.0] - 2021-11-20

### Added
- [Support noAccessToProcedureBodies options in mysql connector](https://github.com/ballerina-platform/ballerina-standard-library/issues/1545)
- [Support Mysql connector failover and retries](https://github.com/ballerina-platform/ballerina-standard-library/issues/1950)
- [Add Tooling support for MySLQ connector](https://github.com/ballerina-platform/ballerina-standard-library/issues/2279)

### Changed
- [Change queryRow return type to anydata](https://github.com/ballerina-platform/ballerina-standard-library/issues/2390)

## [1.0.0] - 2021-10-09

### Changed
- [Add completion type as nil in SQL query return stream type](https://github.com/ballerina-platform/ballerina-standard-library/issues/1654)

## [0.6.0-beta.2] - 2021-06-22

### Changed
- [Change default rowType of the query remote method from `nil` to `<>`](https://github.com/ballerina-platform/ballerina-standard-library/issues/1445)
 
### Added 
- [Add support for queryRow](https://github.com/ballerina-platform/ballerina-standard-library/issues/1604)
- [Remove support for string parameter in APIs](https://github.com/ballerina-platform/ballerina-standard-library/issues/2010)

## [0.7.0-beta.1] - 2021-06-02

### Changed
- Make the MySQL Client class isolated
  
### Added
- Add Additional options to the Option record for mysql connection creation
