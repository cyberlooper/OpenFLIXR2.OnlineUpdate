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
apt-get autoclean -y
apt-get autoremove --purge -y
apt-get update -y
apt-get install -f -y --assume-no
apt-get update -y --assume-no
DEBIAN_FRONTEND=noninteractive apt-get -y --with-new-pkgs upgrade
cp /etc/apt/apt.conf.d/50unattended-upgrades.ucftmp /etc/apt/apt.conf.d/50unattended-upgrades
rm /etc/apt/apt.conf.d/50unattended-upgrades.ucftmp
dpkg --configure -a

## Spotweb
echo ""
echo "Spotweb:"
cd /tmp/
wget https://github.com/spotweb/spotweb/tarball/master
tar -xvzf master
cp -r -u spotweb-spotweb*/* /var/www/spotweb/
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
currentver=$(mono /opt/jackett/JackettConsole.exe --version | awk -F "[ .]" '{print $2 "." $3 "." $4}')
link='https://github.com'$link
# Sanity check and write some stuff to the log so we know what happened if it goes wrong
if [ ! $currentver ]; then
        echo "Could not get currentver - assuming v0.0.0.0"
        currentver='v0.0.0.0'
else
        echo currentver = $currentver
fi
if [ ! $latestver ]; then
        echo "Could not get latestver - assuming same as currentver to avoid breaking stuff"
        latestver=$currentver
else
        echo latestver = $latestver
fi
echo $currentver | grep -i error
if [ $? == 0 ]; then # the currentversion isn't empty but threw an error
        echo "currentver is an error string - assuming v0.0.0.0"
        currentver='v0.0.0.0'
else
        echo currentver = $currentver
fi

if [ $currentver != $latestver ]
then
  echo "Jackett needs updating"
  echo "download link = $link"
  service jackett stop
  cd /tmp/
  rm Jackett.Binaries.Mono.tar.gz* 2> /dev/null
  wget -q $link || echo 'Download failed!'
  tar -xvf Jackett*
  cp -r -u Jackett*/* /opt/jackett/
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

## Lidarr
echo ""
echo "Lidarr:"
# Get Lidarr state so we can return it to the same
wasactive=$(systemctl is-active lidarr)
# GitHub's web page format has changed. Just grab the download link and work with that instead of parsing the version title string.
link=$(wget -q https://github.com/lidarr/Lidarr/releases/latest -O - | grep -i href | grep -i linux.tar.gz | awk -F "[\"]" '{print $2}')
latestver=$(echo $link | awk -F "[\/]" '{print $6}')
latestverurl=$(echo $link | awk -F "[\/]" '{print $1"/"$2"/"$3"/"$4"/"$5"/"$6"/"$7}')
link='https://github.com'$latestverurl
# Write some stuff to the log so we know what happened if it goes wrong
echo latestver = $latestver
  echo "Lidarr needs updating"
  echo "download link = $link"
  service lidarr stop
  cd /tmp/
  rm Lidarr.develop.* 2> /dev/null
  wget -q $link || echo 'Download failed!'
  tar -xvf Lidarr*
  cp -r -u Lidarr*/* /opt/Lidarr/
  rm -rf Lidarr*/
  rm Lidarr.develop.*
  if [ $wasactive == "active" ]
  then
    echo "Starting Lidarr after update"
    service lidarr start
  else
    echo "Lidarr was not running before, so not starting it now"
  fi

## Radarr
echo ""
echo "Radarr:"
service radarr stop
cd /tmp/
wget $( curl -s https://api.github.com/repos/Radarr/Radarr/releases | grep linux.tar.gz | grep browser_download_url | head -1 | cut -d \" -f 4 )
tar -xvzf Radarr.develop.*.linux.tar.gz
rm Radarr.develop.*.linux.tar.gz
cp -r -u Radarr/* /opt/Radarr/
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
git pull
bash netdata-updater.sh

## Update blocklist
echo ""
echo "IP Blocklist:"
bash /opt/openflixr/blocklist.sh

## Pi-hole
echo ""
echo "Pi-hole:"
pihole -up
systemctl disable lighttpd.service

## Latest page imdb grabber
wget https://raw.githubusercontent.com/FabianBeiner/PHP-IMDB-Grabber/master/imdb.class.php -O /usr/share/nginx/html/latest/inc/imdb_class.php
chmod 755 /usr/share/nginx/html/latest/inc/imdb_class.php
chown www-data:www-data /usr/share/nginx/html/latest/inc/*

## Grav
chown www-data:www-data -R /usr/share/nginx/html/user
chown www-data:www-data -R /usr/share/nginx/html/cache
chmod +777 -R /usr/share/nginx/html/cache
cd /usr/share/nginx/html
bin/gpm selfupgrade -f -y
bin/gpm update -f -y

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
