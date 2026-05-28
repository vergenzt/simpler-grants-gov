#!/usr/bin/env bash
# Download Grype JSON artifacts from GitHub Actions and save them to data/grype/.
# Each output file is a single JSON object:
#   { run_id, app_name, started_at, scan: <original grype JSON> }
#
# Prerequisites:
#   - gh CLI authenticated (gh auth login)
#   - jq installed
#
# Usage:
#   ./collect-grype-artifacts.sh [--since YYYY-MM-DD] [--repo owner/repo]
#
# Defaults to the last 90 days of the HHS/simpler-grants-gov repository.

set -euo pipefail

GH_REPO="HHS/simpler-grants-gov"
DAYS_BACK=90
OUTPUT_DIR="data/grype"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --since)   SINCE="$2";    shift 2 ;;
    --repo)    GH_REPO="$2";  shift 2 ;;
    --days)    DAYS_BACK="$2"; shift 2 ;;
    --output)  OUTPUT_DIR="$2"; shift 2 ;;
    *) echo "Unknown flag: $1" >&2; exit 1 ;;
  esac
done

SINCE="${SINCE:-$(date -d "${DAYS_BACK} days ago" -I 2>/dev/null || date -v "-${DAYS_BACK}d" -I)}"

mkdir -p "$OUTPUT_DIR"
echo "Fetching runs from ${GH_REPO} since ${SINCE} → ${OUTPUT_DIR}/"

# Fetch completed workflow runs that belong to the Vulnerability Scans workflow.
# The weekly job is named "Vulnerability Scans" (or called from a parent workflow).
gh api "repos/${GH_REPO}/actions/runs" \
  --paginate \
  -F created="${SINCE}..*" \
  -F status=completed \
  --jq '.workflow_runs[] | select(.name | test("Vulnerability|vuln"; "i")) | {id,name,created_at}' \
| while IFS= read -r run_json; do
    run_id=$(echo "$run_json"   | jq -r '.id')
    created_at=$(echo "$run_json" | jq -r '.created_at')

    # Find all anchore-grype-json-* artifacts attached to this run.
    artifacts=$(
      gh api "repos/${GH_REPO}/actions/runs/${run_id}/artifacts" \
        --jq '.artifacts[] | select(.name | startswith("anchore-grype-json-"))' 2>/dev/null \
      || true
    )

    [ -z "$artifacts" ] && continue

    echo "$artifacts" | while IFS= read -r artifact_json; do
      artifact_id=$(echo "$artifact_json" | jq -r '.id')
      artifact_name=$(echo "$artifact_json" | jq -r '.name')

      # artifact_name is "anchore-grype-json-{app_name}-{run_id}"
      app_name=$(echo "$artifact_name" \
        | sed 's/^anchore-grype-json-//' \
        | sed "s/-${run_id}$//")

      output_file="${OUTPUT_DIR}/${run_id}-${app_name}.json"
      [ -f "$output_file" ] && { echo "  skip ${output_file} (already exists)"; continue; }

      tmpdir=$(mktemp -d)
      trap 'rm -rf "$tmpdir"' EXIT

      echo "  downloading artifact ${artifact_id} → ${output_file}"
      if gh api "repos/${GH_REPO}/actions/artifacts/${artifact_id}/zip" \
           > "${tmpdir}/artifact.zip" 2>/dev/null; then
        unzip -q "${tmpdir}/artifact.zip" -d "${tmpdir}/extracted"
        json_file=$(find "${tmpdir}/extracted" -name "*.json" | head -1)

        if [ -n "$json_file" ]; then
          jq --argjson run_id "$run_id" \
             --arg app_name "$app_name" \
             --arg started_at "$created_at" \
             '{run_id: $run_id, app_name: $app_name, started_at: $started_at, scan: .}' \
             "$json_file" > "$output_file"
        else
          echo "  warning: no JSON found in artifact ${artifact_id}" >&2
        fi
      else
        echo "  warning: failed to download artifact ${artifact_id}" >&2
      fi

      trap - EXIT
      rm -rf "$tmpdir"
    done
  done

echo "Done. Files in ${OUTPUT_DIR}/:"
ls -1 "$OUTPUT_DIR"/*.json 2>/dev/null | wc -l
