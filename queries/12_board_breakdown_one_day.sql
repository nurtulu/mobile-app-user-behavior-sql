-- Business question: Do win/fail events also carry the board size, and how is it distributed?
-- Metric: Level start / complete / fail counts by board size (one day)
-- Dataset: Flood It! (Firebase public sample), 2018-10-03
-- Technique: Scalar subquery on UNNEST - the standard pattern to pull ONE parameter
--            into its own column without multiplying rows:
--            (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'board')
-- Findings:
--   * Check passed: totals match 03_top_events (starts 5,266 / wins 2,004 / fails 1,002),
--     so board is present on all three events.
--   * Board sizes: S, M, L. 88% of level starts are on S.
--   * One-day win rate on L looked very low (~16%), but this was based on only ~285
--     finished games. Re-checked on the full period in 13_difficulty_by_board.

SELECT
  event_name,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'board') AS board,
  COUNT(*) AS event_count
FROM `firebase-public-project.analytics_153293282.events_20181003`
WHERE event_name IN ('level_start_quickplay', 'level_complete_quickplay', 'level_fail_quickplay')
GROUP BY event_name, board
ORDER BY board, event_name;