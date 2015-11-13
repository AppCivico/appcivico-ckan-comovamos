#!/usr/bin/env bash
set -o errexit

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "\$__dir=$__dir\n\n"

set -v

#echo "ckan 2.4..."
echo "v2.3.1"
cd $__dir/_src/
#cp $__dir/source-codes/ckan-2.4.0.zip $__dir/source-codes/ckanext-pages-master.zip .
cp $__dir/source-codes/release-v2.3.1.zip $__dir/source-codes/ckanext-pages-master.zip .
#rm -rf $__dir/ckan-ckan-2.4.0
rm -rf $__dir/ckan-release-v2.3.1
rm -rf $__dir/ckanext-pages-master
unzip -qo ckanext-pages-master.zip && rm ckanext-pages-master.zip
unzip -qo release-v2.3.1.zip && rm release-v2.3.1.zip

echo "unzip datapusher..."
cp $__dir/source-codes/datapusher-006.tar.gz $__dir/_service-provider/
rm -rf $__dir/_service-provider/datapusher
cd $__dir/_service-provider/
tar -xf datapusher-006.tar.gz && rm datapusher-006.tar.gz
mv datapusher-0.0.6 datapusher

echo "configuring datapusher..."
perl -pi -e 's|/tmp/|/root/datapusher/|' datapusher/deployment/datapusher_settings.py
