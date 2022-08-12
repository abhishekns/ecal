#!/bin/bash

# Set network_enabled = true in ecal.ini.
# You can omit this, if you only need local communication.
PREFIX=/usr/local
awk -F"=" '/^network_enabled/{$2="= true"}1' ${PREFIX}/etc/ecal/ecal.ini > ${PREFIX}/etc/ecal/ecal.tmp && \
        rm ${PREFIX}/etc/ecal/ecal.ini && \
        mv ${PREFIX}/etc/ecal/ecal.tmp ${PREFIX}/etc/ecal/ecal.ini
rm -f /logs/subscriber.log

${PREFIX}/bin/ecal_sample_latency_rec | tee /logs/subscriber.log  
#sleep 60
