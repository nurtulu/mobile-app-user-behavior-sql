-- Business question: Were the DAU spikes driven by new users (e.g., an acquisition campaign)?
-- Metric: DAU and new users (first_open) per day (line chart in results/07_dau_vs_new_users.png)
-- Dataset: Flood It! (Firebase public sample), all daily tables (events_*)
-- Technique: Conditional aggregation - COUNT(DISTINCT IF(...)) counts only users
--            who triggered first_open, in the same query as total DAU.
-- Finding: New users stay flat and low on spike days. The hypothesis that spikes
--          came from new installs is REJECTED.

SELECT
  PARSE_DATE('%Y%m%d', _TABLE_SUFFIX) AS event_date,
  COUNT(DISTINCT user_pseudo_id) AS dau,
  COUNT(DISTINCT IF(event_name = 'first_open', user_pseudo_id, NULL)) AS new_users
FROM `firebase-public-project.analytics_153293282.events_*`
GROUP BY event_date
ORDER BY event_date;