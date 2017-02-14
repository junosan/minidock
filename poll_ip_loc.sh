#!/bin/bash

# - Poll freegeoip.net and store the 2-character country code in /tmp/
# - The server takes a bit of time to respond, so we put this in the
#   background to make the main loop of minidock.sh more responsive
# - Make sure not to launch multiple instances

SCRIPT_PATH=${0%/*}

# safe polling interval considering delay for 10000 queries per hour limit
while sleep .3; do
    ip_location=`curl -m3 -s freegeoip.net/xml/ | grep 'CountryCode' | sed -e $'s/\t//' -e 's/<[^>]*>//g'`
    if [ -z $ip_location ]; then
        ip_location='nc' # no connection
    else
        ip_location=`echo $ip_location | awk '{print tolower($0)}'`
    fi

    echo -n ${ip_location::2} > /tmp/poll_ip_loc.log
done
