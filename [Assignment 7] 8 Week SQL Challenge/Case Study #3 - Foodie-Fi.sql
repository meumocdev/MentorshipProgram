-- 1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id)
FROM subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT
  DATE_PART(month, start_date) AS month_date,
  COUNT(s.customer_id) AS trial_plan_subscriptions
FROM subscriptions s
JOIN plans p
  ON s.plan_id = p.plan_id
WHERE s.plan_id = 0 
GROUP BY DATE_PART(month,start_date)

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.
SELECT 
  p.plan_id,
  p.plan_name,
  COUNT(s.customer_id) AS num_of_events
FROM subscriptions AS s
JOIN plans p
  ON s.plan_id = p.plan_id
WHERE  DATE_PART(year, s.start_date) > 2020
GROUP BY p.plan_id, p.plan_name

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT
  COUNT(DISTINCT s.customer_id) AS churned_customers,
  ROUND(100.0 * COUNT(s.customer_id)
    / (SELECT COUNT(DISTINCT customer_id) 
    	FROM subscriptions)
  ,1) AS churn_percentage
FROM subscriptions AS s
JOIN plans p
  ON s.plan_id = p.plan_id
WHERE p.plan_id = 4;

--5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

