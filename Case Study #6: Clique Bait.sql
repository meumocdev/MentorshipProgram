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

-- B. Product Funnel Analysis
WITH purchase_events AS (
    SELECT DISTINCT visit_id
    FROM events
    WHERE event_type = 3
),
product_info AS (
    SELECT 
        ph.page_name AS products_name,
        ph.product_category,
        SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS viewed,
        SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds,
        SUM(CASE WHEN e.event_type = 2 AND pe.visit_id IS NOT NULL THEN 1 ELSE 0 END) AS purchases,
        SUM(CASE WHEN e.event_type = 2 AND pe.visit_id IS NULL THEN 1 ELSE 0 END) AS abandoned
    FROM events e
    JOIN page_hierarchy ph ON e.page_id = ph.page_id
    LEFT JOIN purchase_events pe ON e.visit_id = pe.visit_id
    WHERE ph.product_id IS NOT NULL
    GROUP BY ph.page_name, ph.product_category
)
-- 1. Which product had the most views, cart adds and purchases?
SELECT 
    products_name, 
    product_category, 
    viewed + cart_adds + purchases AS most_views_cart_adds_purchases
FROM product_info
ORDER BY most_views_cart_adds_purchases DESC
LIMIT 1

-- 2. Which product was most likely to be abandoned?
SELECT 
    products_name, 
    product_category, 
    abandoned
FROM product_info
ORDER BY abandoned
LIMIT 1 

-- 3. Which product had the highest view to purchase percentage? 
SELECT 
    product_name, 
    product_category, 
    ROUND(100.0 * purchases / viewed, 2) AS purchase_per_view_percentage
FROM product_info
ORDER BY purchase_per_view_percentage DESC
	
-- 4. What is the average conversion rate from view to cart add?
SELECT 
    AVG(CASE WHEN viewed = 0 THEN 0 ELSE (cart_adds / viewed) END) AS avg_conversion_rate
FROM product_info
	
-- 5. What is the average conversion rate from cart add to purchase? 
 SELECT 
    ROUND(100.0 * AVG(cart_adds / viewed), 2) AS avg_view_to_cart_add_conversion,
    ROUND(100.0 * AVG(purchases / cart_adds), 2) AS avg_cart_add_to_purchases_conversion_rate
FROM product_info
