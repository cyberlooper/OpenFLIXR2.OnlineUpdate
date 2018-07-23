#!/bin/bash
tail -f /var/log/updateplex.log /var/log/onlineupdate.log /var/log/updateof.log /var/log/updatewkly.log /var/log/openflixrupdate/* /var/log/createdirs.log | rtail --port 4321 --id "1 OpenFLIXR" --mute &
tail -f /var/log/nginx/error.log /var/log/syslog /var/log/kern.log | rtail --port 4321 --id "2 System" --mute &
tail -f /var/log/auth.log | rtail --port 4321 --id "6 Authentication" --mute &
tail -f /var/log/monit.log | rtail --port 4321 --id "4 Monit" --mute &
tail -f /var/log/apt/* | rtail --port 4321 --id "3 OS Updates" --mute &
tail -f /var/log/letsencrypt.log /var/log/letsencrypt/* /var/log/le-renew.log | rtail --port 4321 --id "5 Let's Encrypt" --mute &
rtail-server --web-port 4321 --udp-port 4321 &
