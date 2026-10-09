# E-commerce Product Growth, Funnel & Retention Analytics
<img width="3840" height="1971" alt="image" src="https://github.com/user-attachments/assets/df8bc321-c3d1-470f-956d-7d40776f01d9" />

[View the interactive Tableau dashboard](https://public.tableau.com/views/product-growth-funnel-retention-analytics/ProductGrowthDashboard?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

## Overview

Independent portfolio analysis of **4,295,584 anonymized GA4 e-commerce events** from the Google Analytics public sample. I used BigQuery SQL to analyze user growth, revenue, session-funnel conversion, weekly retention cohorts, and first-touch acquisition channels, then presented the results in Tableau Public.

> Results describe observed behavior in a public, obfuscated sample. They do not measure company quality, marketing incrementality, or customer satisfaction.

## Business Questions

- How did weekly active users, new users, revenue, and purchaser rate change over time?
- Where do users drop out of the product-view-to-purchase funnel?
- Do user cohorts return after their first week of activity?
- Which first-touch acquisition channels generated users, purchasers, and revenue?

## Data

- **Source:** `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
- **Coverage:** November 1, 2020–January 31, 2021
- **Scale:** 4,295,584 event records
- **Workflow:** BigQuery for analysis → aggregated outputs → Tableau Public dashboard

## Analysis Approach

1. Calculated weekly active users, new users, purchasers, purchase events, revenue, purchaser rate, and revenue per purchase.
2. Built a sequential session-level funnel: product view → add to cart → begin checkout → purchase.
3. Created weekly retention cohorts based on each user's first observed activity week.
4. Evaluated first-touch source and medium by users, purchasers, revenue, purchaser rate, and revenue per purchaser.

## Key Findings

- The funnel contained **77,020 product-view sessions**, but only **12,883** progressed to add to cart—just **16.73%** of product views.
- **2,313 sessions purchased**, resulting in a **3.00% product-view-to-purchase conversion rate**. The largest observed drop-off occurred between product view and add to cart.
- Retention declined sharply after the initial activity week across cohorts, indicating a need to investigate the early product-value or onboarding experience.
- Among the named acquisition-channel buckets shown, **Google organic** and **Direct** generated the most revenue. This is first-touch attribution, not proof that a channel caused a purchase.

## Dashboard

The Tableau dashboard contains five views:

- Weekly User Growth: Active vs. New Users
- Weekly Revenue and Purchaser Rate
- Product Funnel: Session Conversion
- Weekly Retention Cohorts
- Revenue by Acquisition Channel: First Touch

## SQL Files

| Analysis | SQL file |
|---|---|
| Weekly growth and revenue KPIs | [01_weekly_growth_metrics.sql](sql/01_weekly_growth_metrics.sql) |
| Sequential session funnel | [02_session_funnel.sql](sql/02_session_funnel.sql) |
| Weekly retention cohorts | [03_retention_cohorts.sql](sql/03_retention_cohorts.sql) |
| First-touch channel performance | [04_channel_performance.sql](sql/04_channel_performance.sql) |

## Tools

- Google BigQuery
- SQL
- Tableau Public
- GA4 public sample e-commerce dataset
- GitHub

## Notes and Limitations

- The source data is anonymized and obfuscated.
- `traffic_source` represents a user's first-touch source and medium, not session-level marketing attribution.
- Privacy/obfuscation buckets, including `<Other>` and `data deleted`, were excluded from the channel chart.
- Blank cells in later retention-cohort weeks represent unobserved future time after the dataset ended, not zero retention.
