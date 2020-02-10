#!/bin/sh
#Add IP to find_apps_for_cell to retrieve all apps running on that cell 

next_url="/v3/apps"
find_apps_for_cell="<insert-ip>"

while [[ "${next_url}" != "null" ]]; do
  echo "Page: ${next_url}"
  started_apps=$(cf curl ${next_url} | jq -r '.resources[] | select(.state == "STARTED")'.guid)
  for app_guid in $started_apps; do
    echo "[DEUG] No match, app GUID: ${app_guid}"
    found_cell=$(cf curl /v3/processes/${app_guid}/stats | jq -r -c '.resources[] | select(.host == '\"$find_apps_for_cell\"')'.guid)
    if [[ $found_cell != "" ]]; then
      echo "App GUID ${app_guid} running on cell ${find_apps_for_cell}, Stats:"
      cf curl /v3/processes/${app_guid}/stats | jq -r -c '.resources[]'
    fi
  done
  next_url=$(cf curl ${next_url} | jq -r -c ".pagination.next.href" | sed 's/.*.com//;s/.*.cn//')
done