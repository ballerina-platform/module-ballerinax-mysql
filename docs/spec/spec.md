# Specification: Ballerina MySQL Library

_Owners_: @niveathika @RDPerera @shafreenAnfar  
_Reviewers_:  
_Created_: 2022/01/14  
_Updated_: 2026/11/26  
_Edition_: Swan Lake  

## Introduction

This is the specification for the MySQL connector of the [Ballerina language](https://ballerina.io/), `ballerinax/mysql`, which provides a client for MySQL databases built on the `ballerina/sql` library, and a change data capture (CDC) listener for MySQL built on the `ballerinax/cdc` library.

This specification is the contract of the library. It defines the observable behaviour of the connector: the configuration it accepts, how it connects to the database, how it changes the default behaviour of the `ballerina/sql` library, the errors it returns, and what it rejects at compile time. The behaviour that the connector takes unchanged from `ballerina/sql` is specified in the [SQL specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md) and is not repeated here. A behaviour of the implementation that differs from this specification is a bug in the implementation. A behaviour that this specification does not define is a gap in the specification, and is also reported as a bug. Signatures and per-symbol documentation are part of the [API documentation](https://central.ballerina.io/ballerinax/mysql/latest), and usage examples are part of [Ballerina by Example](https://ballerina.io/learn/by-example/). Neither is repeated here.

The released versions of the specification can be found under the relevant GitHub tag. Changes to the specification follow the proposal process described in the [library development process](https://github.com/ballerina-platform/ballerina-library/blob/main/docs/library-development-process.md). If you have any feedback or suggestions about the library, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/ballerina-library/issues) or in the [Discord server](https://discord.gg/ballerinalang).

### Notation

- The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY and OPTIONAL are interpreted as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174) when, and only when, they appear in all capitals. Other statements of behaviour in the present tense are also normative.
- Examples and notes are informative.
- "SQL §*n*" refers to section *n* of the [SQL specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md), and links to it. A table row of the SQL specification is identified by the value of its first cell, as described in [SQL §17.1](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#171-description).
- _Implementation-defined_ behaviour is chosen and documented by the implementation; _unspecified_ behaviour must not be relied on. _Driver-defined_ behaviour is that of the MySQL JDBC driver (MySQL Connector/J) in use.

## Contents

- [1. Overview](#1-overview)
- [2. Terminology](#2-terminology)
- [3. Client](#3-client)
    - [3.1. Description](#31-description)
    - [3.2. Configuration](#32-configuration)
    - [3.3. Driver](#33-driver)
    - [3.4. Connection URL](#34-connection-url)
    - [3.5. Operations](#35-operations)
    - [3.6. Compile-time validation](#36-compile-time-validation)
    - [3.7. Errors](#37-errors)
    - [3.8. Interactions](#38-interactions)
- [4. Connection options](#4-connection-options)
    - [4.1. Description](#41-description)
    - [4.2. Configuration](#42-configuration)
    - [4.3. Driver properties](#43-driver-properties)
    - [4.4. XA data source](#44-xa-data-source)
    - [4.5. Compile-time validation](#45-compile-time-validation)
    - [4.6. Errors](#46-errors)
    - [4.7. Interactions](#47-interactions)
- [5. SSL/TLS](#5-ssltls)
    - [5.1. Description](#51-description)
    - [5.2. Configuration](#52-configuration)
    - [5.3. Behaviour](#53-behaviour)
    - [5.4. Errors](#54-errors)
    - [5.5. Interactions](#55-interactions)
- [6. Server failover](#6-server-failover)
    - [6.1. Description](#61-description)
    - [6.2. Configuration](#62-configuration)
    - [6.3. Behaviour](#63-behaviour)
    - [6.4. Compile-time validation](#64-compile-time-validation)
    - [6.5. Errors](#65-errors)
- [7. Parameter binding](#7-parameter-binding)
    - [7.1. Description](#71-description)
    - [7.2. Arrays](#72-arrays)
    - [7.3. Values the driver does not support](#73-values-the-driver-does-not-support)
    - [7.4. Errors](#74-errors)
- [8. Result mapping](#8-result-mapping)
    - [8.1. Description](#81-description)
    - [8.2. Result conversion](#82-result-conversion)
    - [8.3. MySQL column types](#83-mysql-column-types)
    - [8.4. Time zones](#84-time-zones)
    - [8.5. Errors](#85-errors)
- [9. Stored procedure calls](#9-stored-procedure-calls)
    - [9.1. Description](#91-description)
    - [9.2. Behaviour](#92-behaviour)
    - [9.3. Errors](#93-errors)
- [10. Connector contract](#10-connector-contract)
    - [10.1. Description](#101-description)
    - [10.2. Obligations](#102-obligations)
    - [10.3. Override points](#103-override-points)
- [11. Observability](#11-observability)
    - [11.1. Description](#111-description)
    - [11.2. Metric tags](#112-metric-tags)
- [12. Change data capture listener](#12-change-data-capture-listener)
    - [12.1. Description](#121-description)
    - [12.2. Configuration](#122-configuration)
    - [12.3. Behaviour](#123-behaviour)
    - [12.4. Errors](#124-errors)
    - [12.5. Interactions](#125-interactions)
- [13. Security considerations](#13-security-considerations)
- [14. Static code rules](#14-static-code-rules)
- [15. Planned changes](#15-planned-changes)
- [References](#references)

## 1. Overview

The `mysql:Client` class includes `sql:Client`. It connects to a MySQL server through MySQL Connector/J and a connection pool of the `ballerina/sql` library, and executes the operations of `sql:Client` (`query`, `queryRow`, `execute`, `batchExecute`, `call` and `close`) as specified in the SQL specification. This specification states how the client is configured, how its configuration becomes a connection URL and driver properties, and where its behaviour differs from the default behaviour of the SQL specification: SQL arrays are not supported, and some MySQL column types map to JDBC types in ways that affect result mapping.

The `mysql:CdcListener` class is a listener of the `ballerinax/cdc` library that captures row changes from the MySQL binary log. This specification states its MySQL-specific configuration; services, events and the common configuration are specified by the `ballerinax/cdc` library.

## 2. Terminology

The terms of [SQL §2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#2-terminology) apply. In addition:

| Term | Meaning |
|---|---|
| Driver | The MySQL JDBC driver, MySQL Connector/J, on the program's class path. |
| Driver property | A property of the MySQL Connector/J data source, set by the connector from its configuration. |
| Primary host | The `host` and `port` given to the client initializer. |
| Failover host | A host given in `failoverServers` ([§6](#6-server-failover)). |
| Debezium property | A configuration property of the Debezium MySQL connector, which the CDC listener runs. |
| Driver options map | The map of driver properties that the connector gives the `sql` library ([SQL §17.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#172-connector-obligations) rule 2); with the URL, the user, the password and the data source class, it forms the pool key ([SQL §4.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#46-pool-selection)). |

## 3. Client

### 3.1. Description

`mysql:Client` is a client of a MySQL database. Its initializer builds a connection URL and driver properties from its parameters and creates the client through the `sql` library ([SQL §3.3.1](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#331-creation)).

### 3.2. Configuration

The initializer takes the following parameters.

| Parameter | Type | Default | Meaning |
|---|---|---|---|
| `host` | `string` | `"localhost"` | Host name or IP address of the primary host. Used in the URL as given ([§3.4](#34-connection-url)). |
| `user` | `string?` | `"root"` | User name. `()` means no user is given to the driver. |
| `password` | `string?` | `()` | Password. `()` means no password is given to the driver. |
| `database` | `string?` | `()` | Default database of the connections. `()` and `""` mean no default database. |
| `port` | `int` | `3306` | Port of the primary host. A value less than or equal to `0` means no port is given in the URL, so the driver uses its default port, `3306`. |
| `options` | `mysql:Options?` | `()` | Connection options ([§4](#4-connection-options)). |
| `connectionPool` | `sql:ConnectionPool?` | `()` | Pool configuration ([SQL §4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#4-connection-pool)). `()` means the global pool configuration ([SQL §4.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#45-global-pool-configuration)). |

### 3.3. Driver

1. The connector does not contain the driver. The program MUST provide it, for example by importing `ballerinax/mysql.driver` or by adding a MySQL Connector/J JAR as a platform dependency.
2. The connector always gives the data source class name `com.mysql.cj.jdbc.MysqlDataSource`, or `com.mysql.cj.jdbc.MysqlXADataSource` when `useXADatasource` is `true` ([§4.4](#44-xa-data-source)). The URL, the user, the password and the driver properties are therefore set as data source properties ([SQL §4.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#47-pool-creation) step 7).
3. If the data source class cannot be loaded, the initializer returns an `sql:ApplicationError` ([SQL §4.10](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#410-errors)).

### 3.4. Connection URL

The connector builds the URL as follows:

1. The URL starts with `jdbc:mysql://` followed by `host`.
2. If `port` is greater than `0`, `:` and `port` are appended.
3. If `options` has a `failoverConfig`, `,` and each failover host as `<host>:<port>` are appended, separated by `,`, in the order of `failoverServers` ([§6](#6-server-failover)).
4. If `database` is neither `()` nor `""`, `/` and `database` are appended.
5. The connector does not validate, escape or encode `host`, `database`, or the `host` of a failover host: each is inserted into the URL as given, and the driver interprets any URL syntax it contains as further URL parts. For example, `database` `"shop?allowMultiQueries=true"` sets the driver property `allowMultiQueries`. These values MUST therefore be trusted input ([§13](#13-security-considerations)).
6. When `host`, `database` or the `host` of a failover host contains one of the characters `/`, `?`, `&`, `;`, `=`, `(`, `)`, `#` and `,`, the initializer logs a warning before the pool is created, and then builds the URL as stated in rules 1–5. The warning does not change the outcome of the initializer.

The URL, the driver options map, the user, the password and the data source class form the pool key of the client ([SQL §4.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#46-pool-selection)); which clients share a pool is specified there.

### 3.5. Operations

1. `query`, `queryRow`, `execute`, `batchExecute`, `call` and `close` behave as specified in [SQL §3](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#3-client) and [SQL §8](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#8-query) to [SQL §13](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#13-transactions), with the connector's binding ([§7](#7-parameter-binding)), result conversion ([§8](#8-result-mapping)) and procedure call behaviour ([§9](#9-stored-procedure-calls)).
2. The client requests generated keys for both `execute` and `batchExecute`, so `lastInsertId` is set as specified in [SQL §10.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#104-generated-keys). The connector does not offer the `sql:GeneratedKeysMode` option of [SQL §10.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#104-generated-keys) rule 7, so the requests cannot be limited to `INSERT` statements.

### 3.6. Compile-time validation

The `ballerinax/mysql` compiler plugin checks each `new` expression whose type is `mysql:Client`. It checks the `connectionPool` argument when it is a mapping constructor, given as a named argument or as the seventh positional argument in a call without named arguments. For each field whose value is a numeric literal, decimal or hexadecimal, optionally preceded by a unary `-`, it checks the value of the literal and reports the diagnostics of the [SQL §4.9](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#49-compile-time-validation) rows `SQL_101`, `SQL_102` and `SQL_103` under their conditions, and [SQL §4.9](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#49-compile-time-validation) rules 1 and 2 apply.

1. A literal whose value is outside the range of `int`, or of the field type, is checked by its value like any other literal. A field value that is not a numeric literal, such as a variable reference, a field given in shorthand form or a spread of a record value, is not checked. Nothing other than the diagnostics of this section makes the plugin fail the build.
2. The `options` argument is checked as specified in [§4.5](#45-compile-time-validation).

These conditions are those of the runtime checks of [SQL §4.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#47-pool-creation) step 3, which still apply to values the plugin does not check. A `sql:ConnectionPool` variable declaration is checked by the `sql` compiler plugin ([SQL §4.9](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#49-compile-time-validation)).

### 3.7. Errors

| Condition | Error |
|---|---|
| The data source class cannot be loaded (no driver) | `sql:ApplicationError`, returned by the initializer |
| `failoverServers` is empty | `sql:ApplicationError`, returned by the initializer ([§6.5](#65-errors)) |
| The first connection cannot be opened, including an unreachable host, failed authentication and a failed TLS handshake | As specified in [SQL §4.10](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#410-errors): an `sql:ApplicationError` when `initializationFailTimeout` is greater than `0`, otherwise an `sql:DatabaseError` |
| Any other failure | As specified in [SQL §15](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#15-errors) |

### 3.8. Interactions

- A client given no `connectionPool` uses the global pool configuration, so it shares a pool with the other such clients whose URL, driver options map, user, password and data source class are equal ([SQL §4.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#46-pool-selection)). Clients that differ in user, password, or `useXADatasource` never share a pool ([SQL §4.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#46-pool-selection) rule 6).
- `options` are part of the pool key through the driver options map ([§4.3](#43-driver-properties)): two clients whose `options` give different driver options maps use different pools. `options` `()` gives the same driver options map as `{}` ([§4.3](#43-driver-properties) rule 1), so the two give equal pool keys ([SQL §4.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#46-pool-selection) rule 2), and clients whose `options` differ only in `()` and `{}` share a pool when the rest of their pool keys are equal.

### 3.9. Example: Client creation

```ballerina
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

# Creates a client of the `shop` database on port 3307.
function createShopClient() returns mysql:Client|error {
    return new ("db.example.com", "app", "secret", "shop", 3307, connectionPool = {maxOpenConnections: 5});
}
```

The URL is `jdbc:mysql://db.example.com:3307/shop` ([§3.4](#34-connection-url) rules 1, 2 and 4), the driver properties of the `mysql:Options` defaults are set although `options` is `()`, so `connectTimeout` is 30 seconds ([§4.3](#43-driver-properties) rule 1), and the client gets a pool of its own because its pool configuration is written inline ([SQL §4.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#46-pool-selection)).

## 4. Connection options

### 4.1. Description

`mysql:Options` configures the connection to the server. The connector converts it to driver properties.

### 4.2. Configuration

`mysql:Options` is a closed record. Time values are in seconds.

| Field | Type | Default | Meaning |
|---|---|---|---|
| `ssl` | `mysql:SecureSocket` | absent | TLS configuration ([§5](#5-ssltls)). Absent means the driver's default TLS behaviour. |
| `failoverConfig` | `mysql:FailoverConfig` | absent | Failover hosts ([§6](#6-server-failover)). |
| `useXADatasource` | `boolean` | `false` | When `true`, the XA data source class is used ([§4.4](#44-xa-data-source)). |
| `connectTimeout` | `decimal` | `30` | Timeout for opening a socket connection to the server. A value that is not positive after conversion to milliseconds ([§4.3](#43-driver-properties) rule 3), including a negative value, means the driver's default, which is no timeout ([§4.6](#46-errors)). |
| `socketTimeout` | `decimal` | `0` | Timeout for each read and write on the connection's socket. A value that is not positive after conversion to milliseconds, including a negative value, means the driver's default, which is no timeout ([§4.6](#46-errors)). |
| `serverTimezone` | `string` | absent | Time zone of the server, a time zone ID such as `"UTC"`, `"Asia/Colombo"` or `"+05:30"`, used by the driver to convert date and time values ([§8.4](#84-time-zones)). Absent means the driver's default, which converts no values. |
| `noAccessToProcedureBodies` | `boolean` | `false` | When `true`, a call of a procedure whose parameter metadata the driver cannot read treats every parameter as an INOUT `VARCHAR` parameter instead of failing ([§9.2](#92-behaviour) rule 4). |

### 4.3. Driver properties

1. When `options` is `()`, the connector sets the driver properties that it sets for `options` `{}` (rule 2), so the defaults of [§4.2](#42-configuration) apply, including `connectTimeout` `30`.
2. When `options` is given, the connector sets the following driver properties, each from the field with the same name unless stated otherwise:
    1. `ssl`: as specified in [§5.3](#53-behaviour).
    2. `connectTimeout` and `socketTimeout`: the value in milliseconds, when it is positive (rule 3). Otherwise the property is not set.
    3. `serverTimezone`: the string, when the field is present.
    4. `noAccessToProcedureBodies`: always set, to the field's value.
    5. `failoverConfig`: as specified in [§6.3](#63-behaviour).
3. A time value is converted to milliseconds by converting the `decimal` to a 64-bit floating-point number, multiplying it by `1000`, and truncating towards zero.
4. The connector gives the pool no pool property of its own. The time a client waits for a connection from the pool is set by the `connectionTimeout` field of the pool configuration alone ([SQL §4.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#47-pool-creation)), and `connectTimeout` never makes the initializer fail by itself.
5. No other driver property can be set through the client. The driver defaults apply to all others.

### 4.4. XA data source

1. When `useXADatasource` is `true`, the data source class is `com.mysql.cj.jdbc.MysqlXADataSource`.
2. The pool is created as specified in [SQL §4.8](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#48-xa-data-sources).

### 4.5. Compile-time validation

The compiler plugin checks a mapping constructor that is the `options` argument of a `mysql:Client` `new` expression (as a named argument, or as the sixth positional argument in a call without named arguments), or the initializer of a variable declaration whose type is `mysql:Options` or a union containing it. For each field whose value is a numeric literal, decimal or hexadecimal, optionally preceded by a unary `-`, the value of the literal is checked:

| Code | Field | Condition | Kind |
|---|---|---|---|
| `MYSQL_101` | `connectTimeout`, `socketTimeout` | value less than `0` | error |

A `failoverConfig` field whose value is a mapping constructor is checked as specified in [§6.4](#64-compile-time-validation). [SQL §4.9](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#49-compile-time-validation) rules 1 and 2 and [§3.6](#36-compile-time-validation) rule 1 apply.

### 4.6. Errors

The options are not validated at run time, except that the initializer logs a warning, before the pool is created, when `connectTimeout` or `socketTimeout` is negative; such a value then means the driver's default, as stated in [§4.2](#42-configuration). A value that the driver rejects when a connection is opened is reported as a failure to open a connection ([§3.7](#37-errors)), except a negative `timeBeforeRetry` or `queriesBeforeRetry` of `failoverConfig`, which makes the initializer return an `sql:ApplicationError` whatever `initializationFailTimeout` is ([§6.5](#65-errors)).

### 4.7. Interactions

- A failure caused by `socketTimeout` during an operation is a database error: the operation returns an `sql:DatabaseError` ([SQL §15.3](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#153-mapping)), and the connection is closed by the driver.
- `serverTimezone` affects result mapping and binding of date and time values ([§8.4](#84-time-zones)).

## 5. SSL/TLS

### 5.1. Description

`mysql:SecureSocket` configures whether and how the connection to the server is encrypted.

### 5.2. Configuration

`mysql:SecureSocket` is a closed record.

| Field | Type | Default | Meaning |
|---|---|---|---|
| `mode` | `mysql:SSLMode` | `SSL_PREFERRED` | TLS mode, set as the driver property `sslMode`. |
| `key` | `crypto:KeyStore` | absent | PKCS #12 key store holding the client certificate and key, for client authentication. Absent means no client certificate. |
| `cert` | `crypto:TrustStore` | absent | PKCS #12 trust store holding the certificates that the server certificate is verified against. Absent means the driver's default trust store, which is that of the JVM. |
| `allowPublicKeyRetrieval` | `boolean` | `false` | When `true`, the driver may request the server's RSA public key to send the password, as required by some authentication plugins on unencrypted connections. |

`mysql:SSLMode` is a union of the following constants, whose values are the values of the driver property `sslMode`:

| Constant | Value | Meaning |
|---|---|---|
| `SSL_PREFERRED` | `"PREFERRED"` | Encrypted when the server supports encryption, unencrypted otherwise. The server certificate is not verified, also when `cert` is given ([§5.3](#53-behaviour) rule 6). |
| `SSL_REQUIRED` | `"REQUIRED"` | Encrypted; the connection fails when encryption cannot be established. The server certificate is not verified. |
| `SSL_VERIFY_CA` | `"VERIFY_CA"` | As `SSL_REQUIRED`, and the server certificate MUST chain to a certificate of the trust store. |
| `SSL_VERIFY_IDENTITY` | `"VERIFY_IDENTITY"` | As `SSL_VERIFY_CA`, and the host name the client connects to MUST match the identity in the server certificate. |
| `SSL_DISABLED` | `"DISABLED"` | Unencrypted. |

### 5.3. Behaviour

1. When `ssl` is absent, the connector sets no TLS driver property; the driver's default mode is `PREFERRED`.
2. When `ssl` is given, the connector sets `sslMode` to `mode` and `allowPublicKeyRetrieval` to its value.
3. When `key` is given, the connector sets `clientCertificateKeyStoreUrl` to `file:` followed by its `path`, `clientCertificateKeyStorePassword` to its `password`, and `clientCertificateKeyStoreType` to `PKCS12`.
4. When `cert` is given, the connector sets `trustCertificateKeyStoreUrl`, `trustCertificateKeyStorePassword` and `trustCertificateKeyStoreType` in the same way.
5. The key store and trust store files are read by the driver when a connection is opened, not when the initializer is called.
6. When `cert` is given and `mode` is `SSL_PREFERRED`, the trust store is not used: the server certificate is not verified, and the connection is encrypted whenever the server supports encryption. The initializer logs a warning in this case, before the pool is created; giving no `cert`, or setting `mode` to `SSL_VERIFY_CA` or `SSL_VERIFY_IDENTITY`, avoids the warning. The warning does not change the outcome of the initializer ([§13](#13-security-considerations)).

#### 5.3.1. Example: Verified TLS

```ballerina
import ballerinax/mysql;

# Creates a client that requires a server certificate issued by the given CA.
function createTlsClient(string host, string password) returns mysql:Client|error {
    mysql:Options options = {
        ssl: {
            mode: mysql:SSL_VERIFY_IDENTITY,
            cert: {path: "/etc/certs/truststore.p12", password: "changeit"}
        }
    };
    return new (host, "app", password, "shop", options = options);
}
```

Every connection is encrypted, and it fails unless the server certificate chains to a certificate in `truststore.p12` and matches `host` ([§5.2](#52-configuration), [§5.3](#53-behaviour) rule 4). Without `cert`, the same mode verifies against the JVM trust store, and, with the default `initializationFailTimeout`, the initializer returns an `sql:ApplicationError` for a server with a self-signed certificate ([§5.4](#54-errors)).

### 5.4. Errors

| Condition | Error |
|---|---|
| A TLS handshake fails, the server certificate cannot be verified, or a key store or trust store cannot be read, while the pool opens its first connection | As in [§3.7](#37-errors) row 3 |
| The same failure while a later connection is opened during an operation | `sql:DatabaseError`, returned by the operation ([SQL §15.3](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#153-mapping) rule 2) |

### 5.5. Interactions

- The TLS configuration applies to every host of the URL, including the failover hosts of [§6](#6-server-failover): a connection to a failover host is encrypted and verified as a connection to the primary host is. With `SSL_VERIFY_IDENTITY`, the name of the host connected to is matched against its certificate.

## 6. Server failover

### 6.1. Description

With a failover configuration, the driver connects to a failover host when the primary host is not reachable, and returns to the primary host later.

### 6.2. Configuration

`mysql:FailoverConfig` is a closed record.

| Field | Type | Default | Meaning |
|---|---|---|---|
| `failoverServers` | `mysql:FailoverServer[]` | Required | Failover hosts, in the order in which they are tried after the primary host. MUST NOT be empty. |
| `timeBeforeRetry` | `int` | absent | Seconds after a failover after which the driver tries the primary host again, set as the driver property `secondsBeforeRetryMaster`. Absent means the driver's default, `30`. `0` means that the elapsed time never makes the driver try the primary host. A negative value makes the initializer return an `sql:ApplicationError` ([§6.5](#65-errors)). |
| `queriesBeforeRetry` | `int` | absent | Number of statements executed after a failover after which the driver tries the primary host again, set as the driver property `queriesBeforeRetryMaster`. Absent means the driver's default, `50`. `0` means that the number of statements never makes the driver try the primary host; when `timeBeforeRetry` is also `0`, the driver does not return to the primary host automatically. A negative value makes the initializer return an `sql:ApplicationError` ([§6.5](#65-errors)). |
| `failoverReadOnly` | `boolean` | `true` | Set as the driver property `failOverReadOnly`. When `true`, a connection to a failover host is read-only. |

`mysql:FailoverServer` is a closed record with the required fields `host` (`string`) and `port` (`int`) of a failover host. Both are written into the URL as given ([§3.4](#34-connection-url) rules 3 and 5), including a `port` of `0` or less.

### 6.3. Behaviour

1. If `failoverServers` is empty, the initializer returns an `sql:ApplicationError` and no pool is created.
2. The failover hosts are added to the URL ([§3.4](#34-connection-url) rule 3), and the driver properties of [§6.2](#62-configuration) are set.
3. Which host a connection uses, when the driver fails over and when it falls back to the primary host, is driver-defined, within the properties set by rule 2.
4. A statement executed on a read-only connection that modifies data fails with a database error: the operation returns an `sql:DatabaseError`.

#### 6.3.1. Example: Failover to a read-only replica

```ballerina
import ballerinax/mysql;

# Creates a client that fails over to a replica when the primary host is down.
function createFailoverClient(string password) returns mysql:Client|error {
    return new ("primary.example.com", "app", password, "shop", options = {
        failoverConfig: {failoverServers: [{host: "replica.example.com", port: 3306}], timeBeforeRetry: 60}
    });
}
```

The URL is `jdbc:mysql://primary.example.com:3306,replica.example.com:3306/shop` ([§3.4](#34-connection-url)). While the primary host is down, connections go to the replica and are read-only, so an `INSERT` returns an `sql:DatabaseError` ([§6.3](#63-behaviour) rule 4); the driver tries the primary host again 60 seconds after failing over.

### 6.4. Compile-time validation

The compiler plugin checks a mapping constructor that is the `failoverConfig` field of an options mapping constructor checked by [§4.5](#45-compile-time-validation), or the initializer of a variable declaration whose type is `mysql:FailoverConfig` or a union containing it:

| Code | Field | Condition | Kind |
|---|---|---|---|
| `MYSQL_101` | `timeBeforeRetry`, `queriesBeforeRetry` | value less than `0` | error |

[SQL §4.9](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#49-compile-time-validation) rules 1 and 2 and [§3.6](#36-compile-time-validation) rule 1 apply. An empty `failoverServers` array is not checked at compile time.

### 6.5. Errors

| Condition | Error |
|---|---|
| `failoverServers` is empty | `sql:ApplicationError`, returned by the initializer |
| A negative `timeBeforeRetry` or `queriesBeforeRetry` | `sql:ApplicationError`, returned by the initializer |
| No host can be reached while the pool opens its first connection | As in [§3.7](#37-errors) row 3 |
| A modifying statement on a read-only failover connection | `sql:DatabaseError`, returned by the operation |

## 7. Parameter binding

### 7.1. Description

Parameters are bound as specified in [SQL §6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#6-parameter-binding), except that the connector rejects every SQL array, because MySQL has no array type.

### 7.2. Arrays

The connector changes the following rows and rules of [SQL §6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#6-parameter-binding):

1. Every array parameter of [SQL §6.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#65-arrays) (`string?[]`, `int?[]`, `boolean?[]`, `float?[]`, `decimal?[]` and `byte[]?[]`), and every `time:Civil[]` and `time:TimeOfDay[]` parameter of [SQL §6.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#64-time-types) rule 5, is rejected with an `sql:DataError`, instead of being bound as an SQL `ARRAY`.
2. Every typed array value class of [SQL §6.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#67-typed-array-values) (every row of its table, from `sql:VarcharArrayValue` to `sql:TimestampArrayValue`) is rejected with an `sql:DataError`.
3. The deprecated `sql:ArrayValue` ([SQL §6.8](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#68-deprecated-array-value)) is rejected with an `sql:DataError`, including when its value is `()`.
4. The statement is not executed, as specified in [SQL §6.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#62-binding-procedure) rule 3. The error message is _unspecified_.

The binding of every other value is that of [SQL §6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#6-parameter-binding).

#### 7.2.1. Example: Matching a list of values

```ballerina
import ballerina/sql;
import ballerinax/mysql;

# Counts the students with the given IDs.
function countStudents(mysql:Client db, int[] ids) returns int|sql:Error {
    sql:ParameterizedQuery query = sql:queryConcat(`SELECT COUNT(*) FROM students WHERE id IN (`,
            sql:arrayFlattenQuery(ids), `)`);
    return db->queryRow(query);
}
```

Each element of `ids` becomes a separate `BIGINT` parameter ([SQL §5.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#55-array-flattening)), so the query is accepted. Passing `ids` itself, as in `` `SELECT COUNT(*) FROM students WHERE id IN (${ids})` ``, returns an `sql:DataError` ([§7.2](#72-arrays) rule 1).

### 7.3. Values the driver does not support

The following outcomes of the default binding are determined by the driver:

1. A `time:TimeOfDay` or `time:Civil` value with a `utcOffset`, and an `sql:TimeValue` or `sql:DateTimeValue` holding one, is rejected with an `sql:TypeMismatchError` ([SQL §6.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#64-time-types) rules 2.3 and 3.3).
2. `sql:StructValue`, `sql:RefValue` and `sql:RowValue` are rejected by the driver, and the operation returns an `sql:DatabaseError`.

### 7.4. Errors

| Condition | Error |
|---|---|
| An array parameter, a typed array value, or an `sql:ArrayValue` | `sql:DataError`, returned |
| A `time:TimeOfDay` or `time:Civil` value with `utcOffset` | `sql:TypeMismatchError`, returned |
| `sql:StructValue`, `sql:RefValue` or `sql:RowValue` | `sql:DatabaseError`, returned |
| Any other binding failure | As specified in [SQL §6.9](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#69-errors) |

## 8. Result mapping

### 8.1. Description

Results are mapped as specified in [SQL §7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#7-result-mapping). This section states the connector's result conversion, and the JDBC types that the driver reports for MySQL column types, which select the rows of [SQL §7.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#76-column-conversion) and [SQL §7.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#77-unmatched-columns) that apply.

### 8.2. Result conversion

1. The connector supplies its own result conversion and an `sql:CustomResultIterator`, `mysql:CustomResultIterator`, so its conversion applies to the rows of `query` streams, to `queryRow`, to the `queryResult` streams of `call`, and to OUT and INOUT parameters ([SQL §17.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#175-interactions)).
2. The conversion is that of [SQL §7.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#76-column-conversion) and [SQL §12.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#127-out-parameter-type-mapping) for every JDBC type and target type.
3. `mysql:CustomResultIterator` is the class of that iterator. The behaviour of a value of this class created by a program is _unspecified_.

### 8.3. MySQL column types

The driver reports the following JDBC types for MySQL column types; the conversion of each is the [SQL §7.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#76-column-conversion) row of that JDBC type, and the default type of a column of an open record is the [SQL §7.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#77-unmatched-columns) row.

| MySQL type | JDBC type | Notes |
|---|---|---|
| `TINYINT(1)`, `BOOL` | `BIT` | Converted to `boolean` by default. |
| `BIT(1)` | `BIT` | |
| `BIT(n)`, n > 1 | `BIT` | Converted to `boolean` by default and for a `boolean` target: every non-zero value becomes `true`. An `int` target gets the unsigned numeric value of the bits, for example `5` for `b'00000101'` in `BIT(8)`. A `byte[]` target gets the ⌈n/8⌉ bytes of the value, most significant byte first. A `string` target gets the n binary digits, most significant first, for example `"00000101"`. |
| `TINYINT`, `SMALLINT`, `MEDIUMINT`, `INT`, `BIGINT` | `TINYINT`, `SMALLINT`, `INTEGER`, `INTEGER`, `BIGINT` | An `UNSIGNED` value is read as `int`; for `BIGINT UNSIGNED`, see the next row. |
| `BIGINT UNSIGNED` | `BIGINT` | A `decimal` target gets the exact value, and a `string` target its decimal digits, for every value up to 2<sup>64</sup> − 1. An `int` target, and an open record, whose default type for the column is `int`, result in an `sql:DatabaseError` for a value greater than 2<sup>63</sup> − 1. |
| `DECIMAL`, `NUMERIC` | `DECIMAL` | |
| `FLOAT` | `REAL` | |
| `DOUBLE` | `DOUBLE` | |
| `DATE` | `DATE` | |
| `YEAR` | `DATE` | The first day of the year, for example `2021-01-01`. |
| `TIME` | `TIME` | A value outside `00:00:00` to `23:59:59` results in an `sql:DatabaseError` for every target type. |
| `DATETIME`, `TIMESTAMP` | `TIMESTAMP` | Fractional seconds are kept. |
| `CHAR`, `VARCHAR`, `ENUM`, `SET` | `CHAR`, `VARCHAR` | An `ENUM` or `SET` value is its string, for example `"x,y"`. |
| `TINYTEXT`, `TEXT`, `MEDIUMTEXT`, `LONGTEXT`, `JSON` | `VARCHAR`, `LONGVARCHAR` | A `JSON` column can be read into a `json` target. |
| `BINARY`, `VARBINARY` | `BINARY`, `VARBINARY` | |
| `TINYBLOB`, `BLOB`, `MEDIUMBLOB`, `LONGBLOB` | `VARBINARY`, `LONGVARBINARY` | |
| `GEOMETRY` and the other spatial types | `BINARY` | The internal MySQL representation of the value as `byte[]`. |

The JDBC type reported for a MySQL type is driver-defined; the table states it for MySQL Connector/J 8.

#### 8.3.1. Example: MySQL column types

```ballerina
import ballerina/sql;
import ballerinax/mysql;

type Item record {|
    boolean active;
    string tags;
    json attributes;
|};

# Reads the item with the given ID.
function getItem(mysql:Client db, int id) returns Item|sql:Error {
    return db->queryRow(`SELECT active, tags, attributes FROM items WHERE id = ${id}`);
}
```

For a table with `active TINYINT(1)`, `tags SET('new','sale')` and `attributes JSON`, a row `(1, 'new,sale', '{"k": 1}')` maps to `{active: true, tags: "new,sale", attributes: {k: 1}}` ([§8.3](#83-mysql-column-types), [SQL §7.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#76-column-conversion)).

### 8.4. Time zones

1. Without `serverTimezone`, the driver does not convert `DATETIME` and `TIMESTAMP` values: the date and time fields of a value are those stored, and [SQL §7.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#76-column-conversion) rule 5 applies.
2. With `serverTimezone`, the driver interprets the date and time fields of `DATETIME` and `TIMESTAMP` values read from the server in that time zone, and converts them to the JVM default time zone before the conversion of [SQL §7.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#76-column-conversion); values bound as `TIMESTAMP` are converted in the opposite direction.
3. The conversions of rule 2 are driver-defined.

For example, with the JVM default time zone UTC and `serverTimezone` `"Asia/Colombo"` (UTC+05:30), a `DATETIME` value `2021-02-03 10:20:30` is read as the `time:Civil` value `2021-02-03T04:50:30`.

### 8.5. Errors

| Condition | Error |
|---|---|
| A `BIGINT UNSIGNED` value greater than 2<sup>63</sup> − 1 into an `int` target or an open record | `sql:DatabaseError` |
| A `TIME` value outside `00:00:00` to `23:59:59` | `sql:DatabaseError` |
| A `BIT(1)` column into a `byte[]` target | `sql:TypeMismatchError` |
| Any other failure | As specified in [SQL §7.8](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#78-errors) |

For `query`, a target type that the JDBC type does not accept is reported before the first row, and the other errors for the row ([SQL §7.8](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#78-errors), [SQL §8.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#85-errors)); `queryRow` returns them ([SQL §9](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#9-query-row)).

## 9. Stored procedure calls

### 9.1. Description

Procedures and functions are called as specified in [SQL §12](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#12-stored-procedure-calls). This section states the MySQL-specific outcomes.

### 9.2. Behaviour

1. A procedure is called with `` `{CALL name(...)}` `` or `` `CALL name(...)` ``, and a stored function with `` `{${ret} = call name(...)}` `` where `ret` is an OUT parameter ([SQL §12.3](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#123-call-execution)).
2. A procedure that returns result sets produces a result set as its first result, so `queryResult` holds a stream and `executionResult` is `()` after `call`. After the last result set, `getNextQueryResult` returns `false` and sets `executionResult` to an `sql:ExecutionResult` with the procedure's update count.
3. `sql:CursorOutParameter` is not supported: the `call` method returns an `sql:DatabaseError`.
4. The driver determines the parameter types of a call from the parameter metadata of the procedure. On MySQL 8, a user with the `EXECUTE` privilege on a procedure can read that metadata also without access to the procedure body, so the call succeeds whatever `noAccessToProcedureBodies` is. When the driver cannot read the metadata, every parameter is treated as an INOUT `VARCHAR` parameter if `noAccessToProcedureBodies` is `true`, and the call fails with an `sql:DatabaseError` otherwise (driver-defined).
5. The registration of OUT and INOUT parameters and the conversion of their values are those of [SQL §12.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#125-out-and-inout-parameter-registration) and [SQL §12.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#127-out-parameter-type-mapping). Whether the driver accepts a registered SQL type that differs from the procedure's parameter type, and how it converts the value, is driver-defined.
6. Calling a built-in function in the function call form `` `{${ret} = call name(...)}` `` fails when none of its arguments is a parameter, as in `` `{${ret} = call NOW()}` ``: `call` returns an `sql:Error` that is none of its subtypes ([SQL §15.3](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#153-mapping) rule 5). With an argument given as a parameter, as in `` `{${ret} = call abs(${n})}` ``, the call succeeds.

### 9.3. Errors

| Condition | Error |
|---|---|
| A `sql:CursorOutParameter` in the call | `sql:DatabaseError`, returned by `call` |
| The driver cannot read the parameter metadata of the procedure and `noAccessToProcedureBodies` is `false` | `sql:DatabaseError`, returned by `call` |
| A call to a built-in function in the function call form without a parameter argument ([§9.2](#92-behaviour) rule 6) | `sql:Error` that is none of its subtypes, returned by `call` |
| Any other failure | As specified in [SQL §12.10](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#1210-errors) |

## 10. Connector contract

### 10.1. Description

This section states how the connector meets the connector obligations of [SQL §17.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#172-connector-obligations), and lists the override points of [SQL §17.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#174-override-points) that it uses.

### 10.2. Obligations

| [SQL §17.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#172-connector-obligations) rule | How the connector meets it |
|---|---|
| 1 | `mysql:Client` includes `sql:Client` and delegates every operation to the library ([§3.5](#35-operations)). |
| 2 | It gives the URL of [§3.4](#34-connection-url), the user and password, the data source class name of [§3.3](#33-driver), the driver options map ([SQL §17.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#172-connector-obligations) rule 2), which holds the driver properties of [§4.3](#43-driver-properties), and the pool configuration. |
| 3 | When `connectionPool` is `()`, it gives `sql:getGlobalConnectionPool()`. |
| 4 | Generated keys are requested for both `execute` and `batchExecute`; the connector offers no `sql:GeneratedKeysMode` option ([§3.5](#35-operations) rule 2). |
| 5 | The connector meets it ([SQL §11.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#112-behaviour) rule 2). |
| 6 | The connector defines no typed value, OUT parameter or INOUT parameter class. |
| 7 | The connector provides no `sql:SchemaClient`. |
| 8 | The override points are listed in [§10.3](#103-override-points). |

### 10.3. Override points

| [SQL §17.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#174-override-points) area | Used | Delta |
|---|---|---|
| Binding of basic types, `time` values and arrays | Yes | Arrays, including `time:Civil[]` and `time:TimeOfDay[]`, are rejected ([§7.2](#72-arrays) rule 1). Basic types and the other `time` values: no change. |
| Binding of typed values | Yes | Typed array values and `sql:ArrayValue` are rejected ([§7.2](#72-arrays) rules 2 and 3). Other typed values: no change. |
| Connector-defined typed values | No | |
| Record parameters | No | |
| Nil parameters | No | |
| OUT parameter registration | No | |
| Result conversion | Yes | No change ([§8.2](#82-result-conversion) rule 2). |
| OUT and INOUT values | Yes | No change ([§8.2](#82-result-conversion) rule 2). |
| Result iteration | Yes | `mysql:CustomResultIterator`, which applies the connector's result conversion; its `getNextQueryResult` behaves as [SQL §12.4.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#1242-moving-to-the-next-result). |
| Pool properties | No | No pool property is given ([§4.3](#43-driver-properties) rule 4). |
| Metric tags | Yes | [§11.2](#112-metric-tags). |
| Data source | Yes | `MysqlDataSource` or `MysqlXADataSource` ([§3.3](#33-driver), [§4.4](#44-xa-data-source)). |

## 11. Observability

### 11.1. Description

The pool metrics of [SQL §16](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#16-observability) apply. The connector adds the metric tags of [SQL §16.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#164-tags) rule 3.

### 11.2. Metric tags

| Tag | Value | Present |
|---|---|---|
| `db_host` | `host`, as given to the initializer | Always |
| `db_port` | The port of the primary host as a decimal integer: `port` when it is greater than `0`, otherwise `3306` ([§3.2](#32-configuration)) | Always |
| `db_name` | `database` | When `database` is neither `()` nor `""` |

Failover hosts do not appear in the tags.

## 12. Change data capture listener

### 12.1. Description

`mysql:CdcListener` is a `cdc:Listener` that captures row changes of a MySQL server from its binary log by running the Debezium MySQL connector. Services, events, the listener lifecycle and the common configuration are those of the `ballerinax/cdc` library ([CDC specification](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md)); this section specifies the MySQL-specific configuration.

### 12.2. Configuration

The initializer takes the fields of `mysql:MySqlListenerConfiguration` as named arguments. It includes `cdc:ListenerConfiguration` and adds:

| Field | Type | Default | Meaning |
|---|---|---|---|
| `database` | `mysql:MySqlDatabaseConnection` | Required | Server connection and capture filters. |
| `options` | `mysql:MySqlOptions` | `{}` | CDC options. |

`mysql:MySqlDatabaseConnection` includes `cdc:DatabaseConnection` (which holds, among others, `username` and `password`) and adds or overrides the following fields. Each field sets the Debezium property named in the last column; a list is joined with `,`.

| Field | Type | Default | Meaning | Debezium property |
|---|---|---|---|---|
| `connectorClass` | `string` | `"io.debezium.connector.mysql.MySqlConnector"` | Debezium connector class. | `connector.class` |
| `hostname` | `string` | `"localhost"` | Server host. | `database.hostname` |
| `port` | `int` | `3306` | Server port. | `database.port` |
| `databaseServerId` | `string` | a random integer in the range 1 to 99999, chosen when the listener is initialized | Server ID with which the listener joins the replication topology as a replica. It MUST be configured when the listener must keep its identity across restarts or share a server with other replicas ([§12.5](#125-interactions)). | `database.server.id` |
| `includedDatabases` | `string\|string[]` | absent | Regular expressions of the databases to capture. | `database.include.list` |
| `excludedDatabases` | `string\|string[]` | absent | Regular expressions of the databases not to capture. | `database.exclude.list` |
| `includedTables`, `excludedTables`, `includedColumns`, `excludedColumns`, `messageKeyColumns` | as in `cdc:DatabaseConnection` | absent | Table and column filters and message keys, set by the `ballerinax/cdc` library ([CDC §2.1](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md#21-listener)). | _implementation-defined_ by the `ballerinax/cdc` library |
| `tasksMax` | `int` | `1` | Number of connector tasks. The MySQL connector always uses one task. | `tasks.max` |
| `replicationConfig` | `mysql:ReplicationConfiguration` | absent | GTID filters. | see below |
| `binlogConfig` | `mysql:BinlogConfiguration` | absent | Binary log reader settings. | see below |

| Record | Field | Type | Default | Meaning | Debezium property |
|---|---|---|---|---|---|
| `mysql:ReplicationConfiguration` | `gtidSourceIncludes` | `string\|string[]` | absent | GTID source UUIDs to include. | `gtid.source.includes` |
| | `gtidSourceExcludes` | `string\|string[]` | absent | GTID source UUIDs to exclude. | `gtid.source.excludes` |
| `mysql:BinlogConfiguration` | `bufferSize` | `int` | `8192` | Size of the binary log look-ahead buffer. | `binlog.buffer.size` |

`mysql:MySqlOptions` includes `cdc:Options` and adds:

| Field | Type | Default | Meaning |
|---|---|---|---|
| `extendedSnapshot` | `mysql:ExtendedSnapshotConfiguration` | absent | Snapshot settings: the fields of `cdc:RelationalExtendedSnapshotConfiguration` and `lockTimeout`. |
| `dataTypeConfig` | `mysql:DataTypeConfiguration` | absent | Data type handling: the fields of `cdc:DataTypeConfiguration` and the MySQL fields below. |
| `heartbeatConfig` | `cdc:RelationalHeartbeatConfiguration` | absent | Heartbeat settings ([CDC §2.5](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md#25-cdc-options)), set by the `ballerinax/cdc` library; the Debezium property names are _implementation-defined_ by that library. |

| Record | Field | Type | Default | Meaning | Debezium property |
|---|---|---|---|---|---|
| `mysql:ExtendedSnapshotConfiguration` | `lockTimeout` | `decimal` | `10` | Seconds to wait for table locks during a snapshot, converted to milliseconds and truncated towards zero. | `snapshot.lock.timeout.ms` |
| `mysql:DataTypeConfiguration` | `bigIntUnsignedHandlingMode` | `mysql:BigIntUnsignedHandlingMode` | `LONG` | Representation of `BIGINT UNSIGNED` values: `LONG` (`"long"`) as a 64-bit integer, which loses values greater than 2<sup>63</sup> − 1, or `PRECISE` (`"precise"`) as an exact decimal. | `bigint.unsigned.handling.mode` |
| | `timePrecisionMode` | `cdc:TimePrecisionMode` | `ADAPTIVE_TIME_MICROSECONDS` | Representation of time values, as in `cdc:DataTypeConfiguration`; the default replaces the `cdc` default `ADAPTIVE`, which the Debezium MySQL connector does not support. | `time.precision.mode` |
| | `enableTimeAdjuster` | `boolean` | `true` | Whether two-digit years are converted to four-digit years. | `enable.time.adjuster` |
| | `includeSchemaChanges` | `boolean` | `true` | Whether schema change events are produced. | `include.schema.changes` |

### 12.3. Behaviour

1. The initializer converts the configuration to Debezium properties: first the properties of the `cdc` library for the common configuration, then the MySQL properties of [§12.2](#122-configuration), then the fields of `options` that are not declared by `mysql:MySqlOptions`. A later property replaces an earlier one with the same name.
2. A property of a record field that is absent is not set, and the Debezium default applies. When `dataTypeConfig` or `extendedSnapshot` is given, the properties of all its fields are set, including those left at their defaults.
3. `databaseServerId` is chosen once per listener value; each run of the program chooses a new value unless it is configured. The chosen value is never `0`.
4. `attach`, `detach`, `start`, `gracefulStop` and `immediateStop` are those of `cdc:Listener` ([CDC §2.1](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md#21-listener)); their behaviour is _implementation-defined_ by the `ballerinax/cdc` library.
5. When `dataTypeConfig` is given and its `timePrecisionMode` is left at its default, the listener sets `time.precision.mode` to `adaptive_time_microseconds`, which is also the Debezium default that applies when `dataTypeConfig` is absent.
6. With `bigIntUnsignedHandlingMode` `PRECISE`, a `BIGINT UNSIGNED` value appears in an event as a `string` holding the base64 encoding of the minimal two's-complement big-endian bytes of the value; for example, 18446744073709551615 appears as `"AP//////////"`. When the `mysql:DataTypeConfiguration` field `decodePreciseDecimals` (`boolean`, default `false`) is `true`, such values appear as `decimal` values instead.
7. The program MUST provide the Debezium MySQL connector, for example by importing `ballerinax/mysql.cdc.driver`, and the MySQL server MUST have row-based binary logging enabled. When either is not met, the initializer and `attach` succeed and `start` returns a `cdc:Error`.

#### 12.3.1. Example: Capturing one table

```ballerina
import ballerina/log;
import ballerinax/cdc;
import ballerinax/mysql;
import ballerinax/mysql.cdc.driver as _;

listener mysql:CdcListener orders = new (database = {
    username: "cdc",
    password: "secret",
    includedDatabases: "shop",
    includedTables: "shop.orders",
    databaseServerId: "5400"
});

service cdc:Service on orders {
    # Logs each inserted order.
    remote function onCreate(record {} after, string tableName) returns error? {
        log:printInfo("order created", 'table = tableName, row = after);
    }
}
```

The listener sets `database.include.list` to `shop` and `database.server.id` to `5400`, and captures the changes of `shop.orders`, so it keeps the same server ID across restarts ([§12.2](#122-configuration), [§12.3](#123-behaviour) rules 1 and 3).

### 12.4. Errors

The listener returns the errors of the `ballerinax/cdc` library ([CDC §3.2](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md#32-errors)). In particular, a configuration that the Debezium MySQL connector rejects, a missing Debezium MySQL connector, and a server without row-based binary logging ([§12.3](#123-behaviour) rule 7) make `start` return a `cdc:Error`.

### 12.5. Interactions

- The listener does not use the `mysql:Client`, its options or its pools. Its TLS, time zone and connection settings are Debezium properties, passed as fields of `options` that `mysql:MySqlOptions` does not declare ([§12.3](#123-behaviour) rule 1).
- Two listeners, or a listener and another replica, with the same `databaseServerId` on one MySQL server interfere with each other: the server closes the earlier replication connection. The random default of `databaseServerId` can equal the ID of another replica.

## 13. Security considerations

1. The security considerations of [SQL §18](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#18-security-considerations) apply. The user and password are part of the pool key ([§3.4](#34-connection-url)), so a client never uses connections opened with the credentials of another client ([SQL §4.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#46-pool-selection) rule 6).
2. `host`, `database` and the failover hosts are placed in the connection URL without validation or escaping, so a value containing URL syntax can change the server, the database or driver properties, such as `allowMultiQueries`, which lets one `execute` call run several statements, or `sslMode`. They MUST be trusted input; a value containing URL syntax characters is logged as a warning ([§3.4](#34-connection-url) rules 5 and 6).
3. Server verification is opt-in, following the Ballerina convention that the minimal configuration connects without further settings: without `ssl`, and with `SSL_PREFERRED`, which is the default of `mode`, or `SSL_REQUIRED`, the server certificate is not verified, also when `cert` is given ([§5.3](#53-behaviour) rule 6, which also states the warning logged for `cert` with `SSL_PREFERRED`). In these cases the connection is not protected against an attacker who can intercept it. `SSL_VERIFY_CA` verifies the certificate chain against the trust store, and `SSL_VERIFY_IDENTITY` also the host name. With `SSL_PREFERRED`, the connection is unencrypted when the server does not support encryption, and with `SSL_DISABLED` it is never encrypted.
4. `allowPublicKeyRetrieval` `true` lets the driver accept the server's RSA public key from the server on an unencrypted connection, so an attacker who can intercept the connection can obtain the password.
5. The key store and trust store passwords, and `password`, are passed to the driver as data source properties; they do not appear in the metric tags ([§11.2](#112-metric-tags)), but `host` and `database` do.
6. The CDC listener reads every change of the captured databases from the binary log, which requires the `REPLICATION SLAVE` and `REPLICATION CLIENT` privileges; its offsets and schema history are stored as configured in `cdc:ListenerConfiguration` ([CDC §2.4](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md#24-listener-configuration)), by default in local files.

## 14. Static code rules

The package ships the following static code rules, which the Ballerina scan tool reports.

| Rule ID | Condition | Kind |
|---|---|---|
| `ballerinax/mysql:1` | A `mysql:Client` is created with `password` given as the empty string literal `""`; whether other arguments are checked is _unspecified_. | Vulnerability |

## 15. Planned changes

This section is informative. It lists behaviour changes planned for the next major version; the rest of this specification describes the current release.

| Change | Affected rule | Current behaviour | Planned behaviour | How to keep the current behaviour |
|---|---|---|---|---|
| URL syntax in connection parameters is rejected | [§3.4](#34-connection-url) rule 6 | A warning is logged, and the value is inserted into the URL as given. | The initializer returns an `sql:ApplicationError` when `host`, `database` or the `host` of a failover host contains one of the listed characters. | Not possible. Remove the characters, and set driver properties through the fields of `mysql:Options`. |
| Negative timeouts are rejected | [§4.6](#46-errors), [§4.2](#42-configuration) | A negative `connectTimeout` or `socketTimeout` logs a warning and means the driver's default, no timeout. | The initializer returns an `sql:ApplicationError`. | Give `0`, which also means the driver's default. |
| A trust store is used with `SSL_PREFERRED` | [§5.3](#53-behaviour) rule 6 | With `cert` and `SSL_PREFERRED`, the server certificate is not verified, and a warning is logged. | When `cert` is given, the server certificate is verified against it. | Give no `cert`. |
| `BIT(n)` with n > 1 is read as bytes by default | [§8.3](#83-mysql-column-types) `BIT(n)` row | The default type in an open record is `boolean`, and a `boolean` target gets `true` for every non-zero value. | The default type is `byte[]`, and a `boolean` target is rejected. | Read the column with an `int` or `byte[]` target, or convert it in SQL, as in `b <> 0`. |
| `BIGINT UNSIGNED` events carry decimals | [§12.3](#123-behaviour) rule 6 | With `PRECISE`, a value appears as a base64 string unless `decodePreciseDecimals` is `true`. | `decodePreciseDecimals` defaults to `true`, so a value appears as a `decimal`. | Set `decodePreciseDecimals: false`. |

## References

- [SQL specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md)
- [CDC specification](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md)
- [MySQL Connector/J configuration properties](https://dev.mysql.com/doc/connector-j/en/connector-j-reference-configuration-properties.html)
- [Debezium connector for MySQL](https://debezium.io/documentation/reference/stable/connectors/mysql.html)
- [RFC 2119: Key words for use in RFCs to Indicate Requirement Levels](https://www.rfc-editor.org/rfc/rfc2119)
- [RFC 8174: Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words](https://www.rfc-editor.org/rfc/rfc8174)
