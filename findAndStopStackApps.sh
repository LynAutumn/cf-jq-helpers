#!/bin/sh

desiredStack=cflinuxfs2
next_url="/v3/apps"
while [[ "${next_url}" != "null" ]]; do
  echo "Page: $next_url"
  stack_app_guids=$(cf curl ${next_url} | jq -r '.resources[] | select(.lifecycle.data.stack == '\"$desiredStack\"')'.guid)
  for app_guid in $stack_app_guids; do
    echo
    cf curl /v3/apps/$app_guid | jq -r '[.guid, .name, .state, .lifecycle.data.buildpacks[], .lifecycle.data.stack, .relationships.space.data.guid] | @tsv'
    read -p "Are you sure to stop above app (AppGuid, Name, State, Buildpacks, Stack, SpaceGuid)? [yY/any other char for no]: " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      echo "Stopping app $app_guid"
      cf curl -X POST /v3/apps/$app_guid/actions/stop | jq -r '[.state, .updated_at] | @tsv'
    else
      echo "Nope, continue..."
    fi

  done
  next_url=$(cf curl ${next_url} | jq -r -c ".pagination.next.href" | sed 's/.*.com//;s/.*.cn//')
done
