#!/bin/bash

DATE=`date +%Y%m%d-%H%M%S`

# Start policy manager

mkdir -p /var/run/neat/cib/
mkdir -p /var/run/neat/pib/
python3.5 /opt/celerway/neat/policy/neatpmd \
  --sock /var/run/neat/ \
  --cib /var/run/neat/cib/ \
  --pib /var/run/neat/pib/ \
  > /monroe/results/neatpmd-${DATE}.txt 2>&1 &

# start socat proxy to dlb

socat TCP-LISTEN:88,fork,bind=172.17.0.1 TCP:127.0.0.1:88 &
 
# Start neat metadata exporter

neat-metadata-exporter --cib-socket /var/run/neat/neat_cib_socket \
  --ifname-key InterfaceName \
  > /monroe/results/metadata-exporter-${DATE}.txt 2>&1 &

# Start the proxy

export NEAT_PM_SOCKET="/var/run/neat/neat_pm_socket"
export NEAT_CIB_SOCKET="/var/run/neat/neat_cib_socket"
neat-proxy > /monroe/results/neat-proxy-${DATE}.txt 2>&1

while true; do
    sleep 15
done
