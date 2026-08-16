-- Load raw CSV into staging table
-- (Run in MySQL Workbench with local_infile enabled)
LOAD DATA LOCAL INFILE 'bank_transactions.csv'
INTO TABLE staging_bank_data
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(TransactionID, CustomerID, CustomerDOB, CustGender, CustLocation, CustAccountBalance, TransactionDate, TransactionTime, TransactionAmount);

-- Populate customers table (deduplicated, DOB validated)
INSERT IGNORE INTO customers (customer_id, dob, gender, location)
SELECT
    TRIM(CustomerID),
    MIN(CASE 
        WHEN CustomerDOB REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{2}$' 
        THEN STR_TO_DATE(CustomerDOB, '%d/%m/%y')
        ELSE NULL
    END),
    MIN(CustGender),
    MIN(CustLocation)
FROM staging_bank_data
WHERE CustomerID IS NOT NULL AND TRIM(CustomerID) != ''
GROUP BY TRIM(CustomerID);

-- Populate transactions table (only for valid customer_ids)
INSERT INTO transactions (transaction_id, customer_id, transaction_date, transaction_time, transaction_amount, account_balance)
SELECT
    TransactionID,
    TRIM(CustomerID),
    CASE 
        WHEN TransactionDate REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{2}$' 
        THEN STR_TO_DATE(TransactionDate, '%d/%m/%y')
        ELSE NULL
    END,
    TransactionTime,
    CASE WHEN TransactionAmount REGEXP '^[0-9]+\\.?[0-9]*$' THEN CAST(TransactionAmount AS DECIMAL(15,2)) ELSE NULL END,
    CASE WHEN CustAccountBalance REGEXP '^[0-9]+\\.?[0-9]*$' THEN CAST(CustAccountBalance AS DECIMAL(15,2)) ELSE NULL END
FROM staging_bank_data
WHERE TRIM(CustomerID) IN (SELECT customer_id FROM customers);