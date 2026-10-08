WITH daily_activity AS (
  SELECT DISTINCT
    user_pseudo_id,
    PARSE_DATE('%Y%m%d', event_date) AS activity_date
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE user_pseudo_id IS NOT NULL
),

user_cohorts AS (
  SELECT
    user_pseudo_id,
    DATE_TRUNC(MIN(activity_date), WEEK(MONDAY)) AS cohort_week
  FROM daily_activity
  GROUP BY user_pseudo_id
),

cohort_activity AS (
  SELECT
    c.cohort_week,
    DATE_DIFF(
      DATE_TRUNC(a.activity_date, WEEK(MONDAY)),
      c.cohort_week,
      WEEK
    ) AS weeks_since_first_activity,
    COUNT(DISTINCT a.user_pseudo_id) AS retained_users
  FROM daily_activity AS a
  JOIN user_cohorts AS c
    USING (user_pseudo_id)
  GROUP BY 1, 2
),

cohort_sizes AS (
  SELECT
    cohort_week,
    COUNT(*) AS cohort_size
  FROM user_cohorts
  GROUP BY cohort_week
)

SELECT
  c.cohort_week,
  c.weeks_since_first_activity,
  s.cohort_size,
  c.retained_users,
  ROUND(
    100 * SAFE_DIVIDE(c.retained_users, s.cohort_size),
    2
  ) AS retention_pct
FROM cohort_activity AS c
JOIN cohort_sizes AS s
  USING (cohort_week)
WHERE c.weeks_since_first_activity BETWEEN 0 AND 8
ORDER BY c.cohort_week, c.weeks_since_first_activity;
