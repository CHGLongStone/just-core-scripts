#!/bin/bash


#######################################
# 2015-04-06
# Just core scripts install script
# - install composer 
# - self update
# - install dependencies 
#
# safe to re-run 
# 
# Composer home: 			https://getcomposer.org
# interactive quick ref:  	http://composer.json.jolicode.com/
# 
#######################################

curl -sS https://getcomposer.org/installer | php


php composer.phar self-update
COMPOSER_VENDOR_DIR=lib php composer.phar install
COMPOSER_VENDOR_DIR=lib php composer.phar update

echo "set your conf files...."
cp lib/chglongstone/mysql-db-sync/my.dev.base lib/chglongstone/mysql-db-sync/my.dev.cnf 
echo "lib/chglongstone/mysql-db-sync/my.dev.cnf"
cat lib/chglongstone/mysql-db-sync/my.dev.cnf
echo ""

cp lib/chglongstone/mysql-db-sync/my.prod.base lib/chglongstone/mysql-db-sync/my.prod.cnf 
echo "lib/chglongstone/mysql-db-sync/my.prod.cnf"
echo ""
cat lib/chglongstone/mysql-db-sync/my.prod.cnf
echo ""