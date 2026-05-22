#!/usr/bin/env bash
set -euo pipefail  # https://sipb.mit.edu/doc/safe-shell/

export GH_REPO=${GH_REPO:-HHS/simpler-grants-gov}

parallel() { PARALLEL_SHELL=bash command parallel --plain "$@";  }

dates="$@"
if [ ${#dates} -eq 0 ]; then
  dates=($(python -c 'import datetime as dt; [print(dt.datetime.now(dt.UTC).date() + dt.timedelta(n)) for n in range(-90, 0)]'))
fi

# useful parallel --match args and placeholders
date_match='(\d{4}).(\d{2}).(\d{2})'
yyyy={1.1}; mm={1.2}; dd={1.3}


### begin actual fetches ###

fetch_workflow_runs_for_date=(
  --quote
  --plus
  --match="$date_match"
  --results=data/${yyyy}-${mm}/${dd}/workflow_runs/index.ndjson
  --resume

  gh api
    # https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2026-03-10#list-workflow-runs-for-a-repository
    /repos/{owner}/{repo}/actions/runs
    -X GET
    -F created=${yyyy}-${mm}-${dd}
    -F status=completed
    -F exclude_pull_requests=true
    --paginate
    --jq='del(.total_count)[][]'
    --cache=$((24*30))h
)

echo "Fetching workflow runs:"
parallel "${fetch_workflow_runs_for_date[@]}" <<< "${dates[@]}"

id={1.4}
jobs_url={1.5}

fetch_workflow_run_details=(
  --match="$date_match"
  --results=data/${yyyy}-${mm}/${dd}/jobs/all.ndjson
  --dry-run
  -t

  curl
    -sSL --fail --fail-early
    https://api.github.com/
    '{= uq; $_ = `jq -r .jobs_url $_`; $_ =~ tr{\n}{ } =}'
)

echo "Fetching workflow run details:"
parallel --progress "${fetch_workflow_run_details[@]}" \
  ::: data/*/*/workflow_runs/index.ndjson

# gh api /repos/HHS/simpler-grants-gov/actions/runs -F created="$(date -d '90 days ago' -I)..*" --jq=.workflow_runs[] \
# | parallel

#   | parallel --colsep=\t -q gh run view {2} --json=startedAt,databaseId,name,workflowName,workflowDatabaseId,jobs --jq='del(.jobs, .name, .databaseId) * { workflowRunName: .name, workflowRunDatabaseId: .databaseId } * (.jobs[] | select(.name | endswith("/ Anchore Scan")) | { jobDatabaseId: .databaseId, jobName: .name })' \
#   | parallel --progress --bar --eta gh api --cache=24h /repos/{owner}/{repo}/actions/jobs/'$(echo {} | jq -r .jobDatabaseId)'/logs \
#     \| cut -d"' '" -f2- \
#     \| sed -n '\'/^NAME *INSTALLED/,/^$/p\'' \
#     \| grep -v '\'^$\'' \
#     \| jq -nRc '\'(input? | [foreach scan("(?:[A-Z]+ )+ +") as $head ({ column: "", length: 0, start: 0 }; . as $prev | { column: ($head | gsub(" +$"; "")), length: ($head | length), start: ($prev.start + $prev.length) })]) as $cols | inputs as $line | $METADATA * reduce $cols[] as $col ({ }; . * { ($col.column): ($line[$col.start:$col.start + $col.length] | gsub(" +$"; "")) }) | .PFX = (.VULNERABILITY | split("-")[0])\'' --argjson METADATA {} \
#   | PARALLEL_SHELL=bash parallel echo {} \| jq -c '\'.CVE_ID = (($from_alas // $from_ghsa // .VULNERABILITY) | split("\n")[])\'' \
#     --arg from_alas '"$(if [[ {[.PFX]} = "ALAS2023" ]]; then curl -sSL https://alas.aws.amazon.com/AL2023/{[.VULNERABILITY]}.html | htmlq \'#references a[href^="https://explore.alas.aws.amazon.com/CVE-"]\' -t | tr -dc \'[A-Z0-9-\\n]\'; fi)"' \
#     --arg from_ghsa '"$(if [[ {[.PFX]} = "GHSA" ]]; then gh api /advisories/{[.VULNERABILITY]} | jq -r .cve_id; fi)"' \
#   > vulns-found-main-normalized-$(date -d '90 days ago' -I)-thru-$(date -I).ndjson
