-- Business question: How does retention develop over the first week, and where do users drop off?
-- Metric: D0-D7 retention curve (cohort analysis), chart in results/10_retention_curve.png
-- Dataset: Flood It! (Firebase public sample), installs up to 2018-09-26
--          (so every user has 7 full days of follow-up in the data)
-- Technique: INNER JOIN of installs and activity, DATE_DIFF for days since install,
--            scalar subquery for the cohort size (denominator).
-- Findings:
--   * Check passed: D0 = 100% (every new user is active on install day).
--   * D1 21.9% -> D2 14.4% -> D3 10.6% -> D7 5.6%.
--   * The biggest drop is in the first 24 hours (-78 points); later losses are much
--     smaller and the curve flattens after ~D5 (core users).
--   * D1 here (21.9%) differs slightly from 09_d1_retention (21.5%) because the
--     cohorts differ (installs up to 09-26 vs 10-02).
--   * Product takeaway: the first-day experience (onboarding, early level difficulty)
--     is the biggest lever. This is consistent with 43% of started levels never
--     being finished (03_top_events).

WITH installs AS (
  SELECT
    user_pseudo_id,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS install_date
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE event_name = 'first_open'
  GROUP BY user_pseudo_id
  HAVING install_date <= DATE '2018-09-26'
),
activity AS (
  SELECT DISTINCT
    user_pseudo_id,
    PARSE_DATE('%Y%m%d', event_date) AS active_date
  FROM `firebase-public-project.analytics_153293282.events_*`
)
SELECT
  DATE_DIFF(a.active_date, i.install_date, DAY) AS day_number,
  COUNT(DISTINCT a.user_pseudo_id) AS active_users,
  ROUND(100 * COUNT(DISTINCT a.user_pseudo_id) / (SELECT COUNT(*) FROM installs), 1) AS retention_pct
FROM installs i
INNER JOIN activity a
  ON i.user_pseudo_id = a.user_pseudo_id
WHERE DATE_DIFF(a.active_date, i.install_date, DAY) BETWEEN 0 AND 7
GROUP BY day_number
ORDER BY day_number;