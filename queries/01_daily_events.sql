-- Business question: How much activity does the app generate in a day?
-- Metric: Total events per day
-- Dataset: Flood It! (Firebase public sample), 2018-10-03
-- Finding: 50,000 events. The exactly round number suggests the public
--          sample is capped at 50,000 rows per day (to be validated on other days).

SELECT COUNT(*) AS total_events
FROM `firebase-public-project.analytics_153293282.events_20181003`;