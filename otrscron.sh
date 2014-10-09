#!/bin/sh
set -e
su -s /usr/bin/perl otrs /opt/otrs/bin/otrs.RebuildConfig.pl
chmod 666 /opt/otrs/Kernel/Config/Files/ZZZAAuto.pm
su -s /usr/bin/perl otrs /opt/otrs/bin/otrs.PostMasterMailbox.pl -b 60
