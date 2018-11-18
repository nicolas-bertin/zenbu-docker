##########################################################################################################
FROM debian:stretch-slim as base
##########################################################################################################

LABEL base.image="debian:stretch-slim"
LABEL maintainer="Nicolas Bertin <nicolas.bertin@gmail.com>"


##########################################################################################################
FROM base as dockerize
##########################################################################################################

# Add dockerize utility to simplify running applications in docker containers.
#    https://github.com/jwilder/dockerize/
# Dockerize is a utility to simplify running applications in docker contaiers.
# It allows you to:
#    Generate application configuration files at container startup time from templates and container environment variables
#    Tail multiple log files to stdout and/or stderr
#    Wait for other services to be available using TCP, HTTP(S), unix before starting the main process.

ARG DOCKERIZE_VERSION="v0.6.1-5-g9773555"
ARG DOCKERIZE_DIST_URL="https://github.com/nicolas-bertin/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz"

WORKDIR "/"
RUN set -eux; \
        \
        apt-get update; \
        apt-get install -y --no-install-recommends wget ca-certificates; \
        wget  -O dist.tar.gz ${DOCKERIZE_DIST_URL}; \
        tar -C /usr/local/bin -xzvf dist.tar.gz; \
        rm dist.tar.gz


##########################################################################################################
FROM base as builder
##########################################################################################################

LABEL software="ZENBU"
LABEL description=" \
   ZENBU is a data integration, data analysis, and visualization system enhanced for next-generation-sequence-tag (NGS) based data. \
   ZENBU allows for novel data exploration through "on-demand" data processing and interactive linked-visualizations and is able to \
   make many-views from the same primary sequence alignment data which users can uploaded from BAM, BED, GFF and tab-text files. \
   Data integration, data processing, and visualization system based around three main web interfaces: \
       - an expression data enhanced genome browser interface, \
       - a secured user system for data upload and secured data sharing, and \
       - a data explorer interface to find and manipulate data across the many supported experimental data types and to find shared user configurations"
LABEL website="http://fantom.gsc.riken.jp/zenbu/"
LABEL github="https://github.com/jessica-severin/ZENBU"

ARG ZENBU_VERSION="2.11"
LABEL version=${ZENBU_VERSION}
ARG ZENBU_SRC_URL="https://github.com/jessica-severin/ZENBU_${ZENBU_VERSION}"
ARG ZENBU_SRC_DIR="/usr/share/zenbu/src/"

ARG ZENBU_SRC_PATCH="ZENBU_${ZENBU_VERSION}.patch"
COPY ${ZENBU_SRC_PATCH} ${ZENBU_SRC_DIR}/../src.patch


WORKDIR "/"
RUN set -eux; \
        \
        allDeps=" \
            apache2 \
            bzip2 \
            cvs \
            ca-certificates \
            expat \
            git \
            wget \
            patch \
            nano \
            openssl \
            sqlite3 \
            samtools \
            uuid-runtime \
            make \
            cmake \
            gcc \
            g++ \
            libapache2-mod-fcgid \
            libboost-dev \
            libcrypto++-dev \
            libcurl4-openssl-dev \
            libexpat1-dev \
            libfcgi-dev \
            libncurses-dev \
            libssl-dev \
            default-libmysqlclient-dev \
          #  libmysqlclient-dev \ 
            mysql-client \ 
            libmysql++-dev \
            libsqlite3-dev \
            zlib1g-dev \
            libcache-perl \
            libcgi-application-perl \
            libcgi-fast-perl \
            libclass-dbi-mysql-perl \
            libclass-dbi-sqlite-perl \
            libcrypt-openssl-bignum-perl \
            libdata-uuid-perl \
            libio-all-lwp-perl \
            liblwp-authen-oauth-perl \
            liblwpx-paranoidagent-perl \
            libnet-openid-common-perl \
            libnet-openid-consumer-perl \
          #  libnet-ping-external-perl \ libnet-ping-external-perl only maintained up to debian wheezy!!  lets try to simply remove it
            libswitch-perl \
            libxml-treepp-perl \
            libyaml-perl \
        "; \
        apt-get update; \
        apt-get install -y --no-install-recommends -V $allDeps; \
        \
## retrieve, patch and extract source to /usr/share/zenbu/src
        mkdir -p ${ZENBU_SRC_DIR}; \
        cd ${ZENBU_SRC_DIR}; \
        git clone ${ZENBU_SRC_URL} . ; \
        patch -p1 < ../src.patch; \
## copy the perl lib objects to /usr/share/zenbu/src/ZENBU/lib
        mkdir ${ZENBU_SRC_DIR}/ZENBU; \
        cp -r ${ZENBU_SRC_DIR}/lib ${ZENBU_SRC_DIR}/ZENBU; \
## compile base sources in /usr/share/zenbu/src/c++
        cd ${ZENBU_SRC_DIR}/c++; \
        make; \
## compile tools' sources in /usr/share/zenbu/src/c++/tools
## install the commandline tools
       cd ${ZENBU_SRC_DIR}/c++/tools; \
       make; \
       make install; \
## compile cgi sources in /usr/share/zenbu/src/c++/cgi
       cd ${ZENBU_SRC_DIR}/c++/cgi; \
       make




##########################################################################################################
FROM builder as app
##########################################################################################################

# 
# Add/set up apache2
# copy .html, .js and .cgi files to Apache docroot
# default command 
#   - setup apache2 site 000-default.conf & zenbu.conf 
#   - wait for `db` service to be ready   
#   - make apache2 access.log & error.log to docker logs (stdout & stderr reespectively)
#   ...and start apache2 process    
#
ARG ZENBU_VERSION="2.11"
ARG ZENBU_AGENT_TEMPLATE="app.agent.template"
ARG ZENBU_WWW_INIT_TEMPLATE="app.init.template"
ARG ZENBU_WWW_SITE_TEMPLATE="site.conf.template"
ARG ZENBU_WWW_DIR="/usr/share/zenbu/www"
ARG ZENBU_SRC_DIR="/usr/share/zenbu/src"
ARG ZENBU_CONF_TEMPLATE="app.conf.template"
ARG ZENBU_CONF_DIR="/etc/zenbu"
ARG ZENBU_USERS_DIR="/var/lib/zenbu/users"
ARG ZENBU_CACHE_DIR="/var/lib/zenbu/cache"
ARG ENTRYPOINT="docker-entrypoint.sh"

ENV APACHE_RUN_USER="www-data"
ENV APACHE_RUN_GROUP="www-data"

COPY --from=dockerize /usr/local/bin/dockerize /usr/local/bin/
COPY ${ZENBU_AGENT_TEMPLATE} ${ZENBU_SRC_DIR}/app.agent.template
COPY ${ZENBU_WWW_INIT_TEMPLATE} ${ZENBU_SRC_DIR}/app.init.template
COPY ${ZENBU_WWW_SITE_TEMPLATE} ${ZENBU_SRC_DIR}/site.conf.template
COPY ${ZENBU_CONF_TEMPLATE} ${ZENBU_SRC_DIR}/app.conf.template
COPY ${ENTRYPOINT} /docker-entrypoint.sh

WORKDIR "/"
RUN set -eux; \
        \
       mkdir -p ${ZENBU_CONF_DIR}; \
       mkdir -p ${ZENBU_WWW_DIR}/zenbu/cgi; \
## copy .html, .js and .cgi files to zenbu-www-dir (apache docroot) 
       cp -rp ${ZENBU_SRC_DIR}/www/zenbu ${ZENBU_WWW_DIR}; \
       cp ${ZENBU_SRC_DIR}/c++/cgi/*cgi ${ZENBU_WWW_DIR}/zenbu/cgi; \
## activate apache mods
       a2enmod cgi; \
       a2enmod cgid; \
       a2enmod fcgid; \
## remove default enabled sites
       rm /etc/apache2/sites-enabled/*; \
## make apache daemon the owner of zenbu /users to /cache dirs
       mkdir -p ${ZENBU_CACHE_DIR} ${ZENBU_USERS_DIR}; \
       chown ${APACHE_RUN_USER}:${APACHE_RUN_GROUP}  ${ZENBU_CACHE_DIR} ${ZENBU_USERS_DIR}; \
## prepare app.init (aka `zenbu_register_peer ... -new_peer` followed by `/usr/sbin/apache2ctl -D FOREGROIUND`)
## prepare app.agent (aka `/usr/local/bin/zenbu_agent_launcher.sh`)
       touch /app.init /app.agent  ; \
       chmod +x /app.init /app.agent /docker-entrypoint.sh

#EXPOSE 80
#CMD ["dockerize", "-template", "${ZENBU_SRC_DIR}/site.conf.template:/etc/apache2/sites-enabled/zenbu.conf", \
#                  "-template", "${ZENBU_SRC_DIR}/app.conf.template:${ZENBU_CONF_DIR}/zenbu.conf", \
#                  "-template", "${ZENBU_SRC_DIR}/app.init.template:/app.init", \
#                  "-template", "${ZENBU_SRC_DIR}/app.agent.template:/app.agent", \
#                  "-wait", "tcp://db:3306", \
#     "/app.init"]

ENTRYPOINT ["/docker-entrypoint.sh"]
