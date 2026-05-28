-- Cleaned vulnerability observations. One row per match per scan run.
-- Grype outputs CVE IDs directly in vulnerability.id — no ALAS/GHSA remapping needed.

select
    run_id,
    app_name,
    started_at,
    vulnerability_id,
    severity,
    namespace,
    fix_state,
    package_name,
    package_version,
    package_type,
    purl
from {{ ref('grype_findings') }}
where vulnerability_id is not null
  and package_name is not null
