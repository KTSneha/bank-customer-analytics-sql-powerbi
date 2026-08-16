CREATE DATABASE IF NOT EXISTS bank_analytics;
USE bank_analytics;

CREATE TABLE staging_bank_data (
    row_id INT AUTO_INCREMENT PRIMARY KEY,
    TransactionID VARCHAR(20),
    CustomerID VARCHAR(20),
    CustomerDOB VARCHAR(20),
    CustGender VARCHAR(10),
    CustLocation VARCHAR(100),
    CustAccountBalance VARCHAR(30),
    TransactionDate VARCHAR(20),
    TransactionTime VARCHAR(20),
    TransactionAmount VARCHAR(30)
);

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    dob DATE,
    gender VARCHAR(10),
    location VARCHAR(100)
);

CREATE TABLE transactions (
    transaction_id VARCHAR(20),
    customer_id VARCHAR(20),
    transaction_date DATE,
    transaction_time VARCHAR(20),
    transaction_amount DECIMAL(15,2),
    account_balance DECIMAL(15,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);