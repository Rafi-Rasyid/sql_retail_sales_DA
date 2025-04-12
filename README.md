# 🛍️ Retail Sales Analysis SQL Project

## 📌 Project Overview

**Project Title**: Retail Sales Analysis – Business Insight Edition
**Tools**: PostgreSQL, SQL  
**Dataset**: Retail transaction data (originally sourced from Zero Analyst)

This project demonstrates how SQL can be used to explore and analyze retail sales data from a business-oriented perspective. The analysis is structured into three main aspects: **Time-Based Analysis**, **Product-Based Analysis**, and **Customer-Based Analysis**. The goal is not only to write queries, but also to extract actionable **insights** and develop relevant **recommendations** that support decision-making in retail strategy, customer segmentation, and product prioritization.

---

## Objectives

1. Clean and prepare the retail sales data.
2. Perform time-based, product-based, and customer-based analysis.
3. Translate query results into actionable insights.
4. Develop recommendations based on data findings.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `retail_sales`.
- **Schema Creation** : Followed by creating a scheme named `rtl_sales`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction_ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
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
);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM rtl_sales.retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM rtl_sales.retail_sales;
SELECT DISTINCT category FROM rtl_sales.retail_sales;

SELECT * FROM rtl_sales.retail_sales
WHERE 
    transactions_id IS NULL OR sale_date IS NULL
    OR sale_time IS NULL OR gender IS NULL
    OR category IS NULL OR quantiy IS NULL
    OR cogs IS NULL OR total_sale IS NULL;

DELETE FROM rtl_sales.retail_sales
WHERE 
    transactions_id IS NULL OR sale_date IS NULL
    OR sale_time IS NULL OR gender IS NULL
    OR category IS NULL OR quantiy IS NULL
    OR cogs IS NULL OR total_sale IS NULL;
```

### 3. Data Analysis & Findings

The SQL queries used to analyze the dataset and extract business insights are organized by theme:

**Time-Based Analysis**:

Q1.1 – What is the trend of total sales by month and year?
```sql
SELECT EXTRACT(YEAR FROM sale_date) AS year, EXTRACT(MONTH FROM sale_date) AS month, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY 1, 2
ORDER BY 1, 2;
```

Q1.2 – On which date did the highest sales occur?
```sql
SELECT sale_date, SUM(total_sale) AS daily_total
FROM retail_sales
GROUP BY sale_date
ORDER BY daily_total DESC
LIMIT 1;
```

Q1.3 – At what time of day do most sales occur?
```sql
SELECT EXTRACT(HOUR FROM sale_time) AS hour, SUM(total_sale) AS hourly_total
FROM retail_sales
GROUP BY hour
ORDER BY hourly_total DESC
LIMIT 1;
```

Q1.4 – Which day of the week has the highest average sales?
```sql
SELECT TO_CHAR(sale_date, 'Day') AS weekday, ROUND(AVG(total_sale), 2) AS avg_sales
FROM retail_sales
GROUP BY 1
ORDER BY avg_sales DESC;
```

**Product-Based Analysis**:

Q2.1 – Which category has the highest number of products sold?
```sql
SELECT category, SUM(quantiy) AS total_quantity
FROM retail_sales
GROUP BY category
ORDER BY total_quantity DESC;
```

Q2.2 – Which category generates the most revenue?
```sql
SELECT category, SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY category
ORDER BY total_revenue DESC;
```

Q2.3 – Which category has the most consistent monthly sales?
```sql
WITH monthly_sales AS (
  SELECT category, DATE_TRUNC('month', sale_date) AS month, SUM(quantiy) AS total_quantity
  FROM retail_sales
  GROUP BY category, month
),
category_variation AS (
  SELECT category, MAX(total_quantity) - MIN(total_quantity) AS range_quantity
  FROM monthly_sales
  GROUP BY category
)
SELECT * FROM category_variation
ORDER BY range_quantity ASC
LIMIT 1;
```

Q2.4 – What is the sales trend by category over time?
```sql
WITH monthly_sales AS (
  SELECT category, DATE_TRUNC('month', sale_date) AS month, SUM(quantiy) AS total_quantity
  FROM retail_sales
  GROUP BY category, month
),
sales_with_growth AS (
  SELECT category, month, total_quantity,
    LAG(total_quantity) OVER (PARTITION BY category ORDER BY month) AS previous_quantity,
    ROUND(100.0 * (total_quantity - LAG(total_quantity) OVER (PARTITION BY category ORDER BY month)) / NULLIF(LAG(total_quantity) OVER (PARTITION BY category ORDER BY month), 0), 2) AS growth_percent
  FROM monthly_sales
)
SELECT * FROM sales_with_growth
ORDER BY category, month;
```

**Customer-Based Analysis**:

Q3.1 – Who are the top spending customers?
```sql
SELECT customer_id, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC;
```

Q3.2 – Which customers make purchases most frequently?
```sql
SELECT customer_id, COUNT(*) AS transactions
FROM retail_sales
GROUP BY customer_id
ORDER BY transactions DESC;
```

Q3.3 – What is the average transaction value per customer?
```sql
SELECT customer_id, ROUND(AVG(total_sale), 2) AS avg_transaction
FROM retail_sales
GROUP BY customer_id
ORDER BY avg_transaction DESC;
```

Q3.4 – Which customers made only one purchase?
```sql
SELECT customer_id
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(*) = 1;
```

Q3.5 – How can we segment customers by their total spending?
```sql
SELECT customer_id, SUM(total_sale) AS total_spent,
  CASE
    WHEN SUM(total_sale) < 200 THEN 'Low Spender'
    WHEN SUM(total_sale) BETWEEN 200 AND 500 THEN 'Mid Spender'
    ELSE 'High Spender'
  END AS spender_type
FROM retail_sales
GROUP BY customer_id;
```

Q3.6 – Which gender performs more transactions?
```sql
SELECT gender, COUNT(*) AS transaction_count
FROM retail_sales
GROUP BY gender;
```

Q3.7 – Which gender contributes more to total sales?
```sql
SELECT gender, SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY gender;
```

Q3.8 – What is the average transaction value by gender?
```sql
SELECT gender, ROUND(AVG(total_sale), 2) AS avg_sale
FROM retail_sales
GROUP BY gender;
```

Q3.9 – What are the most purchased categories by gender?
```sql
SELECT gender, category, SUM(quantiy) AS total_quantity
FROM retail_sales
GROUP BY gender, category
ORDER BY gender, total_quantity DESC;
```

---

## 📈 Key Insights & Recommendations

| Area        | Insight                                                                 | Recommendation                                                  |
|-------------|-------------------------------------------------------------------------|------------------------------------------------------------------|
| Time        | Peak sales in Q4, lowest in Q1                                          | **Prioritize promotions in Q4**, evaluate early-year strategies      |
| Product     | **Electronics lead** in revenue and consistency                             | Focus bundling & loyalty efforts on **Electronics**                 |
| Customer    | High-spending & loyal customers identified                              | Offer **exclusive vouchers** or **early-access promos**                 |
| Gender      | Women favor **Clothing**, Men favor **Electronics**                             | Design **gender-targeted marketing** campaigns                      |
| Time of Day | Most transactions happen **Monday evenings**                                   | Schedule **flash sales** or **promo campaigns** during this time frame  |

---

## 🧑‍💻 How to Use

1. Clone this repository.
2. Create a PostgreSQL database named `retail_sales`.
3. Execute `database_setup.sql` to build and populate the table.
4. Run the queries in `sql_query_retailsales.sql` to explore the dataset.

---

## 🧾 Conclusion

This project highlights how SQL can be applied to derive meaningful insights from retail data even without visualizations. By segmenting the analysis into time, product, and customer dimensions, we can uncover sales trends, customer behavior, and category performance that drive strategic decision-making. This structured approach allows analysts to focus on extracting actionable recommendations purely from data-driven evidence.

---


## 👤 Author

**Name**: Muhammad Rafi'Ar Rasyid  
**LinkedIn**: [Connect with Me Professionally](https://www.linkedin.com/in/muhammadrafiarrasyid/)

---

## 🔗 Credits

- Original dataset by Zero Analyst: [GitHub Repository](https://github.com/najirh/Retail-Sales-Analysis-SQL-Project--P1/blob/main/SQL%20-%20Retail%20Sales%20Analysis_utf%20.csv)
- Analysis and insights were developed independently with a business-focused approach.

---
