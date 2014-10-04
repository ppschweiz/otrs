#!/bin/sh
set -e
su -s /usr/bin/perl otrs /opt/otrs/bin/otrs.RebuildConfig.pl
while true; do 
su -s /usr/bin/perl otrs /opt/otrs/bin/otrs.PostMasterMailbox.pl
sleep 60
done
