#!/bin/bash

# NOT MEANT TO BE RUN STAND ALONE
# Takes in:
# 1. Beeline command to run
# 2. Log path for beeline to output
# 3. Query Number
# 4. CSV name

INTERNAL_BEELINE_COMMAND=$1
INTERNAL_LOG_PATH=$2
INTERNAL_QID=$3
INTERNAL_CSV=$4

# Beeline command to execute
START_TIME="`date +%s`"
$INTERNAL_BEELINE_COMMAND &>> $INTERNAL_LOG_PATH
RETURN_VAL=$?
END_TIME="`date +%s`"

if [[ $RETURN_VAL = 0 ]]; then
    status="SUCCESS"
else
    status="FAIL"
fi

# calculate time
secs_elapsed="$(($END_TIME - $START_TIME))"
# record data
echo $INTERNAL_QID, $secs_elapsed, $status >> $INTERNAL_CSV
# report status to terminal
echo "query$INTERNAL_QID: $status"
