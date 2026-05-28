{{ config(
    materialized="incremental",
    incremental_strategy="microbatch",
    event_time="created_at",
    begin="2026-04-15",
    batch_size="day",
    concurrent_batches=false,
) }}

select
  unnest(workflow_runs, max_depth:=2)
from
  read_json(
    '{{ var("gh_url") }}/repos/{{ var("gh_repo") }}/actions/runs?'
      'status=completed&'
      'created=
      {%- if execute %}
        {%- set event_start = model.batch.event_time_start %}
        {#- Github datetime ranges are *inclusive*... so subtract one quantum of time from event_time_end #}
        {%- set event_end = model.batch.event_time_end  - modules.datetime.timedelta.resolution %}
        {{- event_start.replace(tzinfo=none).isoformat() }}..{{ event_end.replace(tzinfo=none).isoformat() }}
      {%- endif -%}
      '
  )
