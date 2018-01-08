FROM httpd:latest

RUN set -eux; \
	apt-get update; \
	apt-get -y --no-install-recommends install \
		libarchive-zip-perl \
		libcrypt-eksblowfish-perl \
		libdbd-mysql-perl \
		libdbd-mysql-perl \
		libencode-hanextra-perl \
		libfile-spec-native-perl \
		libgd-graph-perl \
		libgd-text-perl \
		libio-socket-ssl-perl \
		libjson-xs-perl \
		libmail-imapclient-perl \
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
	;

ENV MOD_PERL_VERSION 2.0.10
ENV MOD_PERL_SHA256 d1cf83ed4ea3a9dfceaa6d9662ff645177090749881093051020bf42f9872b64

ENV OTRS_VERSION 5_0_26
ENV OTRS_SHA256 380405a55093a1d9c83e8f382890cdf696e0987755ad8cec666cdc1204c4168f

# Add mod_perl build dependencies
RUN set -eux; \
	buildDeps=" \
		gcc \
		libperl-dev \
		make \
		wget \
	"; \
	apt-get update; \
	apt-get install -y --no-install-recommends $buildDeps; \
# Fetch mod_perl source, build and install it
	wget -O mod_perl-$MOD_PERL_VERSION.tar.gz "https://www.apache.org/dyn/closer.cgi?action=download&filename=perl/mod_perl-$MOD_PERL_VERSION.tar.gz"; \
	wget -O mod_perl-$MOD_PERL_VERSION.tar.gz.asc "https://www-eu.apache.org/dist/perl/mod_perl-$MOD_PERL_VERSION.tar.gz.asc"; \
	wget -O Apache-DBI-1.12.tar.gz "https://cpan.metacpan.org/authors/id/P/PH/PHRED/Apache-DBI-1.12.tar.gz"; \
	echo "$MOD_PERL_SHA256 mod_perl-$MOD_PERL_VERSION.tar.gz" | sha256sum -c -; \
	ln -s /usr/lib/x86_64-linux-gnu/libgdbm.so.3.0.0 /usr/lib/libgdbm.so; \
	tar -xf mod_perl-$MOD_PERL_VERSION.tar.gz; \
	rm mod_perl-$MOD_PERL_VERSION.tar.gz; \
	rm mod_perl-$MOD_PERL_VERSION.tar.gz.asc; \
	cd mod_perl-$MOD_PERL_VERSION; \
	perl Makefile.PL MP_AP_PREFIX=/usr/local/apache2; \
	make -j "$(nproc)"; \
	make install; \
	cd ..; \
	rm -r mod_perl-$MOD_PERL_VERSION; \
# Fetch OTRS
	wget -O /opt/otrs-$OTRS_VERSION.tar.gz https://github.com/OTRS/otrs/archive/rel-$OTRS_VERSION.tar.gz; \
	echo "$OTRS_SHA256 /opt/otrs-$OTRS_VERSION.tar.gz" | sha256sum -c -; \
	tar -xf /opt/otrs-$OTRS_VERSION.tar.gz -C /opt; \
	rm /opt/otrs-$OTRS_VERSION.tar.gz; \
	mv /opt/otrs-rel-$OTRS_VERSION /opt/otrs; \
# Remove mod_perl build dependencies
	apt-get purge -y --auto-remove $buildDeps; \
	rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	apt-get update; \
	apt-get -y --no-install-recommends install \
		python-pip \
		supervisor \
	; \
	pip install \
		supervisor-stdout

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

RUN useradd -r -d /opt/otrs/ -c 'OTRS user' otrs && usermod -G nogroup otrs

COPY Config.pm /opt/otrs/Kernel/Config.pm
RUN /opt/otrs/bin/otrs.SetPermissions.pl /opt/otrs --otrs-user=otrs --web-group=www-data
RUN /opt/otrs/bin/otrs.CheckModules.pl

RUN echo " \
Listen *:80\n \
LoadModule access_compat_module modules/mod_access_compat.so\n \
LoadModule alias_module modules/mod_alias.so\n \
LoadModule deflate_module modules/mod_deflate.so\n \
LoadModule filter_module modules/mod_filter.so\n \
LoadModule headers_module modules/mod_headers.so\n \
LoadModule mime_module modules/mod_mime.so\n \
LoadModule perl_module modules/mod_perl.so\n \
LoadModule version_module modules/mod_version.so\n \
RedirectMatch ^/$ /otrs-web/\n \
PerlPassEnv MYSQL_PORT_3306_TCP_ADDR\n \
PerlPassEnv MYSQL_PORT_3306_TCP_PORT\n \
PerlPassEnv MYSQL_USERNAME\n \
PerlPassEnv MYSQL_PASSWORD\n \
PerlPassEnv MYSQL_DATABASE\n \
PerlPassEnv SMTP_PORT_25_TCP_ADDR\n \
PerlPassEnv SMTP_PORT_25_TCP_PORT\n \
PerlPassEnv GPG_PWD_50D7E35A\n \
PerlPassEnv GPG_PWD_B2C7B0F5\n \
PerlPassEnv GPG_PWD_D4CE5C2B\n \
PerlPassEnv GPG_PWD_EEC960A4\n \
" >> /opt/otrs/scripts/apache2-httpd.include.conf
RUN ln -sf /opt/otrs/scripts/apache2-httpd.include.conf /usr/local/apache2/conf/httpd.conf

COPY otrscron.sh /otrscron.sh
COPY entrypoint.sh /entrypoint.sh
COPY supervisord-apache2.conf /etc/supervisor/conf.d/
COPY supervisord-eventlistener.conf /etc/supervisor/conf.d/
EXPOSE 80/tcp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-n"]
