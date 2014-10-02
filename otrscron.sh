#!/bin/sh
set -e
while true; do 
su www-data /opt/otrs/bin/otrs.PostMasterMailbox.pl
sleep 60
done
