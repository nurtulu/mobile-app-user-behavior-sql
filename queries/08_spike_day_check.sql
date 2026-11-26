-- Business question: Are the DAU spikes real user behavior or a data artifact?
-- Metric: DAU, new users, returning users and events per user on spike days
--         (2018-06-18/19) vs neighboring baseline days
-- Dataset: Flood It! (Firebase public sample), 2018-06-16 to 2018-06-21
-- Findings:
--   * Baseline days: DAU 393-443, 25-38 new users, 113-127 events per user.
--   * Spike days: DAU 1,240-1,283 but only 0-10 new users and ~39-40 events per user.
--   * Zero installs on a day with 3x users is not plausible real behavior.
--     Because daily events are capped at 50,000, spreading the cap across more
--     users mechanically lowers events per user.
-- Conclusion: The spikes are most likely a SAMPLING ARTIFACT of the public dataset,
--             not real user behavior. In a real company this would be confirmed with
--             the data engineering team before any decision is based on it.

WITH daily AS (
  SELECT
    _TABLE_SUFFIX AS event_date,
    COUNT(*) AS total_events,
    COUNT(DISTINCT user_pseudo_id) AS dau,
    COUNT(DISTINCT IF(event_name = 'first_open', user_pseudo_id, NULL)) AS new_users
  FROM `firebase-public-project.analytics_153293282.events_*`
  GROUP BY event_date
)
SELECT
  event_date,
  dau,
  new_users,
  dau - new_users AS returning_users,
  ROUND(total_events / dau, 1) AS events_per_user
FROM daily
WHERE event_date IN ('20180616', '20180617', '20180618', '20180619', '20180620', '20180621')
ORDER BY event_date;