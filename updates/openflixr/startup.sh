#!/bin/bash
cd /opt/openflixr/
echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1

if [ $? -eq 0 ]; then
bash updateof
else
echo "Can't update, no Internet Access"
	exit 1
fi
