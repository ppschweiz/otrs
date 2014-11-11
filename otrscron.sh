#!/bin/sh
set -e
su otrs -c "/usr/bin/perl /opt/otrs/bin/otrs.PostMasterMailbox.pl -b 60"
