#!/usr/bin/env -S duckdb -f
.bail on
-- .echo on

.shell echo $PPID
select getenv('PPID');
.quit

set variable tmpid = (select uuid());
.once "|read id && mkfifo /tmp/gh_auth_$id && echo create secret gh_auth \"(type http, scope 'https://api.github.com', bearer_token '$(gh auth token)');\" >/tmp/gh_auth_$id && rm /tmp/gh_auth_$id"
copy (select getvariable('tmpid')) to stdout (format csv);
.read
.shell "mkfifo /tmp/gh_auth &&  & echo $! > /tmp/gh_auth.pid; disown %1"
.read /tmp/gh_auth
.shell "rm -f /tmp/gh_auth"
.output

set variable gh_api_url = 'https://api.github.com';

set variable last_run_id = (
  select max(parse_filename(file, true))
  from glob('data/entity=workflow_run/*.parquet')
);
set variable last_run_at = (select
  uuid_extract_timestamp(getvariable('last_run_id'))
);
set variable gh_daterange = (select url_encode(
  strftime(getvariable('last_run_at') + interval '1 ms', '%xT%X%z')
  || '..*'
));

.output

prepare gh_api as
  copy (
    from read_json(format('{}/{}', getvariable('gh_api_url'), $path))
    select unnest(columns($unnest))
  ) to $outpath (
    format json,
    append
  );

execute gh_api(
  path:='repos/HHS/simpler-grants-gov/actions/runs?exclude_pull_requests=true&created=' || getvariable('gh_daterange'),
  outpath:='data/workflow_runs',
  unnest:='workflow_runs'
);
