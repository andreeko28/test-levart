#!/bin/bash

# set the directory containing the log files
LOG_DIR=/path/to/log/directory

# set the current time in epoch format
CURRENT_TIME=$(date +%s)

# set the time 10 minutes ago in epoch format
TIME_10_MIN_AGO=$((CURRENT_TIME - 600))

# loop through each log file in the directory
for LOG_FILE in $LOG_DIR/*.log; do

  # count the number of HTTP 500 errors in the last 10 minutes
  COUNT=$(grep "HTTP/1.1\" 500" $LOG_FILE | awk -v start="$TIME_10_MIN_AGO" -v end="$CURRENT_TIME" '$4 >= start && $4 <= end' | wc -l)

  # output the count and log file name
  echo "There were $COUNT HTTP 500 errors in $LOG_FILE in the last 10 minutes."

done