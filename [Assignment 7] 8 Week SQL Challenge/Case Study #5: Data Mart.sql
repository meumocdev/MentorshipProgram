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
FROM clean_weekly_sales
GROUP BY calendar_year

-- 4. What is the total sales for each region for each month?
SELECT
  DISTINCT region,
  month_number,
  SUM(sales)
FROM clean_weekly_sales;
GROUP BY DISTINCT region,
  month_number

-- 5. What is the total count of transactions for each platform?
SELECT
   platform,
  SUM(transactions)
FROM clean_weekly_sales;
GROUP BY platform

-- 6. What is the percentage of sales for Retail vs Shopify for each month?
WITH sale_each_month(
  SELECT
    platform,
    month_number,
    SUM(sales) as total_sales
  FROM clean_weekly_sales;
GROUP BY platform,month_number
)
SELECT 
    platform,
    month_number,
    ROUND(100 * SUM(CASE WHEN platform='Retail' THEN total_sales ELSE NULL END)/SUM(total_sales),2) as RETAIL_PERCENTAGE
    ROUND(100 * SUM(CASE WHEN platform='Shopify' THEN total_sales ELSE NULL END)/SUM(total_sales),2) as SHOPIFY_PERCENTAGE
FROM sale_each_month
GROUP BY platform,month_number

--7. What is the percentage of sales by demographic for each year in the dataset?
WITH sale_demographic_year(
  SELECT 
    demographic,
    calendar_year,
    SUM(sales) as yearly_sales
  FROM clean_weekly_sales;
  GROUP BY demographic,calendar_year
)
SELECT 
    demographic,
    calendar_year,
    ROUND(100* SUM(CASE WHEN demographic='Couples' then yearly_sale ELSE NULL END/SUM(yearly_sales)),2) as Couples_Percentage
    ROUND(100* SUM(CASE WHEN demographic='Families' then yearly_sale ELSE NULL END/SUM(yearly_sales)),2) as Families_Percentage
    ROUND(100* SUM(CASE WHEN demographic='unknown' then yearly_sale ELSE NULL END/SUM(yearly_sales)),2) as unknown_Percentage
FROM sale_demographic_year
GROUP BY demographic,calendar_year

-- 8. Which age_band and demographic values contribute the most to Retail sales?
WITH age_demographic_retail_sale(
    SELECT 
    age_band,
    demographic,
    SUM(sales) as total_sale,
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band,demographic
)
SELECT 
    age_band,
    demographic,
    SUM(sales),
FROM age_demographic_retail_sale
WHERE MAX(total_sale)

-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT 
  calendar_year, 
  platform, 
  ROUND(AVG(avg_transaction),0) AS avg_transaction_row, 
  SUM(sales) / sum(transactions) AS avg_transaction_group
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;

-- 🧼 C. Before & After Analysis
--1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
WITH sale_8_weeks(
  SELECT
  week_number,
  SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE week_number BETWEEN 20 AND 28 
  AND calendar_year=2020
GROUP BY week_number
)
WITH before_after_weeks(
  SELECT 
    week_number,
    SUM(CASE WHEN week_number BETWEEN 21 AND 24 then total_sales) as before_weeks
    SUM(CASE WHEN week_number BETWEEN 25 AND 28 then total_sales) as after_weeks
  FROM sale_8_weeks
)
SELECT 
  (after_weeks - before_weeks) AS sales_variance,
  ROUND(100 * after_weeks - before_weeks /before_weeks ,2) AS variance_percentage
FROM before_after_weeks

-- 2. What about the entire 12 weeks before and after?
WITH sale_12_weeks(
  SELECT
  week_number,
  SUM(sales) AS total_sales
FROM clean_weekly_sales
WHERE week_number BETWEEN 13 AND 37 
  AND calendar_year=2020
GROUP BY week_number
)
WITH before_after_weeks(
  SELECT 
    week_number,
    SUM(CASE WHEN week_number BETWEEN 13 AND 24 then total_sales) as before_weeks
    SUM(CASE WHEN week_number BETWEEN 25 AND 37 then total_sales) as after_weeks
  FROM sale_8_weeks
)
SELECT 
  (after_weeks - before_weeks) AS sales_variance,
  ROUND(100 * after_weeks - before_weeks /before_weeks ,2) AS variance_percentage
FROM before_after_weeks


