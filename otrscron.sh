#!/bin/sh
set -e
while true; do
su otrs -c "/usr/bin/perl /opt/otrs/bin/otrs.PostMasterMailbox.pl"
su otrs -c "/usr/bin/perl /opt/otrs/bin/otrs.GenericAgent.pl"
su otrs -c "/usr/bin/perl /opt/otrs/bin/otrs.PendingJobs.pl"
su otrs -c "/usr/bin/perl /opt/otrs/bin/otrs.UnlockTickets.pl --timeout"
su otrs -c "/usr/bin/perl /opt/otrs/bin/otrs.Scheduler.pl -w 1"
sleep 60
done
