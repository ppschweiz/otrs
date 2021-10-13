FROM debian:bullseye-slim

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		apache2 \
		gnupg \
		libapache-dbi-perl \
		libapache2-mod-perl2 \
		libarchive-zip-perl \
		libcrypt-eksblowfish-perl \
		libcss-minifier-xs-perl \
		libdatetime-perl \
		libdbd-mysql-perl \
		libdbd-mysql-perl \
		libencode-hanextra-perl \
		libgd-graph-perl \
		libgd-text-perl \
		libio-socket-ssl-perl \
		libjavascript-minifier-xs-perl \
		libjson-xs-perl \
		libmail-imapclient-perl \
		libmoo-perl \
		libnamespace-clean-perl \
		libnet-dns-perl \
		libnet-ldap-perl \
		libpdf-api2-perl \
		libsoap-lite-perl \
		libtemplate-perl \
		libtext-csv-xs-perl \
		libtimedate-perl \
		libxml-libxml-perl \
		libxml-libxslt-perl \
		libyaml-libyaml-perl \
		supervisor \
	; \
	rm -rf /var/lib/apt/lists/*

ENV APACHE_RUN_DIR /var/run/apache2
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

ENV OTRS_VERSION 6.0.37
ENV OTRS_SHA512 3486bf92fd1cfb15f30fbe8423626cb89a51e3735a18f081e0a8aee8ac34c8cea9938c5ec7500c13622cda97a4e47eb5ffb097a04304a0c0081102df786e0924

RUN set -eux; \
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		bzip2 \
		wget \
	; \
	rm -rf /var/lib/apt/lists/*; \
	wget -nv -O otrs.tar.bz2 "https://download.znuny.org/releases/znuny-${OTRS_VERSION}.tar.bz2"; \
	echo "$OTRS_SHA512 *otrs.tar.bz2" | sha512sum -c -; \
	mkdir /opt/otrs; \
	tar -xf otrs.tar.bz2 --strip-components=1 -C /opt/otrs; \
	rm otrs.tar.bz2; \
	useradd -r -d /opt/otrs -c 'OTRS user' otrs; \
	usermod -G nogroup otrs; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

COPY Config.pm /opt/otrs/Kernel/Config.pm
RUN /opt/otrs/bin/otrs.SetPermissions.pl /opt/otrs --otrs-user=otrs --web-group=www-data
RUN /opt/otrs/bin/otrs.CheckModules.pl

RUN a2dissite 000-default
RUN ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-enabled/otrs.conf
RUN { \
		echo 'RedirectMatch ^/$ /otrs-web/'; \
		echo 'PerlPassEnv MYSQL_PORT_3306_TCP_ADDR'; \
		echo 'PerlPassEnv MYSQL_PORT_3306_TCP_PORT'; \
		echo 'PerlPassEnv MYSQL_USERNAME'; \
		echo 'PerlPassEnv MYSQL_PASSWORD'; \
		echo 'PerlPassEnv MYSQL_DATABASE'; \
		echo 'PerlPassEnv SMTP_PORT_25_TCP_ADDR'; \
		echo 'PerlPassEnv SMTP_PORT_25_TCP_PORT'; \
		echo 'PerlPassEnv GPG_PWD_50D7E35A'; \
		echo 'PerlPassEnv GPG_PWD_B2C7B0F5'; \
		echo 'PerlPassEnv GPG_PWD_D4CE5C2B'; \
		echo 'PerlPassEnv GPG_PWD_EEC960A4'; \
	} >> /etc/apache2/sites-enabled/otrs.conf

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

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-n", "-c" , "/etc/supervisor/supervisord.conf"]
