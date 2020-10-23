#!/bin/sh

set -eu

su -s /usr/bin/perl otrs -c "/opt/otrs/bin/otrs.Console.pl Maint::Database::Check"
su -s /usr/bin/perl otrs -c "/opt/otrs/bin/otrs.Console.pl Maint::Config::Rebuild"
su -s /usr/bin/perl otrs -c "/opt/otrs/bin/otrs.Console.pl Maint::Cache::Delete"

/opt/otrs/bin/otrs.SetPermissions.pl /opt/otrs --otrs-user=www-data --web-group=www-data
chmod 666 /opt/otrs/Kernel/Config/Files/ZZZAAuto.pm

su -s /usr/bin/perl www-data -c "/opt/otrs/bin/otrs.Daemon.pl start"

exec "$@"
