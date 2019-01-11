FROM perl:latest

ENV OTRS_VERSION 5_0_34
ENV OTRS_SHA256 af2e319b0c86bb5b0b3a22651d294cea0c4cb846c6daef3184d226e2d08ca74b

# Add mod_perl build dependencies
RUN set -eux; \
	apt-get update; \
	apt-get -y --no-install-recommends install \
		libfreetype6 \
		libgd3 \
		libicu57 \
		libjpeg62-turbo \
		libmariadbclient18 \
		libossp-uuid16 \
		libpng16-16 \
		libtiff5 \
		libwebp6 \
	; \
	cpanm -M https://www.cpan.org/ \
		Apache::DBI \
		Archive::Tar \
		Archive::Zip \
		Crypt::Eksblowfish::Bcrypt \
		Date::Format \
		DBI \
		DBD::mysql \
		DBD::Pg \
		Digest::SHA \
		Encode::HanExtra \
		IO::Socket::SSL \
		JSON::XS \
		List::Util::XS \
		LWP::UserAgent \
		Mail::IMAPClient \
		IO::Socket::SSL \
		Authen::SASL \
		Authen::NTLM \
		Net::DNS \
		Net::LDAP \
		Template \
		Template::Stash::XS \
		Text::CSV_XS \
		Time::HiRes \
		Time::Piece \
		XML::LibXML \
		XML::LibXSLT \
		XML::Parser \
		YAML::XS \
	; \
#	rm -rf /root/.cpanm; \
	rm -rf /var/lib/apt/lists/*

# Fetch OTRS
RUN set -eux; \
	wget -O /opt/otrs-$OTRS_VERSION.tar.gz https://github.com/OTRS/otrs/archive/rel-$OTRS_VERSION.tar.gz; \
	echo "$OTRS_SHA256 /opt/otrs-$OTRS_VERSION.tar.gz" | sha256sum -c -; \
	tar -xf /opt/otrs-$OTRS_VERSION.tar.gz -C /opt; \
	rm /opt/otrs-$OTRS_VERSION.tar.gz; \
	mv /opt/otrs-rel-$OTRS_VERSION /opt/otrs

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
#RUN /opt/otrs/bin/otrs.SetPermissions.pl /opt/otrs --otrs-user=otrs --web-group=www-data
RUN /opt/otrs/bin/otrs.CheckModules.pl

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
#USER www-data
CMD ["/opt/otrs/bin/otrs.Daemon.pl", "start"]
