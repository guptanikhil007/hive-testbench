#!/bin/bash

INTERNAL_DATABASE=$1
INTERNAL_SETTINGS_PATH=$2
INTERNAL_QUERYPATH=$3
INTERNAL_LOG_PATH=$4
INTERNAL_QID=$5
INTERNAL_CSV=$6
INTERNAL_QUERY_SAMPLES=$7

time_to_timeout=120m

total_query_time=0
return_val=20

# Beeline command to execute
for i in $(seq 1 "$INTERNAL_QUERY_SAMPLES")
do
  start_time=$(date +%s)
  timeout $time_to_timeout beeline -u "jdbc:hive2://hive-interactive:10001/$INTERNAL_DATABASE;transportMode=http" -i "$INTERNAL_SETTINGS_PATH" -f "$INTERNAL_QUERYPATH" &>> "$INTERNAL_LOG_PATH"
  return_val=$?
  end_time=$(date +%s)
  if [[ $return_val != 0 ]]; then
    break
  fi
  secs_elapsed="$((end_time - start_time))"
  echo "query$INTERNAL_QID: Run $i SUCCESS in $secs_elapsed seconds"
  echo "${INTERNAL_QID}.${i}, $secs_elapsed, SUCCESS" >> "$INTERNAL_CSV"
  total_query_time=$((total_query_time + secs_elapsed))
done

if [[ $return_val == 0 ]]; then
  avg_query_time=$((total_query_time / INTERNAL_QUERY_SAMPLES))
  echo "$INTERNAL_QID, $avg_query_time, SUCCESS" >> "$INTERNAL_CSV"
else
  echo "$INTERNAL_QID, , FAILURE" >> "$INTERNAL_CSV"
  echo "query$INTERNAL_QID: FAILURE"
  echo "Status code was: $return_val"
fi

# Misc recovery for system
sleep 5
