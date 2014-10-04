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

    # AuthSyncModule::LDAP::UserSyncRolesDefinition
    # (If "LDAP" was selected for AuthModule and you want to sync LDAP groups to otrs roles, define the following.)
    $Self->{AuthSyncModule::LDAP::UserSyncRolesDefinition} = {
       'cn=DI,dc=workgroups,dc=piratenpartei,dc=ch' => { 'AG DI' => 1, },
       'cn=KAMP,dc=workgroups,dc=piratenpartei,dc=ch' => { 'AG KAMP' => 1, },
       'cn=ROA,dc=workgroups,dc=piratenpartei,dc=ch' => { 'AG ROA' => 1, },
       'cn=TNT,dc=workgroups,dc=piratenpartei,dc=ch' => { 'AG TNT'=> 1, },
       'cn=PR,dc=workgroups,dc=piratenpartei,dc=ch' => { 'AG PR'=> 1, },
       'cn=Board,dc=piratenpartei,dc=ch' => { 'Board' => 1, },
       'cn=Direction,cn=Board,dc=piratenpartei,dc=ch' => { 'Board' => 1, 'Direction' => 1,},
       'cn=Presidium,cn=Board,dc=piratenpartei,dc=ch' => { 'Board' => 1, 'Presidium' => 1, },
       'cn=Board,st=ag,dc=piratenpartei,dc=ch' => { 'Board AG' => 1, },
       'cn=Board,st=bb,dc=piratenpartei,dc=ch' => { 'Board BB' => 1, },
       'cn=Board,st=be,dc=piratenpartei,dc=ch' => { 'Board BE' => 1, },
       'cn=Board,st=fr,dc=piratenpartei,dc=ch' => { 'Board FR' => 1, },
       'cn=Board,st=ge,dc=piratenpartei,dc=ch' => { 'Board GE' => 1, },
       'cn=Board,st=ne,dc=piratenpartei,dc=ch' => { 'Board NE' => 1, },
       'cn=Board,st=os,dc=piratenpartei,dc=ch' => { 'Board OS' => 1, },
       'cn=Board,st=ti,dc=piratenpartei,dc=ch' => { 'Board TI' => 1, },
       'cn=Board,st=ts,dc=piratenpartei,dc=ch' => { 'Board TS' => 1, },
       'cn=Board,st=vd,dc=piratenpartei,dc=ch' => { 'Board VD' => 1, },
       'cn=Board,st=vs,dc=piratenpartei,dc=ch' => { 'Board VS' => 1, },
       'cn=Board,st=zh,dc=piratenpartei,dc=ch' => { 'Board ZH' => 1, },
       'cn=Board,st=zs,dc=piratenpartei,dc=ch' => { 'Board ZS' => 1, },
       'cn=Board,l=bern,st=be,dc=piratenpartei,dc=ch' => { 'Board Bern' => 1, },
       'cn=Board,l=winterthur,st=zh,dc=piratenpartei,dc=ch' => { 'Board Winterthur' => 1, },
       'cn=Board,l=zurich,st=zh,dc=piratenpartei,dc=ch' => { 'Board Zürich' => 1, },
       'cn=AnK,dc=piratenpartei,dc=ch' => { 'Antragskommission' => 1, },
       'cn=PG,dc=piratenpartei,dc=ch' => { 'Pirate Court'=> 1, },
   };

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
