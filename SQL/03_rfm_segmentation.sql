-- Step 1: Calculate raw RFM values per customer
CREATE TABLE customer_rfm AS
SELECT
    customer_id,
    DATEDIFF((SELECT MAX(transaction_date) FROM transactions), MAX(transaction_date)) AS recency_days,
    COUNT(*) AS frequency,
    SUM(transaction_amount) AS monetary
FROM transactions
GROUP BY customer_id;

-- Step 2: Score each customer 1-5 on R, F, M using window functions
CREATE TABLE customer_rfm_scored AS
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
    NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
FROM customer_rfm;

-- Step 3: Combine scores into final customer segments
CREATE TABLE customer_segments AS
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 4 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'
        WHEN r_score BETWEEN 2 AND 3 AND f_score >= 3 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost'
        ELSE 'Needs Attention'
    END AS segment
FROM customer_rfm_scored;

-- Segment distribution summary
SELECT segment, COUNT(*) AS num_customers, ROUND(AVG(monetary),2) AS avg_monetary
FROM customer_segments
GROUP BY segment
ORDER BY num_customers DESC;