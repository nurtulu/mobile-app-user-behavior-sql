# Mobile App User Behavior Analysis with SQL (BigQuery)

SQL analysis of real mobile game event data from **Flood It!**, a public Firebase Analytics sample dataset on Google BigQuery. The project answers product questions on engagement, retention and level difficulty, and validates data quality along the way.

**Tools:** Google BigQuery (SQL), Firebase Analytics event data, Git & GitHub
**Period analyzed:** 114 days (2018-06-12 to 2018-10-03)

---

## Key Findings

| Area | Finding |
|---|---|
| **Engagement** | Stable baseline of ~400–550 daily active users (average DAU: 518), ~1.3 sessions per user per day. |
| **Retention** | **D1 retention: ~21.5%**, below commonly cited ranges for mobile games. D7 retention: 5.6%. The biggest drop happens in the first 24 hours (−78 points); the curve flattens after ~D5 (core users). |
| **Difficulty** | Win rate drops with board size: **Small 62.5% → Medium 50.4% → Large 30.7%**. 84% of games are played on the Small board. |
| **Abandonment** | Surprisingly, abandonment is highest on the **easiest** board (40% of Small games are not finished vs ~25% on Medium/Large). |
| **Monetization** | Only 1 in-app purchase among 484 active users on a sample day: very low monetization. |
| **Data quality** | Several DAU spikes (>1,200 users) turned out to be most likely a **sampling artifact**, not real user behavior (see below). |

### Product Recommendations
1. **Focus on the first-day experience.** Most users are lost in the first 24 hours, so onboarding and early level difficulty are the biggest levers for retention.
2. **A/B test difficulty balancing on Large boards** (e.g., easier early Large levels or better difficulty guidance). Measure win rate and D1 retention.
3. **Investigate abandonment on Small boards.** Check whether quick restarts (`level_reset`) or interrupted sessions drive it.

---

## Data Quality & Limitations

Validating the data was a core part of this project:

- **Daily cap of 50,000 events.** Every day has exactly 50,000 events (min = max across all 114 days), so the public sample is capped. Event counts are therefore not a reliable metric. **User-based metrics and ratios** are used for interpretation.
- **DAU spikes are likely an artifact.** On spike days, DAU tripled while new users dropped to 0–10 (normal: 25–38) and events per user fell from ~120 to ~39. Zero installs on a day with 3x users is not plausible behavior; the fixed 50,000-row cap spread across more users explains the pattern. In a real company, this would be confirmed with the data engineering team before any decision.
- **Retention is a lower bound.** Because of the cap, some activity may be missing, so true retention is likely somewhat higher.
- **Small samples mislead.** A single day showed a ~16% win rate on Large boards (based on only ~285 games); the full period shows 30.7%.

### Lessons Learned
- A "Top 5 days" table suggested a declining trend; the **line chart disproved it**. Always check the distribution before drawing conclusions.
- Hypotheses were tested and **rejected when the data disagreed** (e.g., "spikes came from new installs").
- Cross-checks between queries (e.g., level start totals, new users per day) were used to confirm results.

---

## Queries

| # | Query | Business question | SQL techniques |
|---|---|---|---|
| 01 | [daily_events](queries/01_daily_events.sql) | How much activity in a day? | `COUNT(*)` |
| 02 | [daily_active_users](queries/02_daily_active_users.sql) | How many unique users per day? | `COUNT(DISTINCT)` |
| 03 | [top_events](queries/03_top_events.sql) | What do users do most? | `GROUP BY`, `ORDER BY`, `LIMIT` |
| 04 | [period_summary](queries/04_period_summary.sql) | What period does the data cover? | CTE (`WITH`), wildcard tables, `MIN`/`MAX`/`AVG` |
| 05 | [top_dau_days](queries/05_top_dau_days.sql) | Which days had the most users? | CTE, Top-N |
| 06 | [dau_trend](queries/06_dau_trend.sql) | How does DAU change over time? | `PARSE_DATE`, time series |
| 07 | [dau_vs_new_users](queries/07_dau_vs_new_users.sql) | Were spikes driven by new users? | Conditional aggregation `COUNT(DISTINCT IF(...))` |
| 08 | [spike_day_check](queries/08_spike_day_check.sql) | Are spikes real or a data artifact? | `WHERE IN`, derived metrics, baseline comparison |
| 09 | [d1_retention](queries/09_d1_retention.sql) | What share of new users return the next day? | Multiple CTEs, `LEFT JOIN`, `HAVING`, `DATE_ADD` |
| 10 | [retention_curve](queries/10_retention_curve.sql) | How does retention develop over the first week? | Cohort analysis, `INNER JOIN`, `DATE_DIFF`, subquery |
| 11 | [level_start_params](queries/11_level_start_params.sql) | What parameters do level events carry? | `UNNEST` (nested & repeated fields) |
| 12 | [board_breakdown_one_day](queries/12_board_breakdown_one_day.sql) | How are games distributed across board sizes? | Scalar subquery on `UNNEST(event_params)` |
| 13 | [difficulty_by_board](queries/13_difficulty_by_board.sql) | How difficult is each board size? | `CASE WHEN`, `COUNTIF`, `SAFE_DIVIDE` |

Each `.sql` file starts with the business question, metric, findings and notes. Result screenshots are in [`results/`](results/).

---

## Repository Structure

```
mobile-app-user-behavior-sql/
├── README.md
├── queries/   → 13 SQL queries with comments
└── results/   → screenshots of query results and charts
```

## How to Run

1. Open [Google BigQuery](https://console.cloud.google.com/bigquery) (the free sandbox works, no credit card needed).
2. Copy any query from `queries/` into the editor and run it.
3. Dataset: `firebase-public-project.analytics_153293282.events_*`