#!/bin/bash

# Run and time the benchmark without baby sitting the scripts
# Use: nohup


if [[ "$1" =~ ^[0-9]+$ && "$1" -gt "1" ]]; then
    # query file name
    QUERY_BASE_NAME="sample-queries-tpcds/query"
    QUERY_FILE_EXT=".sql"
    # settings file location
    SETTINGS_PATH="settings.sql"


    # scale ~GB
    SCALE="$1"
    # report name
    REPORT_NAME="time_elapsed_tpcds"
    # database name
    DATABASE="tpcds_bin_partitioned_orc_"$SCALE
    # hostname
    HOSTNAME=`hostname`
    # name of clock file
    CLOCK_FILE="aaa_clocktime.txt"


    if [[ -f $CLOCK_FILE ]]; then
        rm $CLOCK_FILE
        echo "Old clock removed"
    fi
    echo "Created new clock"
    echo "Run queries for TPC-DS at scale "$SCALE > $CLOCK_FILE
    TZ='America/Los_Angeles' date >> $CLOCK_FILE

    # generate time report
    rm $REPORT_NAME*".csv"
    echo "Old report removed"
    echo "query #", "secs elapsed", "status" > $REPORT_NAME".csv"
    echo "New report generated"

    # remove old llapio_summary
    rm "llapio_summary"*".csv"
    echo "Old llapio_summary*.csv removed"

    # clear and make new log directory
    if [[ -d log_query/ ]]; then
        rm -r log_query/
        echo "Old logs removed"
    fi
    mkdir log_query/
    echo "Log folder generated"

    # range of queries
    START=1
    END=99
    for (( i = $START; i <= $END; i++ )); do
        query_path=($QUERY_BASE_NAME$i$QUERY_FILE_EXT)
        
        BEELINE_COMMAND="beeline -u jdbc:hive2://$HOSTNAME:10001/$DATABASE;transportMode=http -i $SETTINGS_PATH -f $query_path"
        LOG_PATH="log_query/logquery$i.txt"

        sh util_internalRunQuery.sh "$BEELINE_COMMAND" "$LOG_PATH" "$i" "$REPORT_NAME.csv"
        
    done

    echo "Finished" >> $CLOCK_FILE
    TZ='America/Los_Angeles' date >> $CLOCK_FILE

    python3 parselog.py

    ID=`TZ='America/Los_Angeles' date +"%m.%d.%Y-%H.%M"`
    mv $REPORT_NAME".csv" $REPORT_NAME$ID".csv"
    zip "tpcds-"$SCALE"GB-"$ID".zip" log_query/* $REPORT_NAME$ID".csv" "llapio_summary"*".csv"
else
    echo "Invalid entry. Scale must also be greater than 1."
fi
