-- Business question: How does DAU change over time?
-- Metric: DAU per day (line chart in results/06_dau_trend.png)
-- Dataset: Flood It! (Firebase public sample), all daily tables (events_*)
-- Findings:
--   * Baseline DAU is stable at roughly 400-550 for the whole period,
--     with a slight increase toward late September.
--   * Several short, sharp spikes (DAU > 1,200 for 1-2 days, then back to baseline)
--     occur between mid-June and early July. These are outliers, not a downward trend.
--   * Lesson: the top-5 table alone suggested a decline; the chart disproved it.
--     Always check the distribution before drawing conclusions.
--   * Next step: check whether new users (first_open) also spiked on those days,
--     which would point to acquisition campaigns.

SELECT
  PARSE_DATE('%Y%m%d', _TABLE_SUFFIX) AS event_date,
  COUNT(DISTINCT user_pseudo_id) AS dau
FROM `firebase-public-project.analytics_153293282.events_*`
GROUP BY event_date
ORDER BY event_date;