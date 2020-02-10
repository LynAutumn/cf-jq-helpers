#!/bin/sh

find_user=<user-name>
next_url="/v2/users"

while [[ "${next_url}" != "null" ]]; do
  user_id=$(cf curl ${next_url} | jq -r '.resources[] | select(.entity.username == '\"$find_user\"')'.metadata.guid)
  if [[ $user_id != "" ]]; then
    echo "User $find_user with GUID: $user_id"
    break
  fi
  next_url=$(cf curl ${next_url} | jq -r -c ".next_url")
done


echo "Organizations for user $find_user: $user_id"
next_url_orgs="/v2/users/$user_id/organizations"

while [[ "${next_url_orgs}" != "null" ]]; do
  cf curl ${next_url_orgs} | jq -r '.resources[] | [.metadata.url, .entity.name] | @tsv'
  next_url_orgs=$(cf curl ${next_url_orgs} | jq -r -c ".next_url")
done


echo "Spaces for user $find_user: $user_id"
next_url_spaces="/v2/users/$user_id/spaces"

while [[ "${next_url_spaces}" != "null" ]]; do
  cf curl ${next_url_spaces} | jq -r '.resources[] | [.metadata.url, .entity.name, .entity.organization_url] | @tsv'
  next_url_spaces=$(cf curl ${next_url_spaces} | jq -r -c ".next_url")
done