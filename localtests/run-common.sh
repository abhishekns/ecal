#!/bin/bash

# Set network_enabled = true in ecal.ini.
# You can omit this, if you only need local communication.
PREFIX=/usr/local
NAME=$1
if [ -z "${NAME}" ]; then
   NAME=sender
fi

# set to local if running all containers in one pc.
MODE="local"

if [ "x${MODE}" == "xlocal" ]; then
        echo "no n/w settings..."
else
        awk -F"=" '/^network_enabled/{$2="= true"}1' ${PREFIX}/etc/ecal/ecal.ini > ${PREFIX}/etc/ecal/ecal.tmp && \
                rm ${PREFIX}/etc/ecal/ecal.ini && \
                mv ${PREFIX}/etc/ecal/ecal.tmp ${PREFIX}/etc/ecal/ecal.ini
        rm -f /logs/${NAME}.log
fi
if [ "x${NAME}" == "xreceiver" ]
    ${PREFIX}/bin/ecal_sample_${NAME} | tee /logs/${NAME}.log
else
    ${PREFIX}/bin/ecal_sample_${NAME} > /logs/${NAME}.log &
fi
