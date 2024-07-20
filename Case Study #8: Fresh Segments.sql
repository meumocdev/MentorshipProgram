-- A. Data Exploration and Cleansing
-- 1. Update the interest_metrics table by modifying the month_year column to be a date data type with the start of the month
ALTER TABLE interest_metrics
MODIFY COLUMN month_year VARCHAR(10);

UPDATE interest_metrics
SET month_year = STR_TO_DATE(CONCAT('01-', month_year), '%d-%m-%Y');

ALTER TABLE interest_metrics
MODIFY COLUMN month_year DATE;

-- 2. What is the count of records in the interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
SELECT month_year, COUNT(*)
FROM interest_metrics
GROUP BY month_year;

-- 3. What should we do with these null values in the interest_metrics?
SELECT *
FROM interest_metrics
WHERE month_year IS NULL
ORDER BY interest_id DESC;

DELETE FROM interest_metrics
WHERE interest_id IS NULL;

-- 4. How many interest_id values exist in the interest_metrics table but not in the interest_map table? What about the other way around?
ALTER TABLE interest_metrics ADD COLUMN interest_id_temp INTEGER;
UPDATE interest_metrics SET interest_id_temp = CAST(interest_id AS UNSIGNED);
ALTER TABLE interest_metrics DROP COLUMN interest_id;
ALTER TABLE interest_metrics CHANGE COLUMN interest_id_temp interest_id INTEGER;

SELECT 
  COUNT(DISTINCT map.id) AS map_id_count,
  COUNT(DISTINCT metrics.interest_id) AS metrics_id_count,
  SUM(CASE WHEN map.id IS NULL THEN 1 ELSE 0 END) AS not_in_metric,
  SUM(CASE WHEN metrics.interest_id IS NULL THEN 1 ELSE 0 END) AS not_in_map
FROM interest_map map
LEFT JOIN interest_metrics metrics ON map.id = metrics.interest_id
UNION ALL
SELECT 
  COUNT(DISTINCT map.id) AS map_id_count,
  COUNT(DISTINCT metrics.interest_id) AS metrics_id_count,
  SUM(CASE WHEN map.id IS NULL THEN 1 ELSE 0 END) AS not_in_metric,
  SUM(CASE WHEN metrics.interest_id IS NULL THEN 1 ELSE 0 END) AS not_in_map
FROM interest_metrics metrics
LEFT JOIN interest_map map ON metrics.interest_id = map.id;

-- 5. Summarize the id values in the interest_map by its total record count in this table.
SELECT COUNT(*) AS map_id_count
FROM interest_map;
