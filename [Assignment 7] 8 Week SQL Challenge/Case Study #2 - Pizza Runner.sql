--B. Runner and Customer Experience
--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) 
SELECT 
  DATEPART(WEEK, r.registration_date),
  COUNT r.runner_id
FROM runners r
  GROUP BY DATEPART(WEEK, r.registration_date)

--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order
WITH time_taken_cte AS
(  
  SELECT
    r.order_id,
    r.pickup_time,
    c.order_time,
    DATEDIFF(MINUTE,c.order_time,r.pickup_time) as pickup_minutes
  FROM runner_orders r
  JOIN customer_orders c
  ON r.order_id=c.order_id
  WHERE r.distance > 0
  GROUP BY r.order_id, r.pickup_time, c.order_time
)
SELECT
  AVG(pickup_minutes) as avg_pickup_minutes
FROM time_taken_cte
WHERE pickup_minutes > 0

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH time_prepare_cte AS
(
  SELECT
    c.order_id,
    COUNT(c.order_id) as order_pizza
    r.pickup_time,
    c.order_time,
    DATEDIFF(MINUTE,c.order_time,r.pickup_time) as pickup_minutes
  FROM customer_orders c
  JOIN runner_orders r
  ON r.order_id=c.order_id
  WHERE r.distance > 0
  GROUP BY c.order_id,r.pickup_time,c.order_time
)
SELECT 
  order_pizza, 
  pickup_minutes
FROM time_prepare_cte
WHERE pickup_minutes > 0
GROUP BY order_pizza

-- 4. Average delivery distance corresponding to each customer ?
SELECT 
  c.customer_id,
  AVG(r.distance) as avg_distance
FROM customer_orders c
JOIN customer_orders c
ON r.order_id=c.order_id 
GROUP BY c.customer_id,

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(r.distance) - MIN(r.distance)
FROM runner_orders r
WHERE r.distance > 0

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
  r.runner_id, 
  r.order_id,
  c.customer_id,
  ROUND((r.distance / r.duration),2) as avg_speed
FROM runner_orders r
JOIN customer_orders c
ON r.order_id=c.order_id 
GROUP BY r.runner_id, r.order_id,c.customer_id

-- 7. What is the successful delivery percentage for each runner?
SELECT 
  r.runner_id,
  ROUND(SUM (CASE 
    WHEN r.distance > 0 then 1 
    else 0 end) * 100/count(r.order_id)
FROM runner_orders r
GROUP BY r.runner_id
