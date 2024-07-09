-- 📈 A. High Level Sales Analysis

-- 1. What was the total quantity sold for all products?

SELECT
  p.product_name,
  SUM(s.qty)
FROM sales s
JOIN product_details p ON s.prod_id=product_id
GROUP BY p.product_name

-- 2. What is the total generated revenue for all products before discounts?
SELECT
  p.product_name
  SUM(s.qty*s.price)
FROM sales s
JOIN product_details p ON s.prod_id=product_id
GROUP BY p.product_name

-- 3. What was the total discount amount for all products?
SELECT
  p.product_name,
  SUM(s.qty * s.prices * s.discount/100)
FROM sales s
JOIN product_details p ON s.prod_id=product_id
GROUP BY p.product_name

-- 🧾 B. Transaction Analysis
