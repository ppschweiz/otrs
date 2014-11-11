#!/bin/bash
set -e
su -s /usr/bin/perl otrs /opt/otrs/bin/otrs.RebuildConfig.pl
chmod 666 /opt/otrs/Kernel/Config/Files/ZZZAAuto.pm

exec "$@"
