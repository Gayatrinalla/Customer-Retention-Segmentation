/*
PROJECT 2: CUSTOMER RETENTION & SEGMENTATION
Dataset: UCI Online Retail
Database: customer_retention

Purpose:
1. Import and audit the source data
2. Create a clean positive-sales dataset
3. Analyze sales and repeat purchasing
4. Measure cohort retention
5. Score and segment customers using RFM
6. Analyze monthly trends, products, and countries

IMPORTANT:
- Setup/import statements are for rebuilding the database from scratch. Run them once on a fresh setup.
- Update the LOAD DATA path to match your computer.
- The source InvoiceDate is text in day-month-year format; convert it with STR_TO_DATE.
- The customer_sales view excludes cancellations, missing customer IDs, nonpositive quantities, and nonpositive prices.
*/

/* ============================================================
   1. DATABASE AND SOURCE IMPORT
   ============================================================ */
CREATE DATABASE IF NOT EXISTS customer_retention;
USE customer_retention;

CREATE TABLE IF NOT EXISTS online_retail_import (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate VARCHAR(30),
    UnitPrice DECIMAL(10,2),
    CustomerID INT,
    Country VARCHAR(100)
);

-- Enable LOCAL INFILE in MySQL if required by your environment.
SHOW VARIABLES LIKE 'local_infile';
-- SET GLOBAL local_infile = 1;

-- Run once for the initial import. Change the path if needed.
-- Ensure the table is empty before importing again to avoid duplicate rows.
LOAD DATA LOCAL INFILE
'C:/Users/SIDDH/Downloads/Customer_Retention_Segmentation/raw data/online_retail.csv'
INTO TABLE online_retail_import
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, @CustomerID, Country)
SET CustomerID = NULLIF(@CustomerID, '');

-- Confirm the import row count.
SELECT COUNT(*) AS total_import_rows
FROM online_retail_import;


/* ============================================================
   2. SOURCE DATA QUALITY AUDIT
   ============================================================ */
-- Check duplicate full rows. GROUP BY is more reliable here than
-- COUNT(DISTINCT multiple_columns), which can ignore rows containing NULLs.
SELECT
    InvoiceNo, StockCode, Description, Quantity, InvoiceDate,
    UnitPrice, CustomerID, Country,
    COUNT(*) AS occurrences
FROM online_retail_import
GROUP BY
    InvoiceNo, StockCode, Description, Quantity, InvoiceDate,
    UnitPrice, CustomerID, Country
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 20;

-- Validate source dates before converting them to DATETIME.
SELECT
    MIN(STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i:%s')) AS earliest_date,
    MAX(STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i:%s')) AS latest_date,
    SUM(STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i:%s') IS NULL) AS unparsed_dates
FROM online_retail_import;

-- Inspect key quality and business-rule indicators.
SELECT
    COUNT(*) AS total_rows,
    SUM(InvoiceNo IS NULL OR InvoiceNo = '') AS missing_invoices,
    SUM(CustomerID IS NULL) AS missing_customer_ids,
    SUM(InvoiceNo LIKE 'C%') AS cancellation_rows,
    SUM(Quantity <= 0) AS nonpositive_quantity_rows,
    SUM(UnitPrice <= 0) AS nonpositive_price_rows
FROM online_retail_import;


/* ============================================================
   3. CONVERT DATES AND CREATE ANALYSIS TABLE
   ============================================================ */
-- Run this table creation and INSERT only once when rebuilding from scratch.
CREATE TABLE IF NOT EXISTS online_retail_analysis (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(12,2),
    CustomerID INT,
    Country VARCHAR(100)
);

-- Run once after importing into online_retail_import.
INSERT INTO online_retail_analysis (
    InvoiceNo, StockCode, Description, Quantity,
    InvoiceDate, UnitPrice, CustomerID, Country
)
SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i:%s'),
    UnitPrice,
    CustomerID,
    Country
FROM online_retail_import;

SELECT
    COUNT(*) AS total_rows,
    MIN(InvoiceDate) AS earliest_date,
    MAX(InvoiceDate) AS latest_date
FROM online_retail_analysis;


/* ============================================================
   4. CLEAN SALES VIEW AND OVERALL KPIs
   ============================================================ */
CREATE OR REPLACE VIEW customer_sales AS
SELECT *
FROM online_retail_analysis
WHERE CustomerID IS NOT NULL
  AND InvoiceNo NOT LIKE 'C%'
  AND Quantity > 0
  AND UnitPrice > 0;

-- Core project KPIs.
SELECT
    COUNT(*) AS sales_line_rows,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    COUNT(DISTINCT CustomerID) AS unique_customers,
    ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue,
    ROUND(
        SUM(Quantity * UnitPrice) / COUNT(DISTINCT InvoiceNo), 2
    ) AS average_order_value,
    ROUND(
        SUM(Quantity * UnitPrice) / COUNT(DISTINCT CustomerID), 2
    ) AS revenue_per_customer
FROM customer_sales;

-- One-time versus repeat purchasers across the full dataset.
SELECT
    CASE WHEN order_count = 1 THEN 'One-time customers'
         ELSE 'Repeat customers' END AS customer_type,
    COUNT(*) AS total_customers,
    ROUND(SUM(customer_revenue), 2) AS total_revenue,
    ROUND(AVG(customer_revenue), 2) AS average_revenue_per_customer
FROM (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS order_count,
        SUM(Quantity * UnitPrice) AS customer_revenue
    FROM customer_sales
    GROUP BY CustomerID
) AS customer_summary
GROUP BY customer_type
ORDER BY total_revenue DESC;

SELECT
    COUNT(*) AS total_customers,
    SUM(order_count = 1) AS one_time_customers,
    SUM(order_count >= 2) AS repeat_customers,
    ROUND(100.0 * SUM(order_count >= 2) / COUNT(*), 2) AS repeat_purchase_rate_pct
FROM (
    SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS order_count
    FROM customer_sales
    GROUP BY CustomerID
) AS customer_orders;


/* ============================================================
   5. COHORT RETENTION ANALYSIS
   ============================================================ */
CREATE OR REPLACE VIEW customer_cohorts AS
SELECT
    CustomerID,
    MIN(DATE_FORMAT(InvoiceDate, '%Y-%m-01')) AS cohort_month
FROM customer_sales
GROUP BY CustomerID;

CREATE OR REPLACE VIEW customer_cohort_activity AS
SELECT DISTINCT
    cs.CustomerID,
    cc.cohort_month,
    DATE_FORMAT(cs.InvoiceDate, '%Y-%m-01') AS activity_month,
    TIMESTAMPDIFF(
        MONTH, cc.cohort_month, DATE_FORMAT(cs.InvoiceDate, '%Y-%m-01')
    ) AS cohort_index
FROM customer_sales cs
JOIN customer_cohorts cc ON cs.CustomerID = cc.CustomerID;

CREATE OR REPLACE VIEW cohort_retention_counts AS
SELECT
    cohort_month,
    cohort_index,
    COUNT(DISTINCT CustomerID) AS active_customers
FROM customer_cohort_activity
GROUP BY cohort_month, cohort_index;

CREATE OR REPLACE VIEW cohort_retention_rates AS
SELECT
    c.cohort_month,
    c.cohort_index,
    c.active_customers,
    s.cohort_size,
    ROUND(100.0 * c.active_customers / s.cohort_size, 2) AS retention_rate_pct
FROM cohort_retention_counts c
JOIN (
    SELECT cohort_month, active_customers AS cohort_size
    FROM cohort_retention_counts
    WHERE cohort_index = 0
) s ON c.cohort_month = s.cohort_month;

-- Detailed cohort table for analysis/export.
SELECT *
FROM cohort_retention_rates
ORDER BY cohort_month, cohort_index;

-- Cohort retention matrix for months 0–12.
SELECT
    cohort_month,
    MAX(CASE WHEN cohort_index = 0 THEN retention_rate_pct END) AS Month_0,
    MAX(CASE WHEN cohort_index = 1 THEN retention_rate_pct END) AS Month_1,
    MAX(CASE WHEN cohort_index = 2 THEN retention_rate_pct END) AS Month_2,
    MAX(CASE WHEN cohort_index = 3 THEN retention_rate_pct END) AS Month_3,
    MAX(CASE WHEN cohort_index = 4 THEN retention_rate_pct END) AS Month_4,
    MAX(CASE WHEN cohort_index = 5 THEN retention_rate_pct END) AS Month_5,
    MAX(CASE WHEN cohort_index = 6 THEN retention_rate_pct END) AS Month_6,
    MAX(CASE WHEN cohort_index = 7 THEN retention_rate_pct END) AS Month_7,
    MAX(CASE WHEN cohort_index = 8 THEN retention_rate_pct END) AS Month_8,
    MAX(CASE WHEN cohort_index = 9 THEN retention_rate_pct END) AS Month_9,
    MAX(CASE WHEN cohort_index = 10 THEN retention_rate_pct END) AS Month_10,
    MAX(CASE WHEN cohort_index = 11 THEN retention_rate_pct END) AS Month_11,
    MAX(CASE WHEN cohort_index = 12 THEN retention_rate_pct END) AS Month_12
FROM cohort_retention_rates
GROUP BY cohort_month
ORDER BY cohort_month;


/* ============================================================
   6. RFM ANALYSIS AND CUSTOMER SEGMENTATION
   ============================================================ */
CREATE OR REPLACE VIEW customer_rfm AS
SELECT
    CustomerID,
    DATEDIFF(
        (SELECT DATE_ADD(MAX(InvoiceDate), INTERVAL 1 DAY) FROM customer_sales),
        MAX(InvoiceDate)
    ) AS recency_days,
    COUNT(DISTINCT InvoiceNo) AS frequency,
    ROUND(SUM(Quantity * UnitPrice), 2) AS monetary_value
FROM customer_sales
GROUP BY CustomerID;

CREATE OR REPLACE VIEW customer_rfm_scores AS
SELECT
    CustomerID,
    recency_days,
    frequency,
    monetary_value,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS R_score,
    NTILE(5) OVER (ORDER BY frequency ASC) AS F_score,
    NTILE(5) OVER (ORDER BY monetary_value ASC) AS M_score
FROM customer_rfm;

CREATE OR REPLACE VIEW customer_segments AS
SELECT
    CustomerID,
    recency_days,
    frequency,
    monetary_value,
    R_score,
    F_score,
    M_score,
    CASE
        WHEN R_score >= 4 AND F_score >= 4 AND M_score >= 4 THEN 'Champions'
        WHEN R_score >= 3 AND F_score >= 4 THEN 'Loyal Customers'
        WHEN R_score >= 4 AND F_score BETWEEN 2 AND 3 THEN 'Potential Loyalists'
        WHEN R_score = 5 AND F_score = 1 THEN 'Recent One-Time Buyers'
        WHEN R_score <= 2 AND F_score >= 3 THEN 'At Risk'
        WHEN R_score <= 2 AND F_score <= 2 THEN 'Hibernating'
        ELSE 'Needs Attention'
    END AS customer_segment
FROM customer_rfm_scores;

-- Customer counts and percentage by segment.
SELECT
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer_segments), 2) AS customer_percentage
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_customers DESC;

-- Inspect the RFM profile within each segment.
SELECT
    customer_segment, R_score, F_score, M_score,
    COUNT(*) AS customers
FROM customer_segments
GROUP BY customer_segment, R_score, F_score, M_score
ORDER BY customer_segment, R_score DESC, F_score DESC, M_score DESC;


/* ============================================================
   7. MONTHLY SALES AND CUSTOMER BEHAVIOR
   ============================================================ */
SELECT
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS sales_month,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    COUNT(DISTINCT CustomerID) AS unique_customers,
    ROUND(SUM(Quantity * UnitPrice), 2) AS monthly_revenue
FROM customer_sales
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
ORDER BY sales_month;

-- First-time and returning customers by activity month.
WITH customer_first_purchase AS (
    SELECT
        CustomerID,
        MIN(DATE_FORMAT(InvoiceDate, '%Y-%m')) AS first_purchase_month
    FROM customer_sales
    GROUP BY CustomerID
),
monthly_customers AS (
    SELECT DISTINCT
        DATE_FORMAT(cs.InvoiceDate, '%Y-%m') AS sales_month,
        cs.CustomerID,
        cfp.first_purchase_month
    FROM customer_sales cs
    JOIN customer_first_purchase cfp ON cs.CustomerID = cfp.CustomerID
)
SELECT
    sales_month,
    COUNT(DISTINCT CASE WHEN sales_month = first_purchase_month THEN CustomerID END) AS new_customers,
    COUNT(DISTINCT CASE WHEN sales_month > first_purchase_month THEN CustomerID END) AS returning_customers
FROM monthly_customers
GROUP BY sales_month
ORDER BY sales_month;


/* ============================================================
   8. PRODUCT AND COUNTRY PERFORMANCE
   ============================================================ */
-- Top products by revenue, excluding postage and manual adjustment codes.
SELECT
    StockCode,
    MAX(Description) AS product_name,
    SUM(Quantity) AS units_sold,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue
FROM customer_sales
WHERE StockCode NOT IN ('POST', 'M')
GROUP BY StockCode
ORDER BY total_revenue DESC
LIMIT 10;

SELECT
    Country,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    COUNT(DISTINCT CustomerID) AS unique_customers,
    ROUND(SUM(Quantity * UnitPrice), 2) AS total_revenue
FROM customer_sales
GROUP BY Country
ORDER BY total_revenue DESC
LIMIT 10;

/* End of final portfolio script. */
