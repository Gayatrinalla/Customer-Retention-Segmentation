# Customer Retention & Segmentation Analytics

## 1. Project Overview

This document explains the methodology used to analyze customer purchasing behaviour, identify repeat customers, and perform RFM-based customer segmentation using MySQL and Power BI.

The project follows a data analytics workflow involving:

- Data exploration and validation
- Data cleaning and preparation
- SQL-based customer analysis
- RFM scoring and customer segmentation
- Power BI dashboard development
- Business insights and recommendations

**Dataset:** UCI Online Retail Dataset

**Analysis Period:** December 2010 – December 2011

**Tools:** MySQL, Power BI, DAX, Power Query

## 2. Data Cleaning & Preparation

The original dataset contained 541,909 transaction records. Data quality checks and cleaning operations were performed using MySQL and Power Query.

### Data Quality Checks

The following issues were identified:

- Missing CustomerID values.
- Cancelled transactions identified by invoice numbers beginning with `C`.
- Zero or negative quantities.
- Zero or negative unit prices.
- Duplicate transaction combinations were examined.

### Cleaning Rules

The following conditions were applied to prepare the dataset for analysis:

| Condition | Action |
|---|---|
| CustomerID IS NULL | Excluded |
| InvoiceNo LIKE 'C%' | Excluded |
| Quantity <= 0 | Excluded |
| UnitPrice <= 0 | Excluded |

### SQL Cleaning Query

```sql
SELECT *
FROM online_retail_import
WHERE CustomerID IS NOT NULL
  AND InvoiceNo NOT LIKE 'C%'
  AND Quantity > 0
  AND UnitPrice > 0;
```

## 3. Customer Analysis Using SQL

SQL was used to analyze customer purchasing patterns and identify retention-related metrics.

### Key Analysis Performed

1. **Revenue Analysis:** Calculated total revenue using Quantity × UnitPrice.
2. **Customer Analysis:** Identified unique customers based on CustomerID.
3. **Invoice Analysis:** Counted distinct invoices to understand purchasing activity.
4. **Repeat Customer Analysis:** Identified customers who made purchases across multiple invoices.
5. **One-Time Customer Analysis:** Identified customers with only one purchase.
6. **Repeat Purchase Rate:** Calculated the percentage of customers who made repeat purchases.

### Repeat Purchase Rate Calculation

Repeat Purchase Rate was calculated using:

Repeat Purchase Rate = (Repeat Customers / Total Customers) × 100

### RFM Metrics Calculation

Customer-level RFM metrics were calculated using SQL:

- **Recency:** Days since the customer's most recent purchase, calculated relative to the day after the latest transaction date.
- **Frequency:** Number of distinct invoices placed by each customer.
- **Monetary:** Total spending calculated as Quantity × UnitPrice.

## 4. RFM Scoring & Customer Segmentation

RFM analysis was performed to group customers based on their purchasing behaviour and value.

### RFM Scoring Method

Customers were assigned scores from 1 to 5 using the SQL `NTILE(5)` window function.

| Metric | Scoring Logic |
|---|---|
| Recency (R) | Higher score for more recent purchases |
| Frequency (F) | Higher score for more frequent purchases |
| Monetary (M) | Higher score for higher spending |

### Customer Segmentation Logic

Customers were categorized into seven segments based on their RFM scores.

| Customer Segment | Segmentation Criteria |
|---|---|
| Champions | R >= 4, F >= 4, M >= 4 |
| Loyal Customers | R >= 3, F >= 4 |
| Potential Loyalists | R >= 4, F between 2 and 3 |
| Recent One-Time Buyers | R = 5, F = 1 |
| At Risk | R <= 2, F >= 3 |
| Hibernating | R <= 2, F <= 2 |
| Needs Attention | All remaining combinations |
The segmentation was implemented using SQL `CASE` statements.

## 5. Power BI Dashboard Development

Power BI was used to transform the analyzed data into interactive visual dashboards.

### Data Preparation

- Imported the cleaned transaction data into Power BI using Power Query.
- Applied data types to the columns.
- Created a Month Start calculated column for monthly trend analysis.
- Imported the customer-level RFM segmentation data exported from MySQL.
- Established a relationship between the transaction table and the customer RFM table using CustomerID.

### Page 1 – Customer Retention Overview

This dashboard focuses on overall business performance and customer purchasing behaviour.

**Key KPIs:**
- Total Revenue
- Total Customers
- Repeat Purchase Rate
- One-Time Customers
- Repeat Customers

**Visualizations:**
- Monthly Revenue Trend
- Repeat vs One-Time Customer Distribution
- Customer Distribution by RFM Segment

### Page 2 – RFM Customer Segmentation

This dashboard focuses on customer value and purchasing behaviour.

**Key KPIs:**
- Total RFM Customers
- Champions
- Hibernating
- Loyal Customers
- At Risk
- Needs Attention
- Potential Loyalists

**Visualizations:**
- Customer Distribution by RFM Segment
- Revenue Contribution by RFM Segment
- Average Recency (Days) by RFM Segment

## 6. Key Findings & Business Insights

The analysis revealed several insights about customer purchasing behaviour and retention.

### Overall Customer Insights

| Metric | Result |
|---|---:|
| Total Revenue | £8,911,407.90 |
| Total Customers | 4,338 |
| Repeat Customers | 2,845 |
| One-Time Customers | 1,493 |
| Repeat Purchase Rate | 65.58% |

### RFM Segmentation Results

| Customer Segment | Customers |
|---|---:|
| Hibernating | 1,210 |
| Champions | 986 |
| Needs Attention | 541 |
| Loyal Customers | 537 |
| At Risk | 526 |
| Potential Loyalists | 523 |
| Recent One-Time Buyers | 15 |

### Important Observations

- Hibernating customers form the largest segment, with 1,210 customers.
- Champions account for 986 customers and contribute approximately £5.81 million in revenue.
- Repeat customers represent 65.58% of the analyzed customer base.
- At Risk and Needs Attention customers present opportunities for targeted retention strategies.
- RFM segmentation helps identify customers requiring different engagement approaches.

## 7. Business Recommendations

Based on the RFM segmentation results, the following strategies can help improve customer retention:

| Customer Segment | Recommended Strategy |
|---|---|
| Champions | Provide exclusive rewards, loyalty benefits, and early access to new products. |
| Loyal Customers | Encourage continued purchases through personalized offers. |
| Potential Loyalists | Use targeted promotions to increase purchase frequency. |
| At Risk | Launch re-engagement campaigns with personalized discounts. |
| Hibernating | Introduce win-back campaigns to encourage customers to return. |
| Needs Attention | Monitor purchasing activity and provide relevant offers. |
| Recent One-Time Buyers | Send follow-up offers to encourage a second purchase. |

### Expected Business Benefits

- Improve customer retention.
- Increase repeat purchase frequency.
- Strengthen customer loyalty.
- Identify customers who may stop purchasing.
- Support targeted marketing decisions.

 ## 8. Conclusion

This project demonstrates the use of SQL and Power BI to analyze customer purchasing behaviour and perform RFM-based customer segmentation.

Through data cleaning, SQL analysis, and interactive dashboard development, the project identified repeat purchasing patterns, evaluated customer value, and highlighted customer retention opportunities.

The analysis provides actionable insights that can help businesses make data-driven decisions, improve customer engagement, and develop targeted retention strategies.

### Skills Demonstrated

- SQL and MySQL
- Data Cleaning and Preparation
- Exploratory Data Analysis
- RFM Analysis
- Customer Segmentation
- Power BI Dashboard Development
- DAX and Power Query
- Business Intelligence and Data Visualization
