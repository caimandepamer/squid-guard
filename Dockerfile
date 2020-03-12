FROM ubuntu
LABEL maintainer="rafael.campoverde@pe.ibm.com"

ENV SQUID_VERSION=3.5.27 \
    SQUID_CACHE_DIR=/var/spool/squid \
    SQUID_LOG_DIR=/var/log/squid \
    SQUID_USER=proxy

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y squid=${SQUID_VERSION}* \
 && apt update -y  \
 && apt install -y squidguard curl vim telnet\
 && rm -rf /var/lib/apt/lists/*

RUN curl -o /tmp/blacklists.tar.gz ftp://ftp.ut-capitole.fr/pub/reseau/cache/squidguard_contrib/blacklists.tar.gz
RUN mkdir /var/squidGuard/ 
RUN tar -zxvf /tmp/blacklists.tar.gz -C  /var/squidGuard/
RUN squidGuard -b -d -C all 
RUN chown -R proxy:proxy /var/squidGuard/blacklists/


COPY squid/squid.conf /etc/squid/squid.conf
COPY squid/squidGuard.conf /etc/squid/squidGuard.conf

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3128/tcp
ENTRYPOINT ["/sbin/entrypoint.sh"]

