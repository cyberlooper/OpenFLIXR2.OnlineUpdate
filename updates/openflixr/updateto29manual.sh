#!/bin/bash
THISUSER=$(whoami)
    if [ $THISUSER != 'root' ]
        then
            echo 'You must use sudo to run this script, sorry!'
           exit 1
    fi

exec 1> >(tee -a /var/log/openflixrupdate/updateto29manual.log) 2>&1
TODAY=$(date)
echo "-----------------------------------------------------"
echo "Date:          $TODAY"
echo "-----------------------------------------------------"

## OpenFLIXR Update version 2.9 manual

# free memory
service monit stop
service plexmediaserver stop
service plexpy stop
service sickrage stop
service couchpotato stop
service ubooquity stop
service nzbhydra stop
service nzbhydra2 stop
service nzbget stop
service radarr stop
service sonarr stop
service lidarr stop
service mysql stop
service plexrequestsnet stop
service docker stop
service sabnzbdplus stop
service netdata stop
service syncthing@openflixr stop
service home-assistant stop
service headphones stop
service mylar stop
service htpcmanager stop
service autosub stop
service lazylibrarian stop
service qbittorrent stop
service logio stop
service jackett stop
service mopidy stop
service php7.0-fpm stop
service webmin stop
killall python
killall Ombi

# backport fixes
mv /etc/nginx/sites-enabled/reverse /opt/openflixr
service nginx restart

## Upgrade Ubuntu to 18.04 LTS - Pass 1

# Wait for apt release
while [ "x$(lsof /var/lib/dpkg/lock)" != "x" ] ; do
    echo "OpenFLIXR update is waiting for apt release, this can take up to an hour or more"
    sleep 10
done

rm /etc/apt/sources.list.d/nijel-ubuntu-phpmyadmin-xenial*
rm /etc/apt/sources.list.d/nginx-ubuntu-development-xenial*
add-apt-repository ppa:teejee2008/ppa -y
echo "deb [arch=amd64,armhf] http://repo.ombi.turd.me/stable/ jessie main" | tee "/etc/apt/sources.list.d/ombi.list"
wget -qO - https://repo.ombi.turd.me/pubkey.txt | apt-key add -
echo "DPkg::options { "--force-confdef"; "--force-confnew"; }" >/etc/apt/apt.conf.d/local
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get update -y --assume-no
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get purge apache2 apache2-bin apache2-data php* -y
add-apt-repository ppa:ondrej/php -y
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get install --reinstall libgpm2 -y
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail dpkg --configure -a --force-confdef --force-confold
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get install -f -y --assume-no
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail dpkg --configure -a --force-confdef --force-confold
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --with-new-pkgs upgrade
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail dpkg --configure -a --force-confdef --force-confold
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get dist-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get install -y jq vnstat socat dns-root-data shellinabox ombi sshfs vim python-cairocffi python3-cairocffi libzip5 python-cffi python-pycparser python-ply ukuu python-dnspython update-manager-core php7.3 php7.3-common php7.3-cli php7.3-bcmath php7.3-bz2 php7.3-curl php7.3-gd php7.3-intl php7.3-json php7.3-mbstring php7.3-readline php7.3-xml php7.3-zip php7.3-fpm
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get autoremove --purge -y

## Upgrade Ubuntu to 18.04 LTS - Pass 2
# free memory because monit gets updated and started
service monit stop
service plexmediaserver stop
service plexpy stop
service sickrage stop
service couchpotato stop
service ubooquity stop
service nzbhydra stop
service nzbhydra2 stop
service nzbget stop
service radarr stop
service sonarr stop
service lidarr stop
service mysql stop
service plexrequestsnet stop
service docker stop
service sabnzbdplus stop
service netdata stop
service syncthing@openflixr stop
service home-assistant stop
service headphones stop
service mylar stop
service htpcmanager stop
service autosub stop
service lazylibrarian stop
service qbittorrent stop
service logio stop
service jackett stop
service mopidy stop
service php7.0-fpm stop
service webmin stop
killall Ombi

sed -i 's/Prompt=never/Prompt=lts/g' /etc/update-manager/release-upgrades
locale-gen en_US.UTF-8
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get update -y --assume-no
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail dpkg --configure -a --force-confdef --force-confold
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get install -f -y --assume-no
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail dpkg --configure -a --force-confdef --force-confold
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --with-new-pkgs upgrade
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail dpkg --configure -a --force-confdef --force-confold
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get dist-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail dpkg --configure -a --force-confdef --force-confold
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get autoremove --purge -y
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail do-release-upgrade -f DistUpgradeViewNonInteractive
# free memory because monit gets updated and started
service monit stop
service plexmediaserver stop
service plexpy stop
service sickrage stop
service couchpotato stop
service ubooquity stop
service nzbhydra stop
service nzbhydra2 stop
service nzbget stop
service radarr stop
service sonarr stop
service lidarr stop
service mysql stop
service plexrequestsnet stop
service docker stop
service sabnzbdplus stop
service netdata stop
service syncthing@openflixr stop
service home-assistant stop
service headphones stop
service mylar stop
service htpcmanager stop
service autosub stop
service lazylibrarian stop
service qbittorrent stop
service logio stop
service jackett stop
service mopidy stop
service php7.0-fpm stop
service webmin stop
killall Ombi
ukuu --install v4.19.26

## Upgrade Ubuntu to 18.04 LTS - Pass 3
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee "/etc/apt/sources.list.d/mono-official-stable.list"
add-apt-repository ppa:nginx/stable -y
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get update -y --assume-no
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail dpkg --configure -a --force-confdef --force-confold
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get install -f -y --assume-no
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail dpkg --configure -a --force-confdef --force-confold
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --with-new-pkgs upgrade
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail dpkg --configure -a --force-confdef --force-confold
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get dist-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail dpkg --configure -a --force-confdef --force-confold
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get clean -y
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get autoclean -y
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get autoremove --purge -y
sed -i 's/Prompt=lts/Prompt=never/g' /etc/update-manager/release-upgrades
ukuu --install v4.19.26

# mofo strange bug
add-apt-repository ppa:ondrej/php -y
debconf-set-selections <<< "phpmyadmin phpmyadmin/internal/skip-preseed boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect"
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean false"
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get update -y --assume-no
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --with-new-pkgs upgrade
DEBIAN_FRONTEND=noninteractive APT_LISTCHANGES_FRONTEND=mail apt-get install -y phpmyadmin debconf-utils php-mbstring php-gettext php7.3-gd php7.3-curl php7.3-mysql dbconfig-common dbconfig-mysql libjs-jquery libjs-sphinxdoc libjs-underscore php-mysql php-pear php-php-gettext php-phpseclib php-tcpdf

# ACME Shell script
git clone https://github.com/Neilpang/acme.sh.git /opt/acme
( crontab -l | grep -v -F '30 2 * * 1  /opt/letsencrypt/letsencrypt-auto renew --standalone --pre-hook "service nginx stop" --post-hook "service nginx start" >> /var/log/le-renew.log' ) | crontab -
bash /opt/acme/acme.sh --install --upgrade --auto-upgrade

# system fixes
sed -i 's/;extension=curl/extension=curl/g' /etc/php/7.3/fpm/php.ini
echo "DNSStubListener=no" >> /etc/systemd/resolved.conf
chown -R www-data: /usr/share/nginx/html/
chown -R www-data: /var/www/
echo "pm = dynamic" >> /etc/php/7.3/fpm/php-fpm.conf
echo "pm.max_children = 10" >> /etc/php/7.3/fpm/php-fpm.conf
echo "pm.min_spare_servers = 1" >> /etc/php/7.3/fpm/php-fpm.conf
echo "pm.max_spare_servers = 8" >> /etc/php/7.3/fpm/php-fpm.conf
echo "pm.max_requests = 250" >> /etc/php/7.3/fpm/php-fpm.conf
echo "pm.start_servers = 4" >> /etc/php/7.3/fpm/php-fpm.conf

# app fixes
sed -i 's/ExecStart.*/ExecStart=\/usr\/bin\/python2.7 \/usr\/local\/bin\/mopidy --config \/usr\/share\/mopidy\/conf.d:\/etc\/mopidy\/mopidy.conf/' /lib/systemd/system/mopidy.service
systemctl daemon-reload

## shellinabox
sed -i 's/SHELLINABOX_ARGS.*/SHELLINABOX_ARGS="--no-beep --localhost-only --disable-ssl --css \/opt\/update\/updates\/openflixr\/shellinabox.css"/' /etc/default/shellinabox
