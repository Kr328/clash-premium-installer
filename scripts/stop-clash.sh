#!/bin/bash
# save this file to ${CLASH_HOME}/stop-clash.sh

# read pid file
PID=`cat ${CLASH_HOME}/clash.pid`
kill -9 ${PID}
rm ${CLASH_HOME}/clash.pid
