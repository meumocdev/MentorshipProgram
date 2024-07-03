-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id,
       SUM(m.price) AS total_amount_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id,
       COUNT(distinct(order_date)) AS number_of_days_visited
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH rank_first_purchased AS
  (SELECT s.customer_id,
          m.product_name,
          DENSE_RANK() OVER (PARTITION BY s.customer_id
                             ORDER BY s.order_date) AS `rank`
   FROM sales s
   JOIN menu m ON s.product_id = m.product_id)

SELECT customer_id,
       product_name AS most_popular_item
FROM rank_first_purchased
WHERE `rank` = 1
GROUP BY customer_id, product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name as most_purchased,
       count(*) AS times_purchased
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.product_id,
         m.product_name
HAVING times_purchased =
  (SELECT count(*) AS times_purchased
   FROM sales
   GROUP BY product_id
   ORDER BY times_purchased DESC
   LIMIT 1);

-- 5. Which item was the most popular for each customer?
WITH rank_popular AS
  (SELECT s.customer_id,
          m.product_name,
          count(m.product_name) AS order_count,
          DENSE_RANK() OVER (PARTITION BY s.customer_id
                            ORDER BY count(m.product_name) DESC) AS `rank`
   FROM sales s
   JOIN menu m ON s.product_id = m.product_id
   GROUP BY s.customer_id,
            m.product_name)
SELECT customer_id,
       product_name as most_popular,
       order_count
FROM rank_popular
WHERE `rank` = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH rank_purchase_after_member AS
  (SELECT s.customer_id,
          mn.product_name,
          DENSE_RANK() OVER (PARTITION BY s.customer_id
                             ORDER BY s.order_date) AS `rank`
   FROM members m
   JOIN sales s ON m.customer_id = s.customer_id
   JOIN menu mn ON s.product_id = mn.product_id
   WHERE s.order_date > m.join_date )

SELECT customer_id,
       product_name AS first_purchased_after_member
FROM rank_purchase_after_member
WHERE `rank` = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH rank_purchase_before_member AS
  (SELECT s.customer_id,
          mn.product_name,
          DENSE_RANK() OVER (PARTITION BY s.customer_id
                             ORDER BY s.order_date desc) AS `rank`
   FROM members m
   JOIN sales s ON m.customer_id = s.customer_id
   JOIN menu mn ON s.product_id = mn.product_id
   WHERE s.order_date < m.join_date )

SELECT customer_id,
       product_name AS last_purchased_before_member
FROM rank_purchase_before_member
WHERE `rank` = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id,
       COUNT(*) AS total_items,
       SUM(mn.price) AS total_amount
FROM members m
JOIN sales s ON m.customer_id = s.customer_id
JOIN menu mn ON s.product_id = mn.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id;
   
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH points_each_sale AS
  (SELECT s.customer_id,
          CASE
              WHEN m.product_name = 'sushi' THEN 20 * m.price
              ELSE 10 * m.price
          END AS points
   FROM sales s
   JOIN menu m ON s.product_id = m.product_id)
   
SELECT customer_id,
       sum(points) AS total_points
FROM points_each_sale
GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH points_each_sale_member AS
  (SELECT s.customer_id,
          s.order_date,
          CASE
              WHEN mn.product_name = 'sushi'
                   OR datediff(s.order_date, m.join_date) BETWEEN 0 AND 6 THEN 20 * mn.price
              ELSE 10 * mn.price
          END AS points
   FROM menu mn
   JOIN sales s ON mn.product_id = s.product_id
   LEFT JOIN members m ON s.customer_id = m.customer_id)
   
SELECT customer_id,
       sum(points) AS total_points
FROM points_each_sale_member
WHERE order_date <= '2021-01-31'
  AND customer_id in ('A', 'B')
GROUP BY customer_id
ORDER BY customer_id;

-- If only count the points after A and B become members
WITH points_each_sale_member AS
  (SELECT s.customer_id,
          s.order_date,
          m.join_date,
          CASE
              WHEN mn.product_name = 'sushi'
                   OR datediff(s.order_date, m.join_date) BETWEEN 0 AND 6 THEN 20 * mn.price
              ELSE 10 * mn.price
          END AS points
   FROM menu mn
   JOIN sales s ON mn.product_id = s.product_id
   LEFT JOIN members m ON s.customer_id = m.customer_id)
   
SELECT customer_id,
       sum(points) AS total_points
FROM points_each_sale_member
WHERE order_date BETWEEN join_date AND '2021-01-31'
  AND customer_id in ('A', 'B')
GROUP BY customer_id
ORDER BY customer_id;
