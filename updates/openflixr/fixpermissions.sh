# Change Owner
chown -R openflixr: /opt/nzbget
chown -R openflixr: /opt/nzbhydra2
chown -R openflixr: /opt/sickrage
chown -R openflixr: /opt/CouchPotato
chown -R openflixr: /opt/headphones
chown -R openflixr: /opt/HTPCManager
chown -R openflixr: /opt/plexpy
chown -R openflixr: /opt/Mylar
chown -R openflixr: /opt/Lidarr
chown -R openflixr: /opt/ubooquity
chown -R root: /opt/LazyLibrarian
chown -R root: /opt/autosub
chown -R root: /opt/Ombi
chown -R root: /opt/NzbDrone
chown -R root: /opt/jackett
chown -R root: /opt/Radarr
chown -R www-data: /var/www/spotweb
chown -R www-data: /usr/share/nginx/html/
chown -R www-data: /var/www/

# Change Mode
chmod 755 /usr/share/nginx/html/latest/inc/imdb_class.php
chmod -R 777 /usr/share/nginx/html/cache
