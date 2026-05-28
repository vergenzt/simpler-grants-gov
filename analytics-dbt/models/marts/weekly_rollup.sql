-- Weekly counts of new and still-open vulnerabilities per severity tier.
--
-- "new" = first appeared during that calendar week.
-- "open" = first appeared on or before the week and last seen on or after it
--          (i.e. still showing up in scans that week).
-- Uses ISO weeks (Monday–Sunday). Each row is one (week_start, severity) pair.

with lifecycle as (
    select
        vulnerability_id,
        package_name,
        package_version,
        app_name,
        severity,
        date_trunc('week', first_seen)::date as first_seen_week,
        date_trunc('week', last_seen)::date  as last_seen_week
    from {{ ref('vuln_lifecycle') }}
),

weeks as (
    select distinct date_trunc('week', gs)::date as week_start
    from unnest(
        generate_series(
            (select min(first_seen_week) from lifecycle),
            current_date::timestamp,
            interval '7 days'
        )
    ) as t(gs)
)

select
    w.week_start,
    l.severity,
    count(case when l.first_seen_week = w.week_start                                    then 1 end) as new_vulns,
    count(case when l.first_seen_week <= w.week_start and l.last_seen_week >= w.week_start then 1 end) as open_vulns
from weeks w
cross join lifecycle l
group by w.week_start, l.severity
order by w.week_start, l.severity
