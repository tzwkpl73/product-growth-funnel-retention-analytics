WITH channel_performance AS (
  SELECT
    COALESCE(NULLIF(traffic_source.source, ''), '(direct)')
      AS first_touch_source,
    COALESCE(NULLIF(traffic_source.medium, ''), '(none)')
      AS first_touch_medium,
    COUNT(DISTINCT user_pseudo_id) AS users,
    COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL))
      AS purchasers,
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
  GROUP BY 1, 2
)

SELECT
  first_touch_source,
  first_touch_medium,
  users,
  purchasers,
  revenue,
  ROUND(100 * SAFE_DIVIDE(purchasers, users), 2)
    AS purchaser_rate_pct,
  ROUND(SAFE_DIVIDE(revenue, purchasers), 2)
    AS revenue_per_purchaser
FROM channel_performance
WHERE users >= 100
ORDER BY revenue DESC, users DESC;
