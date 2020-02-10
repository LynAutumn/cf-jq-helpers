#!/bin/sh

next_url="/v3/apps"

while [[ "${next_url}" != "null" ]]; do
  echo "Page: ${next_url}"
  app_guids=$(cf curl ${next_url} | jq -r '.resources[].guid')

  for app_guid in $app_guids; do
    crashed_app=$(cf curl /v3/processes/${app_guid}/stats | jq '.resources[] | select(.state == "CRASHED") | [.type, .index, .state] | @tsv')
    #If this results in "jq: error (at <stdin>:9): Cannot iterate over null (null)", the app exists, however no process can be mapped to it at the time
    if [[ $crashed_app != "" ]]; then
      count=$((count +1 ))
      echo "${count}: Crashed App GUID ${app_guid}, name: $(cf curl /v3/apps/${app_guid} | jq -r '.name')"
    fi
  done
  next_url=$(cf curl ${next_url} | jq -r -c ".pagination.next.href" | sed 's/.*.com//;s/.*.cn//')
done