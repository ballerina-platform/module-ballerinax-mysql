# Fraud Detection 

This example demonstrates how to use the `mysql:CdcListener` to implement a fraud detection system. The system listens to table changes and processes them to identify potential fraudulent activities.

## Setup Guide

### 1. MySQL Database

1. Refer to the [Setup Guide](https://central.ballerina.io/ballerinax/mysql/latest#setup-guide) for the necessary steps to enable CDC in the MySQL server.

2. Add the necessary schema and data using the `setup.sql` script:
   ```bash
   mysql -u <username> -p < db_scripts/setup.sql
   ```

### 2. Configuration

Configure MySQL Database and Gmail API credentials in the `Config.toml` file located in the example directory:

```toml
username = "<DB Username>"
password = "<DB Password>"

refreshToken = "<Refresh Token>"
clientId = "<Client Id>"
clientSecret = "<Client Secret>"
recipient = "<Recipient Email Address>"
sender = "<Sender Email Address>"
```

Replace `<DB Username>` and `<DB Password>` with your MySQL database credentials.

Replace the Gmail API placeholders (`<Refresh Token>`, `<Client Id>`, `<Client Secret>`, `<Recipient Email Address>`, `<Sender Email Address>`) with your Gmail API credentials and email addresses.

## Setup Guide: Using Docker Compose

You can use Docker Compose to set up MySQL for this example. Follow these steps:

### 1. Start the service

Run the following command to start the MySQL service:

```bash
docker-compose up -d
```

### 2. Verify the service

Ensure `mysql` service is in a healthy state:

```bash
docker-compose ps
```

### 3. Configuration

Ensure the `Config.toml` file is updated with the following credentials:

```toml
username = "cdc_user"
password = "cdc_password"

refreshToken = "<Refresh Token>"
clientId = "<Client Id>"
clientSecret = "<Client Secret>"
recipient = "<Recipient Email Address>"
sender = "<Sender Email Address>"
```

Replace the Gmail API placeholders (`<Refresh Token>`, `<Client Id>`, `<Client Secret>`, `<Recipient Email Address>`, `<Sender Email Address>`) with your Gmail API credentials and email addresses.

## Run the Example

1. Execute the following command to run the example:

   ```bash
   bal run
   ```

2. Use the provided `test.sql` script to insert a sample transactions into the `trx` table to test the fraud detection system. Use the following SQL command:

   ```bash
   mysql -u <username> -p < db_scripts/test.sql
   ```

If using docker services,

   ```bash
   docker exec -i mysql-cdc mysql -u cdc_user -pcdc_password < db-scripts/test.sql
   ```
