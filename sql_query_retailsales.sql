--Create [Retail Sales] Database with its table
CREATE DATABASE retail_sales;
CREATE SCHEMA rtl_sales;
CREATE TABLE retail_sales (
		transactions_id	INT PRIMARY KEY,
		sale_date DATE,
		sale_time TIME,	
		customer_id	INT,
		gender VARCHAR(10),
		age	INT,
		category VARCHAR(20),	
		quantiy	INT,
		price_per_unit FLOAT,	
		cogs FLOAT,	
		total_sale INT
)

-- Data Cleaning
SELECT * FROM rtl_sales.retail_sales
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantiy IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL
;

DELETE FROM rtl_sales.retail_sales
WHERE 
    transactions_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantiy IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL
;

-- Data Analysis & Business Key Problems
--- Q.1 Time-Based Analysis
---- Q.1.1 Bagaimana tren total penjualan setiap bulan?
SELECT
EXTRACT(YEAR FROM sale_date) AS Year,
EXTRACT(MONTH FROM sale_date) AS Month,
SUM(total_sale)
FROM rtl_sales.retail_sales
WHERE EXTRACT(YEAR FROM sale_date)='2022'
GROUP BY 1,2
ORDER BY 1,2;

---- Q.1.2 Pada tanggal berapa penjualan mencapai puncaknya?
SELECT 
	sale_date,
	SUM(total_sale) 
FROM rtl_sales.retail_sales
WHERE EXTRACT(YEAR FROM sale_date)='2023'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

---- Q.1.3 Jam berapa penjualan paling tinggi secara total?
SELECT 
	EXTRACT(HOUR FROM sale_time) AS Hour,
	SUM(total_sale) 
FROM rtl_sales.retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

---- Q.1.4 Hari dalam seminggu mana yang memiliki rata-rata penjualan tertinggi?
SELECT 
	TO_CHAR(sale_date,'Day') AS Day,
	ROUND(AVG(total_sale),2) AS avg_sales
FROM rtl_sales.retail_sales
GROUP BY 1
ORDER BY 2 DESC;

--- Q.2 Product Analysis
---- Q.2.1 Produk atau kategori mana yang paling banyak terjual?
SELECT 
	category,
	SUM(quantiy) AS total 
FROM rtl_sales.retail_sales
--WHERE EXTRACT(YEAR FROM sale_date)='2023'
GROUP BY 1
ORDER BY 2 DESC;

---- Q.2.2 Produk atau kategori mana yang menghasilkan penjualan (revenue) terbesar?
SELECT 
	category, 
	SUM(total_sale) 
FROM rtl_sales.retail_sales
GROUP BY 1
ORDER BY 2 DESC;

---- Q.2.3 Produk/kategori mana yang punya penjualan konsisten setiap bulan?
WITH monthly_sales AS (
  SELECT 
    category,
    DATE_TRUNC('month', sale_date) AS month,
    SUM(quantiy) AS total_quantity
  FROM rtl_sales.retail_sales
  GROUP BY 1, 2
),
category_variation AS (
  SELECT 
    category,
    MAX(total_quantity) - MIN(total_quantity) AS range_quantity
  FROM monthly_sales
  GROUP BY 1
)
SELECT * 
FROM category_variation
ORDER BY range_quantity DESC
;

---- Q.2.4 Apakah ada tren penjualan naik atau turun untuk kategori tertentu?
--FOR 'Beauty'
WITH monthly_sales AS (
  SELECT
    category,
    DATE_TRUNC('month', sale_date) AS month,
    SUM(quantiy) AS total_quantity
  FROM rtl_sales.retail_sales
  GROUP BY category, DATE_TRUNC('month', sale_date)
),
sales_with_growth AS (
  SELECT 
    category,
    month,
    total_quantity,
    LAG(total_quantity) OVER (PARTITION BY category ORDER BY month) AS previous_quantity,
    ROUND(
      100.0 * (total_quantity - LAG(total_quantity) OVER (PARTITION BY category ORDER BY month)) 
      / NULLIF(LAG(total_quantity) OVER (PARTITION BY category ORDER BY month), 0), 2
    ) AS growth_percent
  FROM monthly_sales
)
SELECT * 
FROM sales_with_growth
WHERE category = 'Beauty'
ORDER BY category, month;

--FOR 'Electronics'
WITH monthly_sales AS (
  SELECT
    category,
    DATE_TRUNC('month', sale_date) AS month,
    SUM(quantiy) AS total_quantity
  FROM rtl_sales.retail_sales
  GROUP BY category, DATE_TRUNC('month', sale_date)
),
sales_with_growth AS (
  SELECT 
    category,
    month,
    total_quantity,
    LAG(total_quantity) OVER (PARTITION BY category ORDER BY month) AS previous_quantity,
    ROUND(
      100.0 * (total_quantity - LAG(total_quantity) OVER (PARTITION BY category ORDER BY month)) 
      / NULLIF(LAG(total_quantity) OVER (PARTITION BY category ORDER BY month), 0), 2
    ) AS growth_percent
  FROM monthly_sales
)
SELECT * 
FROM sales_with_growth
WHERE category = 'Electronics'
ORDER BY category, month;

--FOR 'Clothing'
WITH monthly_sales AS (
  SELECT
    category,
    DATE_TRUNC('month', sale_date) AS month,
    SUM(quantiy) AS total_quantity
  FROM rtl_sales.retail_sales
  GROUP BY category, DATE_TRUNC('month', sale_date)
),
sales_with_growth AS (
  SELECT 
    category,
    month,
    total_quantity,
    LAG(total_quantity) OVER (PARTITION BY category ORDER BY month) AS previous_quantity,
    ROUND(
      100.0 * (total_quantity - LAG(total_quantity) OVER (PARTITION BY category ORDER BY month)) 
      / NULLIF(LAG(total_quantity) OVER (PARTITION BY category ORDER BY month), 0), 2
    ) AS growth_percent
  FROM monthly_sales
)
SELECT * 
FROM sales_with_growth
WHERE category = 'Clothing'
ORDER BY category, month;

--- Q.3 Customer Analysis
---- Q.3.1 Siapa pelanggan dengan total pembelian tertinggi (top spender)?
SELECT customer_id,
SELECT
customer_id,
SUM(total_sale) AS total_sale
FROM rtl_sales.retail_sales
--WHERE EXTRACT(YEAR FROM sale_date)='2022'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

---- Q.3.2 Siapa pelanggan dengan frekuensi transaksi terbanyak?
SELECT 
customer_id,
COUNT(*) AS freq_transac
FROM rtl_sales.retail_sales
--WHERE EXTRACT(YEAR FROM sale_date)='2023'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

---- Q.3.3 Bagaimana rata-rata pembelian per transaksi per pelanggan?
SELECT 
	customer_id, 
	ROUND(AVG(total_sale),2) 
FROM rtl_sales.retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

---- Q.3.4 Apakah ada pelanggan yang hanya membeli sekali? (one-time buyer)
SELECT 
	customer_id,
	COUNT(*) AS buyer
FROM rtl_sales.retail_sales
GROUP BY 1
HAVING COUNT(*)=1;

---- Q.3.5 Bagaimana distribusi pelanggan berdasarkan total pembelian mereka?
SELECT
	spender_type,
	COUNT(customer_id)
FROM(
SELECT 
  customer_id,
  SUM(total_sale) AS total_spent,
  CASE
    WHEN SUM(total_sale) < 3000 THEN 'Low Spender'
    WHEN SUM(total_sale) BETWEEN 3000 AND 5000 THEN 'Mid Spender'
    ELSE 'High Spender'
  END AS spender_type
FROM rtl_sales.retail_sales
GROUP BY customer_id
)
GROUP BY 1;

---- Q.3.6 Siapa yang lebih banyak melakukan pembelian, laki-laki atau perempuan?
SELECT
	gender,
	COUNT(*)
FROM rtl_sales.retail_sales
GROUP BY 1;

---- Q.3.7 Siapa yang menghasilkan penjualan (revenue) lebih besar?
SELECT
	gender,
	SUM(total_sale)
FROM rtl_sales.retail_sales
GROUP BY 1;

---- Q.3.8 Siapa yang punya rata-rata pembelian per transaksi lebih tinggi?
SELECT
	gender,
	quantiy,
	AVG(total_sale)
FROM rtl_sales.retail_sales
GROUP BY 1,2
ORDER BY 3 DESC;

---- Q.3.9 Produk apa yang paling banyak dibeli oleh masing-masing gender?
SELECT 
	gender, 
	category, 
	SUM(total_sale) AS total_sale 
FROM rtl_sales.retail_sales
GROUP BY 1,2
ORDER BY 3 DESC;
