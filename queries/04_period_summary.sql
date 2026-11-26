-- Business question: What period does the data cover, and what does typical daily usage look like?
-- Metric: Days covered, min/max daily events, average/min/max DAU
-- Dataset: Flood It! (Firebase public sample), all daily tables (events_*)
-- Findings:
--   * 114 days of data: 2018-06-12 to 2018-10-03.
--   * Daily events are exactly 50,000 on every day (min = max), confirming the public
--     sample is capped at 50,000 rows per day. Event counts are therefore NOT a
--     reliable metric in this dataset; user-based metrics (DAU, ratios) are used instead.
--   * Average DAU: 518 (min 346, max 1,283).

WITH daily AS (
  SELECT
    _TABLE_SUFFIX AS event_date,
    COUNT(*) AS total_events,
    COUNT(DISTINCT user_pseudo_id) AS dau
  FROM `firebase-public-project.analytics_153293282.events_*`
  GROUP BY event_date
)
SELECT
  COUNT(*) AS number_of_days,
  MIN(event_date) AS first_day,
  MAX(event_date) AS last_day,
  MIN(total_events) AS min_events,
  MAX(total_events) AS max_events,
  ROUND(AVG(dau)) AS avg_dau,
  MIN(dau) AS min_dau,
  MAX(dau) AS max_dau
FROM daily;