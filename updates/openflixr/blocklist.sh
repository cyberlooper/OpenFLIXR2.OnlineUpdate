#!/bin/bash
exec 1> >(tee -a /var/log/ipfilter.log) 2>&1
TODAY=$(date)
echo "-----------------------------------------------------"
echo "Date:          $TODAY"
echo "-----------------------------------------------------"

set -e

URLS=(
http://list.iblocklist.com/?list=bt_level1
http://list.iblocklist.com/?list=bt_level2
http://list.iblocklist.com/?list=bt_level3
http://list.iblocklist.com/?list=bt_bogon
)

wget "${URLS[@]}" -O - | gunzip | LC_ALL=C sort -u >"/opt/ipfilter/ipfilter.dat"
