#!/usr/bin/env bash

set -o errexit
set -v

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $__dir/_src/
cp $__dir/source-codes/ckan-2.4.0.zip $__dir/source-codes/ckanext-pages-master.zip .
rm -rf $__dir/ckan-ckan-2.4.0
rm -rf $__dir/ckanext-pages-master
unzip -o ckanext-pages-master.zip && rm ckanext-pages-master.zip
unzip -o ckan-2.4.0.zip && rm ckan-2.4.0.zip

cp $__dir/source-codes/datapusher-stable.zip $__dir/_service-provider/
rm -rf $__dir/_service-provider/_datapusher
cd $__dir/_service-provider/
unzip -o datapusher-stable.zip && rm datapusher-stable.zip
mv datapusher-stable _datapusher
cp Dockerfile _datapusher/

