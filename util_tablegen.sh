#!/bin/bash


# Run and time the table orc generation without baby sitting the scripts
# Use: nohup


# Write the benchmark command you want
BENCHMARK="./tpcds-setup.sh"
# scale ~GB
SCALE=10
# Name of clock file
CLOCK_FILE="aaa_clocktime.txt"


if [[ -f $CLOCK_FILE ]]; then
    rm $CLOCK_FILE
    echo "Old clock removed"
fi
echo "Created new clock"
echo "Table gen time for "$BENCHMARK" "$SCALE > $CLOCK_FILE

# The command string
COMMAND=$BENCHMARK" "$SCALE

echo "Start time" >> $CLOCK_FILE
TZ='America/Los_Angeles' date >> $CLOCK_FILE
$COMMAND
echo "End time" >> $CLOCK_FILE
TZ='America/Los_Angeles' date >> $CLOCK_FILE
