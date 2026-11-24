-- Business question: What do users do most in the app?
-- Metric: Event count by event type (Top 10)
-- Dataset: Flood It! (Firebase public sample), 2018-10-03
-- Findings:
--   * 648 sessions for 484 users -> ~1.3 sessions per user per day.
--   * Data consistency check: level_complete (2,004) + level_fail (1,002)
--     = level_end (3,006).
--   * Level funnel: 5,266 starts -> 3,006 ends (57%) -> 2,004 wins (38%).
--     43% of started levels are never finished.
--   * Only 1 in_app_purchase event for the day -> very low monetization.

SELECT event_name, COUNT(*) AS event_count
FROM `firebase-public-project.analytics_153293282.events_20181003`
GROUP BY event_name
ORDER BY event_count DESC
LIMIT 10;