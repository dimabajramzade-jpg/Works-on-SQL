
----Завдання 3 Розрахунок конверсій в розрізі дат та каналів трафіку

WITH Combined_date AS (
  SELECT 
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS event_date,
    traffic_source.source AS source,
    traffic_source.medium AS medium,
    traffic_source.name AS campaign,
    CONCAT(
      user_pseudo_id,
      CAST((SELECT value.int_value 
            FROM UNNEST(event_params) 
            WHERE KEY = 'ga_session_id') AS STRING)
    ) AS user_session_id,
    event_name
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
),

Agregated_date AS (
  SELECT 
    event_date, 
    campaign, 
    source, 
    medium,
    COUNT(DISTINCT CASE WHEN event_name = 'session_start' THEN user_session_id END) AS session_start_count,
    COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN user_session_id END) AS add_to_cart_count,
    COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN user_session_id END) AS begin_checkout_count,
    COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN user_session_id END) AS purchase_count  
  FROM Combined_date
  GROUP BY event_date, campaign, source, medium
)

SELECT 
  event_date, 
  campaign, 
  source, 
  medium,
  session_start_count,
  SAFE_DIVIDE(add_to_cart_count, session_start_count) * 100 AS visit_to_cart, 
  SAFE_DIVIDE(purchase_count, session_start_count) * 100 AS visit_to_purchase,
  SAFE_DIVIDE(begin_checkout_count, session_start_count) * 100 AS visit_to_checkout
FROM Agregated_date
ORDER BY event_date;








