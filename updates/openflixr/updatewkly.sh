#!/bin/bash
THISUSER=$(whoami)
    if [ $THISUSER != 'root' ]
        then
            echo 'You must use sudo to run this script, sorry!'
            exit 1
    fi

exec 1> >(tee -a /var/log/updatewkly.log) 2>&1
TODAY=$(date)
echo "-----------------------------------------------------"
echo "Date:          $TODAY"
echo "-----------------------------------------------------"

# variables
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

## System
echo ""
echo "OS update:"
apt-get clean -y
sudo apt-get autoclean -y
apt-get autoremove --purge -y
apt-get update -y
apt-get install -f -y --assume-no
apt-get update -y --assume-no
apt-get upgrade -y --assume-no
cp /etc/apt/apt.conf.d/50unattended-upgrades.ucftmp /etc/apt/apt.conf.d/50unattended-upgrades
rm /etc/apt/apt.conf.d/50unattended-upgrades.ucftmp
dpkg --configure -a

## Spotweb
echo ""
echo "Spotweb:"
cd /tmp/
wget https://github.com/spotweb/spotweb/tarball/master
tar -xvzf master
sudo cp -r -u spotweb-spotweb*/* /var/www/spotweb/
rm master
rm -rf spotweb-spotweb*/
cd /var/www/spotweb/bin/
php upgrade-db.php
chown -R www-data:www-data /var/www/spotweb

## Jackett
echo ""
echo "Jackett:"
# Get Jackett state so we can return it to the same
wasactive=$(systemctl is-active jackett)
# GitHub's web page format has changed. Just grab the download link and work with that instead of parsing the version title string.
link=$(wget -q https://github.com/Jackett/Jackett/releases/latest -O - | grep -i href | grep -i mono.tar.gz | awk -F "[\"]" '{print $2}')
latestver=$(echo $link | awk -F "[\/]" '{print $6}')
currentver=$(mono /opt/jackett/JackettConsole.exe -v | awk -F "[ .]" '{print $2 "." $3 "." $4}')
link='https://github.com'$link
# Write some stuff to the log so we know what happened if it goes wrong
echo latestver = $latestver
echo currentver = $currentver
if [ $currentver != $latestver ]
    then
        echo "Jackett needs updating"
        echo "download link = $link"
        service jackett stop
        cd /tmp/
        rm Jackett.Binaries.Mono.tar.gz* 2> /dev/null
        wget -q $link || echo 'Download failed!'
        tar -xvf Jackett*
        sudo cp -r -u Jackett*/* /opt/jackett/
        rm -rf Jackett*/
        rm Jackett.Binaries.Mono.tar.gz*
        if [ $wasactive == "active" ]
            then
                echo "Starting Jackett after update"
                service jackett start
            else
                echo "Jackett was not running before, so not starting it now"
            fi
    else
        echo "Jackett is up to date"
    fi

## Radarr
echo ""
echo "Radarr:"
service radarr stop
cd /tmp/
wget $( curl -s https://api.github.com/repos/Radarr/Radarr/releases | grep linux.tar.gz | grep browser_download_url | head -1 | cut -d \" -f 4 )
tar -xvzf Radarr.develop.*.linux.tar.gz
rm Radarr.develop.*.linux.tar.gz
sudo cp -r -u Radarr/* /opt/Radarr/
rm -rf Radarr/
service radarr start

## NZBget
echo ""
echo "NZBget:"
cd /tmp
wget https://nzbget.net/download/nzbget-latest-bin-linux.run
sh nzbget-latest-bin-linux.run --destdir /opt/nzbget

## Netdata
echo ""
echo "Netdata:"
service netdata stop
killall netdata
cd /opt/netdata.git/
git reset --hard
sudo git pull
sudo bash netdata-installer.sh --dont-wait --install /opt

##
# Update blocklist
echo ""
echo "IP Blocklist:"
bash /opt/openflixr/blocklist.sh

## Pi-hole
echo ""
echo "Pi-hole:"
pihole -up
sudo systemctl disable lighttpd.service

# Latest page imdb grabber
wget https://raw.githubusercontent.com/FabianBeiner/PHP-IMDB-Grabber/master/imdb.class.php -O /usr/share/nginx/html/latest/inc/imdb_class.php

## Update everything else
echo ""
echo "updateof:"
cd /opt/openflixr
bash updateof
echo ""
echo "Node / PIP / NPM:"
cd /usr/lib/node_modules
sudo npm install npm@latest -g
sudo -H npm install npm@latest
sudo -H npm i npm@latest -g
cd /usr/lib/node_modules/rtail
sudo -H npm update
cd /usr/lib/node_modules/npm
sudo -H npm update
sudo -H pip install --upgrade pip
sudo -H pip3 install --upgrade pip
sudo -H pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U
sudo -H pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip3 install -U

## Maintenance tasks
echo ""
echo "Cleanup:"
cd /opt/openflixr
bash cleanup.sh

echo ""
echo "Nginx fix"
mkdir /var/log/nginx

## Update OpenFLIXR Online
/usr/local/bin/updateopenflixr
