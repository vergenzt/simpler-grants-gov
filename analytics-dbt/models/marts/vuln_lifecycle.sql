-- Vulnerability lifecycle: earliest and latest observation for each
-- (CVE, package, version, app) tuple across all scans in the data window.
--
-- `days_open` is the span between first and last scan appearance — a rough
-- proxy for "days the vulnerability was present". It underestimates if the
-- scan cadence has gaps, and resets if a vuln disappears and reappears.
-- Interpretation approach originally developed by Evan Snow in Vulnerability_Scans.ipynb.

select
    vulnerability_id,
    package_name,
    package_version,
    app_name,
    severity,
    fix_state,
    min(started_at)                                   as first_seen,
    max(started_at)                                   as last_seen,
    datediff('day', min(started_at), max(started_at)) as days_open,
    count(distinct run_id)                            as scan_appearances
from {{ ref('stg_vuln_observations') }}
group by
    vulnerability_id,
    package_name,
    package_version,
    app_name,
    severity,
    fix_state
