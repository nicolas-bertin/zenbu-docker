#!/bin/bash
set -eo pipefail
shopt -s nullglob

cmd=( $( ls /usr/local/bin/zenbu* --ignore=/usr/local/bin/zenbu_agent_launcher.sh ) )
cmdBasename=( ${cmd[@]##*/} )

if [ "$1" == init ] || [ "$1" == app.init ]; then

   /usr/local/bin/dockerize \
               -template /usr/share/zenbu/src/site.conf.template:/etc/apache2/sites-enabled/zenbu.conf \
               -template /usr/share/zenbu/src/app.conf.template:/etc/zenbu/zenbu.conf \
               -template /usr/share/zenbu/src/app.init.template:/app.init \
               -template /usr/share/zenbu/src/app.agent.template:/app.agent \
               -stdout /var/log/apache2/access.log \
               -stderr /var/log/apache2/error.log \
               -wait tcp://db:3306 -timeout 60s \
               /app.init

elif [ "$1" == agent ] || [ "$1" == app.agent ]; then

   /usr/local/bin/dockerize \
               -template /usr/share/zenbu/src/app.agent.template:/app.agent \
               -wait tcp://www:80 -timeout 60s \
               -wait tcp://db:3306 -timeout 60s \
               /app.agent

elif ! [[ ${cmdBasename[*]} =~ "$1" ]] ; then

    echo "Available ZENBU commands: "
    echo "$(printf '\t%s\n' "${cmdBasename[@]}")"

fi

exec "$@"
