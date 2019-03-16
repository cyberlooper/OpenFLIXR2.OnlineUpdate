#!/bin/bash
if nc -zw1 8.8.8.8 53; then
bash /opt/openflixr/updateof
else
echo "Can't update, no Internet Access"
	exit 1
fi
