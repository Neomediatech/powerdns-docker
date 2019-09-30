FROM alpine

ENV VERSION=4.1.11 \
    BUILD_DATE=2019-08-03 \
    TZ=Europe/Rome \
    MYSQL_AUTOCONF=true \
    MYSQL_HOST="mysql" \
    MYSQL_PORT="3306" \
    MYSQL_USER="root" \
    MYSQL_PASS="root" \
    MYSQL_DB="pdns"
    
LABEL maintainer="docker-dario@neomediatech.it" \ 
      org.label-schema.version=$VERSION \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-type=Git \
      org.label-schema.vcs-url=https://github.com/Neomediatech/dnsbl/docker/images/powerdns \
      org.label-schema.maintainer=Neomediatech

RUN apk --update upgrade && \
    apk add ca-certificates curl less \
        boost-program_options \
        openssl \
        mariadb-connector-c libpq \
        mariadb-client \
        yaml-cpp \
	pdns pdns-backend-mariadb pdns-tools bash && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /etc/pdns/conf.d

ENV PAGER less

ADD schema.sql pdns.conf /etc/pdns/
ADD docker-entrypoint.sh /
RUN chmod +x /entrypoint.sh

RUN pdns_server --version || [ $? -eq 99 ]

HEALTHCHECK --interval=1m --timeout=3s --start-period=10s CMD /usr/bin/pdns_control --config-dir=/etc/pfns rping || exit 1
ENTRYPOINT ["/docker-entrypoint.sh"]

