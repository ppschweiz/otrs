FROM ppschweiz/apache

RUN apt-get update && apt-get -y install libapache2-mod-perl2 libdbd-mysql-perl libtimedate-perl libnet-dns-perl \
    libnet-ldap-perl libio-socket-ssl-perl libpdf-api2-perl libdbd-mysql-perl libsoap-lite-perl \
    libgd-text-perl libtext-csv-xs-perl libjson-xs-perl libgd-graph-perl libapache-dbi-perl libmail-imapclient-perl libyaml-libyaml-perl supervisor


ENV LDAP_PORT_389_TCP_ADDR localhost
ENV LDAP_BASEDN dc=piratenpartei,dc=ch
ENV LDAP_UID uid
ENV LDAP_USERNAME cn=bind,dc=piratenpartei,dc=ch
ENV LDAP_PASSWORD changeme

ENV MYSQL_PORT_3306_TCP_ADDR localhost
ENV MYSQL_PORT_3306_TCP_PORT 3306
ENV MYSQL_USERNAME otrs
ENV MYSQL_PASSWORD changeme
ENV MYSQL_DATABASE otrs
ENV SMTP_PORT_22_TCP_ADDR mail-1-p.piratenpartei.ch
ENV SMTP_PORT_22_TCP_PORT 25

ADD otrs-3.2.16.tar.gz /opt/
RUN ln -s /opt/otrs-3.2.16 /opt/otrs
RUN useradd -r -d /opt/otrs/ -c 'OTRS user' otrs && usermod -G nogroup otrs

COPY Config.pm /opt/otrs/Kernel/Config.pm
RUN cp /opt/otrs/Kernel/Config/GenericAgent.pm.dist /opt/otrs/Kernel/Config/GenericAgent.pm
RUN /opt/otrs/bin/otrs.SetPermissions.pl /opt/otrs --otrs-user=otrs --otrs-group=nogroup --web-user=www-data --web-group=www-data
RUN /opt/otrs/bin/otrs.CheckModules.pl

RUN a2dissite 000-default
RUN ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/conf.d/otrs.conf
RUN echo "RedirectMatch ^/$ /otrs-web/" >> /etc/apache2/conf.d/otrs.conf
RUN echo "PerlPassEnv MYSQL_PORT_3306_TCP_ADDR" >> /etc/apache2/conf.d/otrs.conf
RUN echo "PerlPassEnv MYSQL_PORT_3306_TCP_PORT" >> /etc/apache2/conf.d/otrs.conf
RUN echo "PerlPassEnv MYSQL_USERNAME" >> /etc/apache2/conf.d/otrs.conf
RUN echo "PerlPassEnv MYSQL_PASSWORD" >> /etc/apache2/conf.d/otrs.conf
RUN echo "PerlPassEnv MYSQL_DATABASE" >> /etc/apache2/conf.d/otrs.conf
RUN echo "PerlPassEnv SMTP_PORT_22_TCP_ADDR" >> /etc/apache2/conf.d/otrs.conf
RUN echo "PerlPassEnv SMTP_PORT_22_TCP_PORT" >> /etc/apache2/conf.d/otrs.conf
RUN echo "PerlPassEnv LDAP_PORT_389_TCP_ADDR" >> /etc/apache2/conf.d/otrs.conf
RUN echo "PerlPassEnv LDAP_BASEDN" >> /etc/apache2/conf.d/otrs.conf
RUN echo "PerlPassEnv LDAP_UID" >> /etc/apache2/conf.d/otrs.conf
RUN echo "PerlPassEnv LDAP_USERNAME" >> /etc/apache2/conf.d/otrs.conf
RUN echo "PerlPassEnv LDAP_PASSWORD" >> /etc/apache2/conf.d/otrs.conf

COPY otrscron.sh /otrscron.sh
COPY supervisord-apache2.conf /etc/supervisor/conf.d/
COPY supervisord-otrscron.conf /etc/supervisor/conf.d/

CMD ["supervisord", "-n"]
