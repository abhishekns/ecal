#!/bin/bash

# Set network_enabled = true in ecal.ini.
# You can omit this, if you only need local communication.
PREFIX=/usr/local
NAME=$1
if [ -z "${NAME}" ]; then
   NAME=sender
fi
MODE="local"
if [ "x${MODE}" == "xlocal" ]; then
        echo "nothing to do in local mode..."
else
        awk -F"=" '/^network_enabled/{$2="= true"}1' ${PREFIX}/etc/ecal/ecal.ini > ${PREFIX}/etc/ecal/ecal.tmp && \
                rm ${PREFIX}/etc/ecal/ecal.ini && \
                mv ${PREFIX}/etc/ecal/ecal.tmp ${PREFIX}/etc/ecal/ecal.ini
        rm -f /logs/${NAME}.log
fi

${PREFIX}/bin/ecal_sample_${NAME} | tee /logs/${NAME}.log
#sleep 60
