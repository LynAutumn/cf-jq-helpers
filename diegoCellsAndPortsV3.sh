#!/bin/sh

next_url="/v3/apps"
while [[ "${next_url}" != "null" ]]; do
  echo "Page: ${next_url}"
  echo "Format: Host, ExternalPort1, ExternalPort2, InternalPort1, InternalPort2"
  started_apps=$(cf curl ${next_url} | jq -r '.resources[] | select(.state == "STARTED")'.guid)
  for app_guid in $started_apps; do
    echo "AppGuid: ${app_guid}:"
    cf curl /v3/processes/${app_guid}/stats | jq -r -c '.resources[] | [ "host: ", .host, "port_external: ", .instance_ports[].external, "port_internal: ", .instance_ports[].internal] | @tsv'
  done
  next_url=$(cf curl ${next_url} | jq -r -c ".pagination.next.href" | sed 's/.*.com//;s/.*.cn//')
done