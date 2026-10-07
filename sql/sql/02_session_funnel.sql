WITH funnel_events AS (
  SELECT
    user_pseudo_id,
    CONCAT(
      user_pseudo_id,
      '-',
      CAST((
        SELECT value.int_value
        FROM UNNEST(event_params)
        WHERE key = 'ga_session_id'
      ) AS STRING)
    ) AS session_id,
    event_name,
    event_timestamp
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name IN (
    'view_item',
    'add_to_cart',
    'begin_checkout',
    'purchase'
  )
),

session_steps AS (
  SELECT
    session_id,
    MIN(IF(event_name = 'view_item', event_timestamp, NULL)) AS viewed_at,
    MIN(IF(event_name = 'add_to_cart', event_timestamp, NULL)) AS cart_at,
    MIN(IF(event_name = 'begin_checkout', event_timestamp, NULL)) AS checkout_at,
    MIN(IF(event_name = 'purchase', event_timestamp, NULL)) AS purchased_at
  FROM funnel_events
  WHERE session_id IS NOT NULL
  GROUP BY session_id
),

funnel_counts AS (
  SELECT
    1 AS step_order,
    '1. Product view' AS stage,
    COUNTIF(viewed_at IS NOT NULL) AS sessions
  FROM session_steps

  UNION ALL

  SELECT
    2,
    '2. Add to cart',
    COUNTIF(viewed_at IS NOT NULL AND cart_at > viewed_at)
  FROM session_steps

  UNION ALL

  SELECT
    3,
    '3. Begin checkout',
    COUNTIF(
      viewed_at IS NOT NULL
      AND cart_at > viewed_at
      AND checkout_at > cart_at
    )
  FROM session_steps

  UNION ALL

  SELECT
    4,
    '4. Purchase',
    COUNTIF(
      viewed_at IS NOT NULL
      AND cart_at > viewed_at
      AND checkout_at > cart_at
      AND purchased_at > checkout_at
    )
  FROM session_steps
)

SELECT
  stage,
  sessions,
  ROUND(
    100 * SAFE_DIVIDE(
      sessions,
      FIRST_VALUE(sessions) OVER (ORDER BY step_order)
    ),
    2
  ) AS conversion_from_product_view_pct,
  ROUND(
    100 * SAFE_DIVIDE(
      sessions,
      LAG(sessions) OVER (ORDER BY step_order)
    ),
    2
  ) AS conversion_from_previous_stage_pct
FROM funnel_counts
ORDER BY step_order;
