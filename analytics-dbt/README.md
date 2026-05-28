# Vulnerability Analysis — analytics-dbt

dbt + DuckDB pipeline that turns Grype scan artifacts from GitHub Actions into
structured vulnerability lifecycle data. The goal is a durable, query-able
history of which CVEs appeared in each container image, when they were first
seen, how long they stayed open, and how the count changes week-over-week.

Context: Jira BEN-219, GitHub epic HHS/simpler-grants-gov#9498.

## Data flow

```
GitHub Actions (weekly)
  └─ vulnerability-scans.yml  ← anchore-scan job
       └─ Grype JSON artifact  (90-day retention)
            "anchore-grype-json-{app}-{run_id}"

collect-grype-artifacts.sh   ← run once locally to download
  └─ data/grype/{run_id}-{app}.json

dbt run
  └─ ingest/grype_findings     ← Python model, reads data/grype/*.json
  └─ staging/stg_vuln_observations
  └─ marts/vuln_lifecycle      ← first_seen / last_seen / days_open per CVE
  └─ marts/weekly_rollup       ← new + open counts by week and severity
```

The `ingest/workflow_runs` model is a separate microbatch ingest of GitHub
workflow run metadata (needs `DBT_ENV_SECRET_GITHUB_TOKEN`). It is not
required by the vulnerability models; it exists to cross-reference run IDs
with commit hashes and branch names.

## Quick start

```bash
# 1. Install dependencies
cd analytics-dbt
uv sync

# 2. (Option A) Use the bundled sample data (3 findings, no credentials needed)
uv run dbt run --vars '{grype_data_path: data/sample/*.json}' \
               --exclude workflow_runs

# 2. (Option B) Download real artifacts from the last 90 days
export GITHUB_TOKEN=$(gh auth token)
./collect-grype-artifacts.sh          # populates data/grype/
uv run dbt run --exclude workflow_runs
```

After a successful run, query results:

```bash
duckdb target/results.duckdb \
  "select * from vuln_lifecycle order by days_open desc limit 20"
```

## Model reference

| Model | Description |
|-------|-------------|
| `ingest/grype_findings` | Raw findings from local Grype JSON files. One row per match per run. |
| `ingest/workflow_runs` | Workflow run metadata from GH API (requires GH token). |
| `staging/stg_vuln_observations` | Typed, null-filtered view of `grype_findings`. |
| `marts/vuln_lifecycle` | First/last seen, days open per (CVE, package, version, app). |
| `marts/weekly_rollup` | Weekly new-and-open counts by severity. |

## Configuration

| dbt var | Default | Purpose |
|---------|---------|---------|
| `grype_data_path` | `data/grype/*.json` | Glob for input Grype artifacts |
| `gh_url` | `https://api.github.com` | GH API base (for `workflow_runs` model) |
| `gh_repo` | `HHS/simpler-grants-gov` | Repo slug (for `workflow_runs` model) |

Override vars on the command line: `dbt run --vars '{grype_data_path: s3://...}'`

## Adding S3 persistence (Phase 2)

When the S3 bucket is provisioned:
1. Run `collect-grype-artifacts.sh` and upload the JSON files to the bucket.
2. Configure the DuckDB S3 secret in `profiles.yml`.
3. Override `grype_data_path` with an `s3://.../*.json` glob.
4. Set up a scheduled Lambda or GitHub Action to run `collect-grype-artifacts.sh`
   + `dbt run` on a nightly cadence.

## Open questions

- **Closed vs open detection**: `last_seen` is the last scan date the CVE appeared. A
  vulnerability is "closed" only after it stops appearing. This is approximate — if there's
  a gap in scan history, a temporarily-absent CVE will show a premature `last_seen`.
  A stricter approach would require a run-level "expected scans" list.
- **Dedup within a run**: if the same CVE matches multiple packages, each gets its own row.
  This is intentional; the lifecycle model groups by `(cve, package, version, app)`.
- **EPSS scores**: the original notebook tracked EPSS; Grype doesn't include EPSS in its JSON.
  Could be joined in from the FIRST EPSS API by CVE ID if needed.
