#!/bin/bash
exec 1> >(tee -a /var/log/letsencrypt.log) 2>&1
TODAY=$(date)
echo "-----------------------------------------------------"
echo "Date:          $TODAY"
echo "-----------------------------------------------------"

THISUSER=$(whoami)
    if [ $THISUSER != 'root' ]
        then
            echo 'You must use sudo to run this script, sorry!'
            exit  1
    fi

domainname=$(crudini --get /usr/share/nginx/html/setup/config.ini access domainname)
letsencrypt=$(crudini --get /usr/share/nginx/html/setup/config.ini access letsencrypt)

    if [ "$letsencrypt" == 'on' ]
        then
openssl dhparam -out /etc/nginx/dhparam.pem 2048
bash /opt/acme/acme.sh --issue --alpn -d "$domainname" -d www."$domainname" --keylength ec-384 --ocsp-must-staple --cert-home /etc/letsencrypt/live --pre-hook "service monit stop && service nginx stop" --post-hook "service monit start && service nginx start"
else
echo "Let's Encrypt is disabled"
fi
