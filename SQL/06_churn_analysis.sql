-- Activity tiers based on recency
SELECT
    CASE
        WHEN recency_days <= 14 THEN 'Active (0-14 days)'
        WHEN recency_days <= 30 THEN 'Cooling (15-30 days)'
        WHEN recency_days <= 60 THEN 'At Risk (31-60 days)'
        ELSE 'Churned (60+ days)'
    END AS activity_status,
    COUNT(*) AS num_customers,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(AVG(frequency), 2) AS avg_frequency
FROM customer_rfm
GROUP BY activity_status
ORDER BY MIN(recency_days);

-- Active vs inactive summary (headline stat)
SELECT
    CASE WHEN recency_days <= 30 THEN 'Active' ELSE 'Inactive/Churned' END AS status,
    COUNT(*) AS num_customers,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(SUM(monetary), 2) AS total_monetary,
    ROUND(AVG(frequency), 2) AS avg_frequency
FROM customer_rfm
GROUP BY status;