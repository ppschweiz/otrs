# --
# Kernel/Config.pm - Config file for OTRS kernel
# Copyright (C) 2001-2013 OTRS AG, http://otrs.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
#  Note:
#
#  -->> Most OTRS configuration should be done via the OTRS web interface
#       and the SysConfig. Only for some configuration, such as database
#       credentials and customer data source changes, you should edit this
#       file. For changes do customer data sources you can copy the definitions
#       from Kernel/Config/Defaults.pm and paste them in this file.
#       Config.pm will not be overwritten when updating OTRS.
# --

package Kernel::Config;

#use strict;
use warnings;
use utf8;

sub Load {
    my $Self = shift;

    # ---------------------------------------------------- #
    # database settings                                    #
    # ---------------------------------------------------- #

    # The database host
    $Self->{DatabaseHost} = $ENV{'MYSQL_PORT_3306_TCP_ADDR'};

    # The database name
    $Self->{Database} = $ENV{'MYSQL_DATABASE'};

    # The database user
    $Self->{DatabaseUser} = $ENV{'MYSQL_USERNAME'};

    # The password of database user. You also can use bin/otrs.CryptPassword.pl
    # for crypted passwords
    $Self->{DatabasePw} = $ENV{'MYSQL_PASSWORD'};

    # The database DSN for MySQL ==> more: "perldoc DBD::mysql"
    $Self->{DatabaseDSN} = "DBI:mysql:database=$Self->{Database};host=$Self->{DatabaseHost};";

    # ---------------------------------------------------- #
    # fs root directory
    # ---------------------------------------------------- #
    $Self->{Home} = '/opt/otrs';

    # ---------------------------------------------------- #
    # insert your own config settings "here"               #
    # config settings taken from Kernel/Config/Defaults.pm #
    # ---------------------------------------------------- #
    # $Self->{SessionUseCookie} = 0;
    # $Self->{CheckMXRecord} = 0;
    $Self->{'DefaultCharset'} = 'utf-8';

    delete $Self->{'PreferencesGroups'}->{'SpellDict'};
    delete $Self->{'SendmailBcc'};
    $Self->{'Organization'} =  'Piratenpartei Schweiz';
    $Self->{'AdminEmail'} =  'admin@piratenpartei.ch';
    $Self->{'HttpType'} =  'https';
    $Self->{'FQDN'} =  'info.piratenpartei.ch';
    $Self->{'SecureMode'} =  '1';
    $Self->{'MinimumLogLevel'} =  'info';
    $Self->{'PostMasterMaxEmailSize'} =  40960;
    $Self->{'SendmailModule'} = 'Kernel::System::Email::SMTP';
    $Self->{'SendmailModule::Host'} = $ENV{'SMTP_PORT_25_TCP_ADDR'};
    
    $Self->{'AuthModule'} = 'Kernel::System::Auth::LDAP';
    $Self->{'AuthModule::UseSyncBackend'} = 'AuthSyncBackend';
    $Self->{'AuthModule::LDAP::Host'} = $ENV{'LDAP_PORT_389_TCP_ADDR'};
    $Self->{'AuthModule::LDAP::BaseDN'} = $ENV{'LDAP_BASEDN'};
    $Self->{'AuthModule::LDAP::UID'} = $ENV{'LDAP_UID'};

    $Self->{'AuthModule::LDAP::SearchUserDN'} = $ENV{'LDAP_USERNAME'};
    $Self->{'AuthModule::LDAP::SearchUserPw'} = $ENV{'LDAP_PASSWORD'};

    $Self->{'AuthSyncModule'} = 'Kernel::System::Auth::Sync::LDAP';
    $Self->{'AuthSyncModule::LDAP::Host'} = $ENV{'LDAP_PORT_389_TCP_ADDR'};
    $Self->{'AuthSyncModule::LDAP::BaseDN'} = $ENV{'LDAP_BASEDN'};
    $Self->{'AuthSyncModule::LDAP::UID'} = $ENV{'LDAP_UID'};
    $Self->{'AuthSyncModule::LDAP::SearchUserDN'} = $ENV{'LDAP_USERNAME'};
    $Self->{'AuthSyncModule::LDAP::SearchUserPw'} = $ENV{'LDAP_PASSWORD'};
    $Self->{'AuthSyncModule::LDAP::UserSyncMap'} = {
       # DB -> LDAP
       UserFirstname => 'givenName',
       UserLastname  => 'sn',
       UserEmail     => 'mail',
    };
    $Self->{AuthSyncModule::LDAP::AccessAttr} = 'member';
    $Self->{AuthSyncModule::LDAP::UserAttr} = 'DN';

    # ---------------------------------------------------- #

    # ---------------------------------------------------- #
    # data inserted by installer                           #
    # ---------------------------------------------------- #
    # $DIBI$

    # ---------------------------------------------------- #
    # ---------------------------------------------------- #
    #                                                      #
    # end of your own config options!!!                    #
    #                                                      #
    # ---------------------------------------------------- #
    # ---------------------------------------------------- #
}

# ---------------------------------------------------- #
# needed system stuff (don't edit this)                #
# ---------------------------------------------------- #
use strict;
use warnings;

use vars qw(@ISA);

use Kernel::Config::Defaults;
push (@ISA, 'Kernel::Config::Defaults');

# -----------------------------------------------------#

1;
