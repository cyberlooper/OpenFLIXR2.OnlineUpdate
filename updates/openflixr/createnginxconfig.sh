#!/bin/bash
service monit stop
service nginx stop
mkdir /opt/openflixr/nginx
mv /etc/nginx/sites-enabled/reverse /opt/openflixr
cat /opt/update/updates/nginx/start.nginx.core >/etc/nginx/sites-enabled/openflixr.conf
cat /opt/update/updates/nginx/*.coreblock >>/etc/nginx/sites-enabled/openflixr.conf
cp /opt/update/updates/nginx/*.sslblock /opt/openflixr/nginx

domainname=$(crudini --get /usr/share/nginx/html/setup/config.ini access domainname)
letsencrypt=$(crudini --get /usr/share/nginx/html/setup/config.ini access letsencrypt)

if [ "$letsencrypt" == 'on' ]
    then
sed -i 's/^server_name.*/server_name openflixr '$domainname' www.'$domainname';  #donotremove_domainname/' /etc/nginx/sites-enabled/openflixr.conf
sed -i 's/^.*#ssl_port_config/listen 443 ssl http2;	#ssl_port_config/' /opt/openflixr/nginx/ssl.nginx.sslblock
sed -i 's/^.*#donotremove_certificatepath/ssl_certificate \/etc\/letsencrypt\/live\/'$domainname'_ecc\/fullchain.cer; #donotremove_certificatepath/' /opt/openflixr/nginx/ssl.nginx.sslblock
sed -i 's/^.*#donotremove_certificatekeypath/ssl_certificate_key \/etc\/letsencrypt\/live\/'$domainname'_ecc\/'$domainname'.key; #donotremove_certificatekeypath/' /opt/openflixr/nginx/ssl.nginx.sslblock
sed -i 's/^.*#donotremove_trustedcertificatepath/ssl_trusted_certificate \/etc\/letsencrypt\/live\/'$domainname'_ecc\/fullchain.cer; #donotremove_trustedcertificatepath/' /opt/openflixr/nginx/ssl.nginx.sslblock
    else
echo "Do not add SSL part, Let's Encrypt is disabled"
fi

cat /opt/openflixr/nginx/*.sslblock >>/etc/nginx/sites-enabled/openflixr.conf
cat /opt/update/updates/nginx/*.block >>/etc/nginx/sites-enabled/openflixr.conf
cat /opt/openflixr/nginx/*.block >>/etc/nginx/sites-enabled/openflixr.conf
cat /opt/update/updates/nginx/end.nginx.core >>/etc/nginx/sites-enabled/openflixr.conf
service nginx start
service monit start
