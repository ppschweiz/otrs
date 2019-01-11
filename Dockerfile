FROM debian:jessie

RUN apt-get update && apt-get -y install apache2 libapache2-mod-perl2 libdbd-mysql-perl libtimedate-perl libnet-dns-perl \
    libnet-ldap-perl libio-socket-ssl-perl libpdf-api2-perl libdbd-mysql-perl libsoap-lite-perl \
    libgd-text-perl libtext-csv-xs-perl libjson-xs-perl libgd-graph-perl libapache-dbi-perl libmail-imapclient-perl libyaml-libyaml-perl supervisor \
    libarchive-zip-perl libcrypt-eksblowfish-perl libtemplate-perl \
    libencode-hanextra-perl libxml-libxml-perl libxml-libxslt-perl

RUN apt-get install -y python-pip && pip install supervisor-stdout

ENV MYSQL_PORT_3306_TCP_ADDR localhost
ENV MYSQL_PORT_3306_TCP_PORT 3306
ENV MYSQL_USERNAME otrs
ENV MYSQL_PASSWORD changeme
ENV MYSQL_DATABASE otrs
ENV SMTP_PORT_25_TCP_ADDR mail-1-p.piratenpartei.ch
ENV SMTP_PORT_25_TCP_PORT 25
ENV GPG_PWD_50D7E35A changeme
ENV GPG_PWD_B2C7B0F5 changeme
ENV GPG_PWD_D4CE5C2B changeme
ENV GPG_PWD_EEC960A4 changeme

ADD otrs-5.0.34.tar.gz /opt/
RUN ln -s /opt/otrs-rel-5_0_34 /opt/otrs
RUN useradd -r -d /opt/otrs/ -c 'OTRS user' otrs && usermod -G nogroup otrs

COPY Config.pm /opt/otrs/Kernel/Config.pm
RUN /opt/otrs/bin/otrs.SetPermissions.pl /opt/otrs --otrs-user=otrs --web-group=www-data
RUN /opt/otrs/bin/otrs.CheckModules.pl

RUN a2dissite 000-default
RUN ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-enabled/otrs.conf
RUN echo "RedirectMatch ^/$ /otrs-web/" >> /etc/apache2/sites-enabled/otrs.conf
RUN echo "PerlPassEnv MYSQL_PORT_3306_TCP_ADDR" >> /etc/apache2/sites-enabled/otrs.conf
RUN echo "PerlPassEnv MYSQL_PORT_3306_TCP_PORT" >> /etc/apache2/sites-enabled/otrs.conf
RUN echo "PerlPassEnv MYSQL_USERNAME" >> /etc/apache2/sites-enabled/otrs.conf
RUN echo "PerlPassEnv MYSQL_PASSWORD" >> /etc/apache2/sites-enabled/otrs.conf
RUN echo "PerlPassEnv MYSQL_DATABASE" >> /etc/apache2/sites-enabled/otrs.conf
RUN echo "PerlPassEnv SMTP_PORT_25_TCP_ADDR" >> /etc/apache2/sites-enabled/otrs.conf
RUN echo "PerlPassEnv SMTP_PORT_25_TCP_PORT" >> /etc/apache2/sites-enabled/otrs.conf
RUN echo "PerlPassEnv GPG_PWD_50D7E35A" >> /etc/apache2/sites-enabled/otrs.conf
RUN echo "PerlPassEnv GPG_PWD_B2C7B0F5" >> /etc/apache2/sites-enabled/otrs.conf
RUN echo "PerlPassEnv GPG_PWD_D4CE5C2B" >> /etc/apache2/sites-enabled/otrs.conf
RUN echo "PerlPassEnv GPG_PWD_EEC960A4" >> /etc/apache2/sites-enabled/otrs.conf

EXPOSE 80/tcp

# Set required defaults
ENV APACHE_LOCK_DIR /var/run
ENV APACHE_PID_FILE /var/run/apache.pid
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log

COPY otrscron.sh /otrscron.sh
COPY entrypoint.sh /entrypoint.sh
COPY supervisord-apache2.conf /etc/supervisor/conf.d/
COPY supervisord-eventlistener.conf /etc/supervisor/conf.d/

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-n"]
