#!/bin/bash


# Run and time the benchmark without baby sitting the scripts
# Use: nohup


# scale ~GB
SCALE=10
# query file name
QUERY_BASE_NAME="sample-queries-tpch/tpch_query"
QUERY_FILE_EXT=".sql"
# settings file location
SETTINGS_PATH="settings.sql"

# report name
REPORT_NAME="time_elapsed_tpch.csv"
# database name
DATABASE="tpch_flat_orc_"$SCALE
# hostname
HOSTNAME=`hostname`
# name of clock file
CLOCK_FILE="aaa_clocktime.txt"


if [[ -f $CLOCK_FILE ]]; then
    rm $CLOCK_FILE
    echo "Old clock removed"
fi
echo "Created new clock"
echo "Run queries for TPC-H at scale "$SCALE > $CLOCK_FILE
TZ='America/Los_Angeles' date >> $CLOCK_FILE

# generate time report
echo "query #", "start time", "end time", "secs elapsed", "status" >> $REPORT_NAME
echo "New report generated. Old report was removed"

# clear and make new log directory
if [[ -d log_query/ ]]; then
    rm -r log_query/
    echo "Old logs removed"
fi
mkdir log_query/
echo "Log folder generated"

# range of queries
START=1
END=22
for (( i = $START; i <= $END; i++ )); do
    query_path=($QUERY_BASE_NAME$i$QUERY_FILE_EXT)
    
    
    # run the query
    START_TIME="`date +%s`"
    beeline -u "jdbc:hive2://"$HOSTNAME":10001/"$DATABASE";transportMode=http" -i $SETTINGS_PATH -f $query_path &>> "log_query/logquery"$i".txt"
    RETURN_VAL=$?
    END_TIME="`date +%s`"


    # read exit code
    if [[ $RETURN_VAL = 0 ]]; then
        status="SUCCESS"
    else
        status="FAIL"
    fi
    # calculate time
    secs_elapsed="$(($END_TIME - $START_TIME))"
    # record data
    echo $i, $START_TIME, $END_TIME, $secs_elapsed, $status >> $REPORT_NAME
    # report status to terminal
    echo "query"$i": "$status
done

echo "Finished" >> $CLOCK_FILE
TZ='America/Los_Angeles' date >> $CLOCK_FILE
