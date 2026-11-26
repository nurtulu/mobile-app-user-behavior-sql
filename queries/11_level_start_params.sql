-- Business question: What extra information (parameters) does the level start event carry?
-- Metric: Parameter names and counts for level_start_quickplay (exploration)
-- Dataset: Flood It! (Firebase public sample), 2018-10-03
-- Technique: event_params is a nested, repeated field (a list of key-value pairs per
--            event). ", UNNEST(event_params)" flattens it to one row per parameter.
-- Findings:
--   * 4 parameters: firebase_event_origin, board, firebase_screen_class, firebase_screen_id.
--   * Check passed: board appears 5,266 times = number of level_start_quickplay events
--     (03_top_events), so every level start has a board value.
--   * Screen parameters are missing on 94 events: auto-collected params can be incomplete.
--   * "board" = board size (difficulty) -> basis for the difficulty analysis.

SELECT
  ep.key AS param_name,
  COUNT(*) AS param_count
FROM `firebase-public-project.analytics_153293282.events_20181003`,
  UNNEST(event_params) AS ep
WHERE event_name = 'level_start_quickplay'
GROUP BY param_name
ORDER BY param_count DESC;