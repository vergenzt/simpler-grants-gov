-- Raw vulnerability findings from Grype JSON artifacts produced by the
-- `anchore-scan` job in vulnerability-scans.yml. Each row is one match from
-- one scan run.
--
-- Source files live at data/grype/{run_id}-{app_name}.json and are produced by
-- collect-grype-artifacts.sh.  Override grype_data_path to point at the sample
-- fixtures or an S3 prefix during testing or production runs respectively.
--
-- Analysis approach originally developed by Evan Snow in Vulnerability_Scans.ipynb.

{{ config(materialized='table') }}

with raw as (
    select
        run_id::bigint          as run_id,
        app_name::varchar       as app_name,
        started_at::timestamptz as started_at,
        unnest(scan.matches)    as m
    from read_json(
        '{{ var("grype_data_path", "data/grype/*.json") }}',
        auto_detect = true
    )
)

select
    run_id,
    app_name,
    started_at,
    m.vulnerability.id::varchar        as vulnerability_id,
    m.vulnerability.severity::varchar  as severity,
    m.vulnerability.namespace::varchar as namespace,
    m.vulnerability.fix.state::varchar as fix_state,
    m.artifact.name::varchar           as package_name,
    m.artifact.version::varchar        as package_version,
    m.artifact.type::varchar           as package_type,
    m.artifact.purl::varchar           as purl
from raw
