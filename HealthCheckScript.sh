#!/bin/bash

CHECK_INTERVAL=10

trap TERM INT
trap TERM SIGINT

rm -f $FlagFile 2> /dev/null

echo "$(date)"
echo "Starting Docker Depencency Delays..."
echo "Requirement check interval ${CHECK_INTERVAL}s"
echo " "

if [ -n "$MIN_SYSTEM_UPTIME" ] && [ "$MIN_SYSTEM_UPTIME" -eq "$MIN_SYSTEM_UPTIME" ] 2>/dev/null; then
  echo "Checking system uptime"
  UPTIME="$(awk -F. '{print $1}' /proc/uptime)"
  while [ $UPTIME -lt $MIN_SYSTEM_UPTIME ]; do
    echo "  $UPTIME < $MIN_SYSTEM_UPTIME"
    sleep $CHECK_INTERVAL
    UPTIME="$(awk -F. '{print $1}' /proc/uptime)"
  done
  echo "System uptime requirement ($UPTIME >= $MIN_SYSTEM_UPTIME) passed!"
  echo " "
fi


if [ ! -z ${REQUIRED_FILES+x} ]; then
  IFS='|'
  REQUIRED_FILES=(${REQUIRED_FILES})
  echo "Checking existing files / directories: $REQUIRED_FILES"
  for FILE in "${REQUIRED_FILES[@]}"; do
    while [ ! -e "$FILE" ]; do
      echo "  $FILE does not exist"
      sleep $CHECK_INTERVAL
    done
    echo "  $FILE exists"
  done
  echo "FS requirements passed!"
  echo " "
fi


if [ ! -z ${REQUIRED_CONTAINER_NAMES+x} ]; then
  IFS='|'
  REQUIRED_CONTAINER_NAMES=(${REQUIRED_CONTAINER_NAMES})
  echo "Checking container names: $REQUIRED_CONTAINER_NAMES"
  for ID in "${REQUIRED_CONTAINER_NAMES[@]}"; do
    # Default to 'healthy' if container does not support HealthChecks
    HEALTH=$(docker inspect --format '{{json .State.Health.Status }}' $ID | tr -d '"' || echo "healthy")
    while [ "$HEALTH" != "healthy" ]; do
      echo "  $ID: $HEALTH"
      sleep $CHECK_INTERVAL
      HEALTH=$(docker inspect --format '{{json .State.Health.Status }}' $ID | tr -d '"' || echo "healthy")
    done
    echo "  $ID up and $HEALTH"    
  done
  echo "Docker container requirements passed!"
  echo " "
fi

echo "Healthy since: $(date +'%Y-%m-%d %H:%M:%S')" > $FlagFile

echo "Dependency checks completed succesfully!"
echo 'Going to sleep now...'
sleep infinity & wait
