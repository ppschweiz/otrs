#!/bin/sh
set -e
while true; do 
su -s /bin/sh www-data /opt/otrs/bin/otrs.PostMasterMailbox.pl
sleep 60
done
