filename="service_instance_guids"
service="<service-name>"

service_guid=$(cf curl /v2/services | jq -r '.resources[] | select (.entity.label == '\"$service\"')'.metadata.guid)

echo "Searching service instances for service $service ($service_guid) writing into $filename"

#iterating over all service instances for service_guid
next_url="/v2/service_instances"
while [[ "${next_url}" != "null" ]]; do
   service_instance_guids=$(cf curl ${next_url} | jq -r '.resources[] | select (.entity.service_guid == '\"$service_guid\"')'.metadata.guid)
   for service_instance_guid in $service_instance_guids; do
      echo $service_instance_guid
      echo $service_instance_guid >> $filename
   done
   next_url=$(cf curl ${next_url} | jq -r -c ".next_url")
done
