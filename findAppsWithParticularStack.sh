#!/bin/sh

desiredStack=cflinuxfs2
echo "Getting all apps for stack ${desiredStack}, GUID: $(cf curl /v3/stacks | jq '.resources[] | select (.name == '\"$desiredStack\"')'.guid)"

next_url="/v3/apps"
while [[ "${next_url}" != "null" ]]; do
  echo "Page: ${next_url}"
  cf curl ${next_url} | jq -r '.resources[] | select(.lifecycle.data.stack == '\"$desiredStack\"') | [.name,.guid] | @tsv'
  next_url=$(cf curl ${next_url} | jq -r -c ".pagination.next.href" | sed 's/.*.com//;s/.*.cn//')
done