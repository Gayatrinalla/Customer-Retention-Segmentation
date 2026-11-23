# Customer-Retention-Segmentation

## Project Overview

Customer Retention & Segmentation Analytics is a data analytics project focused on understanding customer purchasing behaviour, identifying repeat customers, and segmenting customers based on their Recency, Frequency, and Monetary (RFM) values.
The project uses SQL for data cleaning and analysis and Power BI to create interactive dashboards that highlight customer retention patterns, purchasing behaviour, and revenue contribution across customer segments.

##  Project Objectives

- Analyze customer purchasing behaviour and transaction patterns.
- Identify one-time and repeat customers.
- Calculate customer Recency, Frequency, and Monetary (RFM) metrics.
- Segment customers based on purchasing behaviour and value.
- Analyze revenue contribution across customer segments.
- Identify customer retention opportunities and provide actionable business recommendations.

##  Tools & Technologies

- **MySQL:** Data cleaning, querying, customer analysis, and RFM segmentation.
- **Power BI:** Interactive dashboard development and data visualization.
- **Microsoft Excel:** Initial data exploration and validation.
- **DAX:** Calculated measures and customer metrics.
- **Power Query:** Data transformation and preparation.

##  Dataset

**Dataset Name:** Online Retail Dataset

**Source:** UCI Machine Learning Repository

**Analysis Period:** December 2010 – December 2011

**Original Dataset Size:** 541,909 transaction records

The dataset contains transactional data from a UK-based online retail business.

### Key Columns

| Column | Description |
|---|---|
| InvoiceNo | Unique invoice number |
| StockCode | Product code |
| Description | Product description |
| Quantity | Number of items purchased |
| InvoiceDate | Date and time of purchase |
| UnitPrice | Price per item |
| CustomerID | Customer identifier |
| Country | Customer's country |

##  Data Cleaning & Preparation

The raw dataset was examined and cleaned using SQL and Power Query.

The following cleaning steps were performed:

- Removed transactions with missing CustomerID values.
- Excluded cancelled invoices identified by InvoiceNo starting with `C`.
- Removed records with zero or negative quantities.
- Removed records with zero or negative unit prices.
- Checked transaction records and customer identifiers.
- Prepared the cleaned dataset for customer-level analysis.

**SQL cleaning conditions:**

```sql
WHERE CustomerID IS NOT NULL
  AND InvoiceNo NOT LIKE 'C%'
  AND Quantity > 0
  AND UnitPrice > 0;
```

##  SQL Analysis

SQL was used to perform customer-level analysis and identify purchasing patterns.

The major analyses included:

- Total revenue and transaction analysis.
- Total unique customers and invoices.
- One-time versus repeat customer identification.
- Repeat purchase rate calculation.
- Customer-level RFM analysis.
- Customer segmentation using RFM scores.
- Revenue contribution by customer segment.
- Average recency analysis across customer segments.

### RFM Analysis

RFM stands for:

| Metric | Description |
|---|---|
| Recency (R) | Number of days since the customer's last purchase |
| Frequency (F) | Number of distinct invoices placed by the customer |
| Monetary (M) | Total amount spent by the customer |

Customers were assigned RFM scores using SQL window functions (`NTILE(5)`) and categorized into seven segments:

- Champions
- Loyal Customers
- Potential Loyalists
- Recent One-Time Buyers
- At Risk
- Hibernating
- Needs Attention

##  Key Findings

The analysis of the cleaned dataset revealed the following insights:

- **Total Revenue:** £8.91 million generated from customer transactions.
- **Total Customers:** 4,338 customers included in the RFM analysis.
- **Repeat Customers:** 2,845 customers made multiple purchases.
- **One-Time Customers:** 1,493 customers made only one purchase.
- **Repeat Purchase Rate:** 65.58% of customers made repeat purchases.

### Customer Segmentation Insights

| Customer Segment | Customer Count |
|---|---:|
| Hibernating | 1,210 |
| Champions | 986 |
| Needs Attention | 541 |
| Loyal Customers | 537 |
| At Risk | 526 |
| Potential Loyalists | 523 |
| Recent One-Time Buyers | 15 |

- Hibernating customers represent the largest customer segment.
- Champions contribute significantly to overall revenue.
- At-risk and needs-attention customers represent opportunities for targeted retention campaigns.

##  Business Recommendations

Based on the customer segmentation and purchasing behaviour analysis, the following strategies are recommended:

| Customer Segment | Business Recommendation |
|---|---|
| Champions | Reward loyal customers through exclusive offers, early access, and loyalty benefits. |
| Loyal Customers | Encourage continued engagement through personalized recommendations and loyalty rewards. |
| Potential Loyalists | Use targeted promotions and product recommendations to encourage more frequent purchases. |
| At Risk | Launch personalized re-engagement campaigns and limited-time offers. |
| Hibernating | Use win-back campaigns with special discounts to encourage customers to return. |
| Needs Attention | Analyze purchasing behaviour and offer relevant promotions to improve engagement. |
| Recent One-Time Buyers | Send follow-up emails and first-repeat-purchase incentives to encourage a second order. |

These recommendations aim to improve customer retention, increase repeat purchases, and strengthen long-term customer relationships.

##  Power BI Dashboard

The project includes two interactive dashboard pages:

### Page 1 – Customer Retention Overview

![Customer Retention Overview]("C:\Users\SIDDH\Downloads\Customer_Retention_Segmentation\Dashboard_screenshots\customer_retention_overview.png.png")

### Page 2 – RFM Customer Segmentation

![RFM Customer Segmentation]("C:\Users\SIDDH\Downloads\Customer_Retention_Segmentation\Dashboard_screenshots\rfm_customer_segmentation.png.png")

## Conclusion

This project demonstrates how SQL and Power BI can be used together to analyze customer purchasing behaviour and identify retention opportunities.

Through customer-level RFM analysis, the project identified different customer segments, evaluated repeat purchasing patterns, and analyzed revenue contribution across segments.

The interactive dashboards provide insights that can support data-driven decisions, targeted marketing strategies, and customer retention initiatives.

**Key Skills Demonstrated:** SQL, MySQL, Power BI, DAX, Power Query, Data Cleaning, Exploratory Data Analysis, and RFM Customer Segmentation.
