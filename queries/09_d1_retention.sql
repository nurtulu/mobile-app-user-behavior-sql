-- Business question: What share of new users come back the day after their first open?
-- Metric: Day-1 (D1) retention
-- Dataset: Flood It! (Firebase public sample), all daily tables (events_*)
-- Technique: Two CTEs (installs, activity) combined with LEFT JOIN, so users who
--            never returned are kept in the denominator.
-- Notes:
--   * Users who installed on the last day (2018-10-03) are excluded with HAVING,
--     because their "next day" is not in the data.
--   * MIN() takes the first first_open per user (a user can reinstall).
-- Findings:
--   * 4,251 new users, 915 returned on day 1 -> D1 retention = 21.5%.
--   * Sanity check: 4,251 users / ~113 days = ~38 new users per day, consistent
--     with the 25-38 new users per day seen in 08_spike_day_check.
--   * Below commonly cited ranges for mobile games (roughly 25-40%, varies by source).
--   * Limitation: the 50,000-row daily cap may hide some activity, so true retention
--     is likely somewhat higher. Read as "at least 21.5%".

WITH installs AS (
  SELECT
    user_pseudo_id,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS install_date
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE event_name = 'first_open'
  GROUP BY user_pseudo_id
  HAVING install_date < DATE '2018-10-03'
),
activity AS (
  SELECT DISTINCT
    user_pseudo_id,
    PARSE_DATE('%Y%m%d', event_date) AS active_date
  FROM `firebase-public-project.analytics_153293282.events_*`
)
SELECT
  COUNT(DISTINCT i.user_pseudo_id) AS new_users,
  COUNT(DISTINCT IF(a.active_date = DATE_ADD(i.install_date, INTERVAL 1 DAY),
                    i.user_pseudo_id, NULL)) AS returned_day1,
  ROUND(100 * COUNT(DISTINCT IF(a.active_date = DATE_ADD(i.install_date, INTERVAL 1 DAY),
                                i.user_pseudo_id, NULL))
            / COUNT(DISTINCT i.user_pseudo_id), 1) AS d1_retention_pct
FROM installs i
LEFT JOIN activity a
  ON i.user_pseudo_id = a.user_pseudo_id;