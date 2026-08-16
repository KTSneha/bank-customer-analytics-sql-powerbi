-- Top locations by transaction value and customer volume
SELECT
    location,
    COUNT(DISTINCT c.customer_id) AS num_customers,
    ROUND(AVG(account_balance), 2) AS avg_balance,
    SUM(transaction_amount) AS total_value
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY location
HAVING COUNT(DISTINCT c.customer_id) >= 100
ORDER BY avg_balance DESC
LIMIT 20;