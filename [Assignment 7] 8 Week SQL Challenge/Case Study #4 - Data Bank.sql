-- 1. How many unique nodes are there on the Data Bank system?
SELECT COUNT (DISTINCT (node_id))
FROM customer_nodes

-- 2. What is the number of nodes per region?
SELECT 
  DISTINCT r.region_name,
  COUNT (node_id)
FROM customer_nodes c
LEFT JOIN regions r on c.region_id = r.region_id
GROUP BY r.region_name

-- 3. How many customers are allocated to each region?
SELECT 
  DISTINCT r.region_name,
  COUNT customer_id
FROM customer_nodes c
LEFT JOIN regions r on c.region_id = r.region_id
GROUP BY r.region_name

-- 4. How many days on average are customers reallocated to a different node?
WITH days(
  SELECT 
    c.customer_id,
    c.node_id,
    (c.end_date - c.start_date) as days_reallocated
  FROM customer_nodes c
  LEFT JOIN regions r on c.region_id = r.region_id
  GROUP BY c.customer_id, c.node_id
)
WITH total_days(
  SELECT 
    c.customer_id,
    c.node_id,
    SUM (days_reallocated) as sum_days
  FROM days
  GROUP BY c.customer_id, c.node_id
)
SELECT AVG(sum_days)
FROM total_days

-- 🏦 B. Customer Transactions
-- 1. What is the unique count and total amount for each transaction type?
SELECT 
  c.txt_type,
  COUNT(customer_id) AS transaction_count,
  SUM (c.txt_amount) AS total_amount
FROM customer_transactions c
GROUP BY c.txt_type

-- 2. What is the average total historical deposit counts and amounts for all customers?
WITH total_deposit(
  SELECT 
    c.customer_id
    COUNT (c.txt_type)
    SUM (c.txt_amount)
  FROM customer_transactions c
  GROUP BY c.customer_id
  WHERE c.txt_type = 'deposit'
)

-- 3.For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 purchase in a single month?
WITH each_months(
  SELECT 
    customer_id,
    DATEPART(month,txt_date) AS months 
    SUM(CASE WHEN xn_type = 'deposit' THEN 1 ELSE 0 END) AS total_deposit,
    SUM(CASE WHEN xn_type = 'purchase' THEN 1 ELSE 0 END) AS total_purchase,
    SUM(CASE WHEN xn_type = 'purchase' THEN 1 ELSE 0 END) AS total_purchase
  FROM customer_transactions c
  GROUP BY customer_id
)
SELECT
  months,
  COUNT(customer_id).
  total_deposit,
  total_purchase,
  total_purchase
FROM each_months
WHERE total_deposit > 1 AND 
  (total_purchase >=1 OR total_purchase>=1)
GROUP BY months






