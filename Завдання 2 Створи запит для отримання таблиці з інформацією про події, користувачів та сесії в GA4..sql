
----Завдання 2. Підготовка даних для побудови звітів у BI системах.

SELECT TIMESTAMP_MICROS(event_timestamp ) AS event_timestamp,
    user_pseudo_id,
    (select value.int_value FROM UNNEST(event_params) WHERE KEY = 'ga_session_id' ) AS session_id,
   event_name,
  geo.country,
  device.category,
  traffic_source.source AS source,
  traffic_source.medium AS medium,
  traffic_source.name AS campaign
from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
where _TABLE_SUFFIX BETWEEN  '20210101' AND '20211231'
AND event_name IN (
  'session_start', 'view_item', 'add_to_cart', 'purchase', 'add_shipping_info',
'add_payment_info', 'begin_checkout'
);







