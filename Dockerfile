FROM alpine:3.10

ENV VERSION=4.1.11-r0 \
    BUILD_DATE=2019-08-03 \
    TZ=Europe/Rome \
    PDNS_HOME=/etc/pdns
    
LABEL maintainer="docker-dario@neomediatech.it" \ 
      org.label-schema.version=$VERSION \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-type=Git \
      org.label-schema.vcs-url=https://github.com/Neomediatech/dnsbl/docker/images/powerdns \
      org.label-schema.maintainer=Neomediatech

RUN apk --update upgrade && \
    apk add ca-certificates curl less tzdata bash \
        boost-program_options \
        openssl \
        mariadb-connector-c libpq \
        mariadb-client \
        yaml-cpp \
	pdns pdns-backend-mariadb pdns-tools bash && \
    rm -rf /var/cache/apk/* && \
    mkdir -p ${PDNS_HOME}/conf.d

WORKDIR ${PDNS_HOME}

COPY pdns.conf ${PDNS_HOME}/
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
COPY pdns.conf /etc/pdns/

RUN pdns_server --version || [ $? -eq 99 ]

HEALTHCHECK --interval=1m --timeout=3s --start-period=10s CMD /usr/bin/pdns_control --config-dir=${PDNS_HOME} rping || exit 1
ENTRYPOINT ["/docker-entrypoint.sh"]

