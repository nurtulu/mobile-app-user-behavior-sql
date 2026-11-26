-- Business question: How difficult is each board size, and where do players abandon games?
-- Metric: Starts, wins, fails, win rate and finish rate by board size (full period)
-- Dataset: Flood It! (Firebase public sample), all daily tables (events_*)
-- Techniques: CASE WHEN (readable labels + 'Unknown' safety net), COUNTIF (several
--             counts in one pass), SAFE_DIVIDE (avoids divide-by-zero errors).
-- Findings:
--   * Win rate: Small 62.5% > Medium 50.4% > Large 30.7% -> difficulty increases with
--     board size as designed (consistency check passed).
--   * 84% of all games are played on Small.
--   * Lesson: the one-day sample (12_board_breakdown_one_day) showed ~16% win rate on Large;
--     the full period shows 30.7%. Small samples are misleading.
--   * Surprise: abandonment is highest on the EASIEST board (Small: 40% of games not
--     finished vs ~25% on Medium/Large). Hypothesis for follow-up: quick restarts
--     (level_reset) or short, interrupted sessions.
--   * No 'Unknown' row -> board is filled on every level event.
--   * Limitation: absolute counts are affected by the 50,000-row daily cap; ratios are
--     more reliable and are used for interpretation.
--   * Product idea: A/B test easier early Large boards or better difficulty guidance,
--     measuring win rate and D1 retention.

WITH level_events AS (
  SELECT
    event_name,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'board') AS board
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE event_name IN ('level_start_quickplay', 'level_complete_quickplay', 'level_fail_quickplay')
)
SELECT
  CASE board
    WHEN 'S' THEN 'Small'
    WHEN 'M' THEN 'Medium'
    WHEN 'L' THEN 'Large'
    ELSE 'Unknown'
  END AS board_size,
  COUNTIF(event_name = 'level_start_quickplay') AS starts,
  COUNTIF(event_name = 'level_complete_quickplay') AS wins,
  COUNTIF(event_name = 'level_fail_quickplay') AS fails,
  ROUND(100 * SAFE_DIVIDE(
    COUNTIF(event_name = 'level_complete_quickplay'),
    COUNTIF(event_name IN ('level_complete_quickplay', 'level_fail_quickplay'))), 1) AS win_rate_pct,
  ROUND(100 * SAFE_DIVIDE(
    COUNTIF(event_name IN ('level_complete_quickplay', 'level_fail_quickplay')),
    COUNTIF(event_name = 'level_start_quickplay')), 1) AS finish_rate_pct
FROM level_events
GROUP BY board_size
ORDER BY starts DESC;