Ballerina MySQL library
===================

  [![Build](https://github.com/ballerina-platform/module-ballerinax-mysql/workflows/Build/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-mysql/actions?query=workflow%3ABuild)
  [![GitHub Release](https://img.shields.io/github/release/ballerina-platform/module-ballerinax-mysql.svg)](https://central.ballerina.io/ballerinax/mysql)
  [![GitHub Release Date](https://img.shields.io/github/release-date/ballerina-platform/module-ballerinax-mysql.svg)](https://central.ballerina.io/ballerinax/mysql)
  [![GitHub Open Issues](https://img.shields.io/github/issues-raw/ballerina-platform/module-ballerinax-mysql.svg)](https://github.com/ballerina-platform/module-ballerinax-mysql)
  [![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-mysql.svg)](https://github.com/ballerina-platform/module-ballerinax-mysql/commits/master)
  [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

MySQL Driver for <a target="_blank" href="https://ballerina.io/">Ballerina</a> language.

For more information on all the operations supported by the `mysql:Client`, which includes the below mentioned operations, see [API Docs](https://ballerina.io/swan-lake/learn/api-docs/ballerina/mysql/).

1. Connection Pooling
1. Querying data
1. Inserting data
1. Updating data
1. Deleting data
1. Batch insert and update data
1. Execute stored procedures
1. Closing client

For a quick sample on demonstrating the usage see [Ballerina By Example](https://ballerina.io/swan-lake/learn/by-example/)

## Building from the source

The MySQL library is tested with a docker based integration test framework. The test framework initializes the docker container before executing the test suite.

1. Install and run docker in daemon mode.

    *  Installing docker on Linux,<br>
       Note:<br>    These commands retrieve content from get.docker.com web in a quiet output-document mode and install.Then we need to stop docker service as it needs to restart docker in daemon mode. After that, we need to export docker daemon host.
       
            wget -qO- https://get.docker.com/ | sh
            sudo service dockerd stop
            export DOCKER_HOST=tcp://172.17.0.1:4326
            docker daemon -H tcp://172.17.0.1:4326

    *  On installing docker on Mac, see <a target="_blank" href="https://docs.docker.com/docker-for-mac/">Get started with Docker for Mac</a>

    *  On installing docker on Windows, see <a target="_blank" href="https://docs.docker.com/docker-for-windows/">Get started with Docker for Windows</a>

2. To run the integration tests, issue the following commands.

        ./gradlew clean test

3. To build the module without tests,

        ./gradlew clean build -x test

4. To debug the tests,

        ./gradlew clean build -Pdebug=<port>

## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community. To start contributing, read these [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md) for information on how you should go about contributing to our project.

Check the issue tracker for open issues that interest you. We look forward to receiving your contributions.

## Useful links

* The ballerina-dev@googlegroups.com mailing list is for discussing code changes to the Ballerina project.
* Chat live with us on our [Slack channel](https://ballerina.io/community/slack/).
* Technical questions should be posted on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
* Ballerina performance test results are available [here](performance/benchmarks/summary.md).
