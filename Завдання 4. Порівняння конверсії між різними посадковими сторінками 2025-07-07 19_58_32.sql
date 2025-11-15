
---Завдання 4. Порівняння конверсії між різними посадковими сторінками

WITH session_start AS (
  SELECT
    CONCAT(
      user_pseudo_id, '-', 
      CAST((SELECT value.int_value 
            FROM UNNEST(event_params) 
            WHERE key = 'ga_session_id') AS STRING)
    ) AS user_session_id,
    
    REPLACE(
      (SELECT value.string_value 
       FROM UNNEST(event_params) 
       WHERE key = 'page_location'),
      'https://shop.googlemerchandisestore.com/', ''
    ) AS page_path
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20200101' AND '20201231'
    AND event_name = 'session_start'
),

purchases AS (
  SELECT
    CONCAT(
      user_pseudo_id, '-', 
      CAST((SELECT value.int_value 
            FROM UNNEST(event_params) 
            WHERE key = 'ga_session_id') AS STRING)
    ) AS user_session_id
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20200101' AND '20201231'
    AND event_name = 'purchase'
)

SELECT
  s.page_path,
  COUNT(DISTINCT s.user_session_id) AS unique_sessions,
  COUNT(DISTINCT p.user_session_id) AS purchases,
  SAFE_DIVIDE(COUNT(DISTINCT p.user_session_id), COUNT(DISTINCT s.user_session_id)) AS conversion_rate
FROM session_start s
LEFT JOIN purchases p
  ON s.user_session_id = p.user_session_id
GROUP BY s.page_path
ORDER BY unique_sessions DESC;







