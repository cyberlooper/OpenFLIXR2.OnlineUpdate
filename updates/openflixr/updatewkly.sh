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

## Jackett
echo ""
echo "Jackett:"
service jackett stop
cd /tmp/
rm Jackett.Binaries.Mono.tar.gz* 2> /dev/null
jackettver=$(wget -q https://github.com/Jackett/Jackett/releases/latest -O - | grep -E \/tag\/ | awk -F "[><]" '{print $3}' | sed -n '2p')
wget -q https://github.com/Jackett/Jackett/releases/download/$jackettver/Jackett.Binaries.Mono.tar.gz
tar -xvf Jackett*
sudo cp -r -u Jackett*/* /opt/jackett/
rm -rf Jackett*/
rm Jackett.Binaries.Mono.tar.gz*
service jackett start

## PlexRequests
echo ""
echo "Plexrequests.net:"
service plexrequestsnet stop
cd /tmp/
plexrequestsver=$(wget -q https://github.com/tidusjar/Ombi/releases/latest -O - | grep -E \/tag\/ | awk -F "[<>]" '{print $3}' | cut -c 6- | sed -n '2p')
wget -q https://github.com/tidusjar/Ombi/releases/download/$plexrequestsver/Ombi.zip
unzip Ombi.zip
rm Ombi.zip
sudo cp -r -u Release/* /opt/plexrequest.net/
rm -rf Release/
service plexrequestsnet start

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

## Plex Media Server
echo ""
echo "Plex Media Server:"
cd /opt/plexupdate
bash plexupdate.sh -p
dpkg -i /tmp/plexmediaserver*.deb 2> /dev/null
rm /tmp/plexmediaserver*

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

## Update everything else
echo ""
echo "updateof:"
cd /opt/openflixr
bash updateof
echo ""
echo "Node / PIP / NPM:"
cd /usr/lib/node_modules
sudo -H npm install npm@latest
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
updateopenflixr
