-- Business question: How many unique users were active in a day?
-- Metric: DAU (Daily Active Users)
-- Dataset: Flood It! (Firebase public sample), 2018-10-03
-- Finding: 484 active users -> ~103 events per user, showing high in-game engagement.

SELECT COUNT(DISTINCT user_pseudo_id) AS daily_active_users
FROM `firebase-public-project.analytics_153293282.events_20181003`;