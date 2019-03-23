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

# be 100% sure pi-hole isn't shitting around
sed -i 's/nameserver.*/nameserver 8.8.8.8/' /etc/resolv.conf

# variables
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

## System
echo ""
echo "OS update:"
DEBIAN_FRONTEND=noninteractive apt-get update -y --assume-no
DEBIAN_FRONTEND=noninteractive dpkg --configure -a --force-confdef --force-confold
DEBIAN_FRONTEND=noninteractive apt-get clean -y
DEBIAN_FRONTEND=noninteractive apt-get autoclean -y
DEBIAN_FRONTEND=noninteractive apt-get install -f -y --assume-no
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --with-new-pkgs upgrade
DEBIAN_FRONTEND=noninteractive apt-get autoremove --purge -y
DEBIAN_FRONTEND=noninteractive apt-get -y --with-new-pkgs upgrade
cp /etc/apt/apt.conf.d/50unattended-upgrades.ucftmp /etc/apt/apt.conf.d/50unattended-upgrades
rm /etc/apt/apt.conf.d/50unattended-upgrades.ucftmp

## OpenFLIXR repo's
#echo ""
#echo "OpenFLIXR Wizard Update:"
#cd /usr/share/nginx/html/setup
#rm /usr/share/nginx/html/setup/.git/index.lock
#git reset --hard
#git pull
echo ""
echo "OpenFLIXR Landing Page:"
cd /usr/share/nginx/html/openflixr
git reset --hard
git pull
echo ""
echo "Set Version"
version=$(crudini --get /usr/share/nginx/html/setup/config.ini custom custom1)
sed -i 's/Version.*/Version '$version'<\/span>/' /usr/share/nginx/html/openflixr/index.html
echo ""
echo "OpenFLIXR Setup Script:"
cd /opt/OpenFLIXR2.SetupScript
git reset --hard
git pull

## Pip Apps
echo ""
echo "Home-Assistant:"
sudo -H pip3 install --upgrade homeassistant
echo ""
echo "Mopidy-Mopify:"
sudo -H pip install --upgrade Mopidy
echo ""
echo "Mopidy-Mopify:"
sudo -H pip install --upgrade Mopidy-Mopify
echo ""
echo "Mopidy-Moped:"
sudo -H pip install --upgrade Mopidy-Moped
echo ""
echo "Mopidy-Iris:"
sudo -H pip install --upgrade Mopidy-Iris
echo ""
echo "pafy:"
sudo -H pip install --upgrade pafy
echo ""
echo "Mopidy-WebSettings"
sudo -H pip install --upgrade Mopidy-WebSettings

## Git Apps
echo ""
echo "CouchPotato:"
cd /opt/CouchPotato
git fetch --all
git reset --hard origin/master
git pull origin master
/usr/sbin/service couchpotato restart
echo ""
echo "Headphones:"
cd /opt/headphones
git pull
/usr/sbin/service headphones restart
echo ""
echo "HTPC Manager:"
cd /opt/HTPCManager
git pull
/usr/sbin/service htpcmanager stop
sleep 3
/usr/sbin/service htpcmanager start
echo ""
echo "Mylar:"
cd /opt/Mylar
git pull
/usr/sbin/service mylar restart
echo ""
echo "Plexpy:"
cd /opt/plexpy
git pull
/usr/sbin/service plexpy restart
echo ""
echo "SickRage:"
cd /opt/sickrage
git fetch --all
git reset --hard origin/master
git pull origin master
echo ""
echo "Letsencrypt:"
cd /opt/letsencrypt
git reset --hard
git pull
echo ""
echo "AutoSub:"
cd /opt/autosub
git reset --hard
git pull
/usr/sbin/service autosub restart
echo ""
echo "ComicReader:"
cd /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/Plug-ins/ComicReader.bundle
git pull
echo ""
echo "PlexRequestChannel:"
cd /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/Plug-ins/PlexRequestChannel.bundle
git pull
echo ""
echo "Sub-Zero:"
cd /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/Plug-ins/
## rm -rf Sub-Zero.bundle
## git clone https://github.com/pannal/Sub-Zero.bundle
## /usr/sbin/service plexmediaserver restart
cd Sub-Zero.bundle
git pull
echo ""
echo "WebTools:"
cd /var/lib/plexmediaserver/Library/Application\ Support/Plex\ Media\ Server/Plug-ins/WebTools.bundle
git pull
echo ""
echo "Groovy:"
cd /opt/groovy
git pull
echo ""
echo "NZBhydra2:"
 wasactive=$(systemctl is-active nzbhydra2)
 link=$(wget -q https://github.com/theotherp/nzbhydra2/releases/latest -O - | grep -i href | grep -i linux.zip | awk -F "[\"]" '{print $2}')
 latestver=$(echo $link | awk -F "[\/]" '{print $6}')
 latestverurl=$(echo $link | awk -F "[\/]" '{print $1"/"$2"/"$3"/"$4"/"$5"/"$6"/"$7}')
 link='https://github.com'$latestverurl
 # Write some stuff to the log so we know what happened if it goes wrong
 echo latestver = $latestver
   echo "NZBhydra2 needs updating"
   echo "download link = $link"
   service nzbhydra2 stop
   cd /tmp/
   rm nzbhydra2* 2> /dev/null
   wget -q $link || echo 'Download failed!'
   unzip -o nzbhydra2*.zip -d /opt/nzbhydra2/
   rm nzbhydra2* 2> /dev/null
   chown openflixr: -R /opt/nzbhydra2
   if [ $wasactive == "active" ]
   then
     echo "Starting NZBhydra2 after update"
     service nzbhydra2 start
   else
     echo "NZBhydra2 was not running before, so not starting it now"
   fi
echo ""
echo "LazyLibrarian:"
cd /opt/LazyLibrarian
git reset --hard
git pull
echo ""
echo "Ubooquity Plex Theme:"
cd /opt/ubooquity/themes/plextheme
git pull
echo ""
echo "ACME Shell Script:"
cd /opt/acme
git pull
echo ""
echo "Cleanup:"
rm /usr/share/nginx/html/setup/setup.sh 2> /dev/null

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

## Jackett
echo ""
echo "Jackett:"
# Get Jackett state so we can return it to the same
wasactive=$(systemctl is-active jackett)
# GitHub's web page format has changed. Just grab the download link and work with that instead of parsing the version title string.
link=$(wget -q https://github.com/Jackett/Jackett/releases/latest -O - | grep -i href | grep -i mono.tar.gz | awk -F "[\"]" '{print $2}')
latestver=$(echo $link | awk -F "[\/]" '{print $6}')
currentver=$(mono /opt/jackett/JackettConsole.exe --version | awk -F "[ .]" '{print $2 "." $3 "." $4; exit}')
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
cd /opt/netdata.git/
git reset --hard
git pull
bash netdata-updater.sh -f --out-out-from-anonymous-statistics

## Update blocklist
echo ""
echo "IP Blocklist:"
bash /opt/openflixr/blocklist.sh

## Pi-hole
echo ""
echo "Pi-hole:"
bash -x /etc/.pihole/automated\ install/basic-install.sh --unattended
systemctl daemon-reload
systemctl disable lighttpd.service

## Latest page imdb grabber
wget https://raw.githubusercontent.com/FabianBeiner/PHP-IMDB-Grabber/master/imdb.class.php -O /usr/share/nginx/html/latest/inc/imdb_class.php

## Grav
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

## Fix Permissions
echo ""
echo "Fix Permissions:"
cd /opt/openflixr
bash fixpermissions.sh

# restore pi-hole
sed -i 's/nameserver.*/nameserver 127.0.0.1/' /etc/resolv.conf
