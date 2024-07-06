-- 👩🏻‍💻 A. Digital Analysis
-- 1. How many users are there?
SELECT 
  COUNT user_id
FROM users

-- 2. How many cookies does each user have on average?
SELECT
  user_id,
  AVG(COUNT(cookie_id))
FROM users
GROUP BY user_id

--3. What is the unique number of visits by all users per month?
SELECT
  DATEPART(month,event_time),
  COUNT(DISTINCT visit_id)
FROM events
GROUP BY DATEPART(month,event_time)

-- 4. What is the number of events for each event type?
SELECT
  event_type,
  COUNT(*)
FROM events
GROUP BY event_type

-- 5. What is the percentage of visits which have a purchase event?
SELECT
  100 * COUNT(visit_id) as total_visits /(SELECT COUNT visit_id FROM events) ,
  
FROM events e
JOIN event_identifier i 
  ON e.event_type=i.e.event_type
WHERE e.event_name='purchase'

-- 6. What is the percentage of visits which view the checkout page but do not have a purchase event? The strategy to answer this question is to breakdown the question into 2 parts.
WITH checkout_purchase(
  SELECT
    SUM(CASE WHEN event_type = 1 AND page_id = 12 THEN 1 ELSE 0 END) AS checkoutpurchase,
    SUM(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS checkoutpurchase
  
  FROM events
)

-- 7. What are the top 3 pages by number of views?
SELECT 
  p.page_name, 
  COUNT(*) AS page_views
FROM events e
JOIN page_hierarchy AS p
  ON e.page_id = p.page_id
WHERE e.event_type = 1 
GROUP BY p.page_name
ORDER BY page_views DESC 
LIMIT 3;

-- 8. What is the number of views and cart adds for each product category?
SELECT 
  p.product_category, 
  SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
  SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds
FROM events AS e
JOIN page_hierarchy AS p
  ON e.page_id = p.page_id
WHERE p.product_category IS NOT NULL
GROUP BY p.product_category

-- 9. What are the top 3 products by purchases?
SELECT 
  p.product_category, 
  COUNT(*) AS product
FROM events e
JOIN page_hierarchy AS p
  ON e.page_id = p.page_id
WHERE e.event_type = 3 
GROUP BY p.product_category
ORDER BY product DESC 
LIMIT 3;

