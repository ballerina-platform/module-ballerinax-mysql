CREATE DATABASE IF NOT EXISTS finance_db;
USE finance_db;

-- transactions table
CREATE TABLE transactions (
    tx_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(10,2),
    status VARCHAR(50),
    created_at DATETIME
);

-- Sample data
INSERT INTO transactions (user_id, amount, status, created_at) VALUES
(10, 9000.00, 'COMPLETED', '2025-04-01 08:00:00'),
(11, 12000.00, 'COMPLETED', '2025-04-01 08:10:00'), -- this one should trigger fraud logic
(12, 4500.00, 'PENDING',   '2025-04-01 08:30:00');
