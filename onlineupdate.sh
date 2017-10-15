#!/bin/bash
THISUSER=$(whoami)
    if [ $THISUSER != 'root' ]
        then
            echo 'You must use sudo to run this script, sorry!'
           exit 1
    fi

mkdir /var/log/openflixrupdate
exec 1> >(tee -a /var/log/openflixrupdate/onlineupdate.log) 2>&1
TODAY=$(date)
echo "-----------------------------------------------------"
echo "Date:          $TODAY"
echo "-----------------------------------------------------"

## OpenFLIXR Online Update version 1.0.3
echo ""
echo "OpenFLIXR Wizard Update:"
cd /usr/share/nginx/html/setup
git reset --hard
git pull
echo ""
echo "OpenFLIXR Online Update:"
cd /opt/update
chmod -x /opt/update/scripts/*
git pull
echo ""
echo "OpenFLIXR installing updates:"
chmod +x /opt/update/scripts/*

cd /opt/update/doneupdate/
FILES=*

for f in $FILES
  do
    if [ "$f" != '*' ]
        then
          rm /opt/update/scripts/$f
    fi
  done
run-parts /opt/update/scripts
