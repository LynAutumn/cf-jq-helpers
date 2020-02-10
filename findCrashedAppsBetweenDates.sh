#!/bin/sh

#Replace start and end date in correct format; for tdays date use: startDate=$(date +%FT00:00:00Z)
startDate="2019-12-09T12:19:39Z"
endDate="2019-12-10T04:18:11Z"
next_url="/v2/events?q=type:app.crash"

echo "Search for crashed Apps between $startDate and $endDate"

while [[ "${next_url}" != "null" ]]; do
  echo "Page: $next_url"
  cf curl ${next_url} | jq -r '.resources[] | select(.entity.timestamp >= '\"$startDate\"' and .entity.timestamp <= '\"$endDate\"') | [.entity.actor, .entity.timestamp, .entity.actor_name] | @tsv'
  next_url=$(cf curl ${next_url} | jq -r -c ".next_url")
done
