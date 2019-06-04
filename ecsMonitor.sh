#!/bin/bash
#ecsMonitor.sh: a script to read container stats from docker api and push the info to cloudwatch
#script should be executed by cron
#requires an IAM role to already be configured to allow cloudwatch pushes from the ec2 host instance

mkdir -p /etc/ecsMonitor/data


#test if docker is running
if /sbin/service docker status | grep running; then
  INSTANCEJSON=$(curl -s --unix-socket /var/run/docker.sock http::/containers/json )
  INSTANCELIST=$(jq -e -r '.[].Id' <<< "$INSTANCEJSON")
  CLUSTER=$(sed s'/ECS_CLUSTER=//' /etc/ecs/ecs.config)
  COUNTER=0

  while IFS= read -r INSTANCE
  do
    STATSJSON=$( curl -s --unix-socket /var/run/docker.sock "http::/containers/$INSTANCE/stats?stream=0")
    NAME=$(jq -e -r .[$COUNTER].Names <<< $INSTANCEJSON | tr -d '[]"/' | tr -d '[:space:]')


    #Accumulate MEMORY metrics
    MEMUSE=$(jq -e -r '.memory_stats.usage' <<< "$STATSJSON")
    MEMMAX=$(jq -e -r '.memory_stats.limit' <<< "$STATSJSON")
    MEM=$(echo "scale = 3; ($MEMUSE / $MEMMAX)" | bc)
    MEMPCT=$(echo "($MEM * 100)" | bc)
    MEMKB=$(echo "($MEMUSE / 1024)" | bc)

    #Accumulate CPU metrics and calculate percentage
    CPUPERCENT=0
    if [ -f "/etc/ecsMonitor/data/$NAME" ]; then
      CPUPREVIOUS=`cat "/etc/ecsMonitor/data/$NAME"`
      CPUCHECK=1
    else
      CPUPREVIOUS=0
      CPUCHECK=0
    fi

    CPUUSAGE=$(jq -e -r '.cpu_stats.cpu_usage.total_usage' <<< "$STATSJSON")
    CPUDELTA="$(($CPUUSAGE-$CPUPREVIOUS))"
    echo $CPUUSAGE > "/etc/ecsMonitor/data/$NAME"
    echo $CPUSYSTEM > /etc/ecsMonitor/data/system

    if [ $NAME = "ecs-agent" ]; then
          continue;
        fi
        CONTAINER=$(echo -e container=${NAME})
    aws cloudwatch put-metric-data --metric-name "ContainerMemory" --namespace $CLUSTER --unit Kilobytes --value $MEMKB --dimensions $CONTAINER
    if [ $CPUCHECK -eq "1" ]; then
      aws cloudwatch put-metric-data --metric-name "ContainerCpu" --namespace $CLUSTER --unit Count --value $CPUDELTA --dimensions $CONTAINER
    fi


    COUNTER=$((COUNTER+1))

  done <<< "$INSTANCELIST"
fi
