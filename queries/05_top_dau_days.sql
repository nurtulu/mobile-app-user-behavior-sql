-- Business question: Which days had the highest number of active users?
-- Metric: Top 5 days by DAU
-- Dataset: Flood It! (Firebase public sample), all daily tables (events_*)
-- Finding: All top 5 days (DAU 1,219-1,283) fall between 2018-06-18 and 2018-07-01,
--          about 2.5x the average DAU of 518. See 06_dau_trend for how to read this.

WITH daily AS (
  SELECT
    _TABLE_SUFFIX AS event_date,
    COUNT(DISTINCT user_pseudo_id) AS dau
  FROM `firebase-public-project.analytics_153293282.events_*`
  GROUP BY event_date
)
SELECT event_date, dau
FROM daily
ORDER BY dau DESC
LIMIT 5;