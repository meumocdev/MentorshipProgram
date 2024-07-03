-- 🧼 A. Data Cleansing Steps
CREATE TABLE clean_weekly_sales AS(
  SELECT
  CONVERT(DATE, week_date,103) AS week_date,
  DATEPART('week', CONVERT(DATE, week_date,103)) AS week_number,
  DATEPART('month', CONVERT(DATE, week_date,103)) AS month_number,
  DATEPART('year', CONVERT(DATE, week_date,103)) AS calendar_year,
  region, 
  platform, 
  segment,
  CASE 
    WHEN RIGHT(segment,1) = '1' THEN 'Young Adults'
    WHEN RIGHT(segment,1) = '2' THEN 'Middle Aged'
    WHEN RIGHT(segment,1) in ('3','4') THEN 'Retirees'
    ELSE 'unknown' END AS age_band,
  CASE 
    WHEN LEFT(segment,1) = 'C' THEN 'Couples'
    WHEN LEFT(segment,1) = 'F' THEN 'Families'
    ELSE 'unknown' END AS demographic,
  transactions,
    CAST(ROUND(sales * 1.00 / transactions, 2) AS DECIMAL(18, 2)) AS avg_transaction,
  sales
FROM weekly_sales
)

-- 🛍 B. Data Exploration
-- 1. What day of the week is used for each week_date value?
SELECT
  DATENAME(weekday, week_date) AS week_day
FROM clean_weekly_sales;

-- 2. What range of week numbers are missing from the dataset?

-- 3. How many total transactions were there for each year in the dataset?
SELECT
  calendar_year,
  SUM(transactions)
FROM clean_weekly_sales;
GROUP BY calendar_year

-- 4. What is the total sales for each region for each month?
SELECT
  DISTINCT region,
  month_number,
  SUM(sales)
FROM clean_weekly_sales;
GROUP BY DISTINCT region,
  month_number




