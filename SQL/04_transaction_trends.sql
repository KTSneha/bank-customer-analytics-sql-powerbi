-- Monthly transaction summary
SELECT
    DATE_FORMAT(transaction_date, '%Y-%m') AS month,
    COUNT(*) AS total_transactions,
    SUM(transaction_amount) AS total_value,
    ROUND(AVG(transaction_amount), 2) AS avg_transaction_value
FROM transactions
GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
ORDER BY month;

-- Day-of-week pattern
SELECT
    DAYNAME(transaction_date) AS day_of_week,
    COUNT(*) AS total_transactions,
    SUM(transaction_amount) AS total_value
FROM transactions
GROUP BY DAYNAME(transaction_date), DAYOFWEEK(transaction_date)
ORDER BY DAYOFWEEK(transaction_date);

-- Daily trend table with 7-day rolling average (feeds Power BI)
CREATE TABLE daily_trend AS
SELECT
    transaction_date,
    COUNT(*) AS daily_transactions,
    SUM(transaction_amount) AS daily_value
FROM transactions
GROUP BY transaction_date;

SELECT
    transaction_date,
    daily_transactions,
    daily_value,
    ROUND(AVG(daily_value) OVER (ORDER BY transaction_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS rolling_7day_avg
FROM daily_trend
ORDER BY transaction_date;