#!/bin/bash
# save this file to ${CLASH_HOME}/start-clash.sh

# save pid file
echo $$ > ${CLASH_HOME}/clash.pid

diff --ignore-matching-lines "=i-g-n-o-r-e=" ${CLASH_HOME}/config.yaml <(curl -L -s ${CLASH_URL})
if [ "$?" == 0 ]
then
    /usr/bin/bypass-proxy /usr/bin/clash -d /srv/clash
else
    TIME=`date '+%Y-%m-%d_%H:%M:%S'`
    cp ${CLASH_HOME}/config.yaml "${CLASH_HOME}/config.yaml.bak${TIME}"
    curl -L -o ${CLASH_HOME}/config.yaml ${CLASH_URL}
    /usr/bin/bypass-proxy /usr/bin/clash -d /srv/clash
fi
