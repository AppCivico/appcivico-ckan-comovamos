#!/usr/bin/env bash
set -o errexit


COMPOSENAME=${PWD##*/}

# hope this will solve the issue if people use diffrent name than the original of git clone
COMPOSENAME=$(echo "$COMPOSENAME" |  tr -cd 'A-Za-z0-9')

if [ ! -f _config/who.ini ]; then
    echo "copying who.ini to _config/"
    cp _src/ckan-release-v2.3.1/who.ini _config/
fi

if [ ! -f _config/ckan.ini ]; then
    echo "using paster for generate ckan.ini under _config/"
    docker rm ckan-generate-config-paster 1>/dev/null 2>/dev/null|| true
    docker run --rm --name ckan-generate-config-paster \
      -v `pwd`/_config/:/etc/ckan/default/ \
       --tty --entrypoint='' ${COMPOSENAME}_ckan /bin/bash -c 'cd /usr/lib/ckan/default && virtualenv . && /usr/lib/ckan/default/bin/paster make-config ckan /etc/ckan/default/ckan.ini'
   docker rm ckan-generate-config-paster 1>/dev/null 2>/dev/null|| true
fi

if [ ! -f _config/custom_options.ini ]; then
    echo "copying custom_options.ini to _config/"
    cp _etc/ckan/custom_options.ini _config/
fi
