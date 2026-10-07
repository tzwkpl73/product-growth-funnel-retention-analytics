WITH weekly_metrics AS (
  SELECT
    DATE_TRUNC(
      PARSE_DATE('%Y%m%d', event_date),
      WEEK(MONDAY)
    ) AS week_start,

    COUNT(DISTINCT user_pseudo_id) AS active_users,

    COUNT(DISTINCT IF(
      event_name = 'first_visit',
      user_pseudo_id,
      NULL
    )) AS new_users,

    COUNT(DISTINCT IF(
      event_name = 'purchase',
      user_pseudo_id,
      NULL
    )) AS purchasers,

    COUNTIF(event_name = 'purchase') AS purchase_events,

    ROUND(
      SUM(
        IF(
          event_name = 'purchase',
          COALESCE(ecommerce.purchase_revenue, 0),
          0
        )
      ),
      2
    ) AS revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  GROUP BY 1
)

SELECT
  week_start,
  active_users,
  new_users,
  purchasers,
  purchase_events,
  revenue,
  ROUND(
    100 * SAFE_DIVIDE(purchasers, active_users),
    2
  ) AS purchaser_rate_pct,
  ROUND(
    SAFE_DIVIDE(revenue, purchase_events),
    2
  ) AS revenue_per_purchase
FROM weekly_metrics
ORDER BY week_start;
