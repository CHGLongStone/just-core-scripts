#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#######################################
# load the utils script
# clean up and complete
# - symbolic links for dependency scripts
# - remove base dir redundant files
# 
# 
# 


#######################################
source "$DIR/"management_utils.sh

#source "$DIR/"env_config.sh


function usage(){

	echo -e "
	${GREEN}usage: $0 options${NC}
	make sure you run this in your sand box directory

	
	This installs the tool box for https://github.com/CHGLongStone/just-core-stub projects, 
	- git clone a copy of trunk/master
	- create a branch for the user
	- set vhost configuration
	
	
	${YELLOW} OPTIONS: ${NC}
	 
	${YELLOW}	-h    ${yellow}  Show this message
	${YELLOW}	-i    ${yellow}  install composer [Y] this script is called by composer we don't need it to loop
	${YELLOW}	-t    ${yellow}  tag name
	${YELLOW}	-m    ${yellow}  execute MySQL update in v#.data.sql [Y]
	${NC}
	
	"
}





#######################################
# ARGS HAVE BEEN PASSED CHECK THE OPTIONS FIRST
#	i_flag= install y/n
#	v_flag=
#	t_flag=
#
#######################################

i_flag=
v_flag=
t_flag=
u_flag=


#echo -e ${BLUE}"$0 $#args[$@] OPTIND[$OPTIND] OPTARG[$OPTARG]"${NC}
while getopts ":v:i:u:h" name; do
	#echo -e "		${purple}FLAG:" $name "VALUE: $OPTARG${NC}"
	case $name in
		v)  v_flag=1
			VERBOSE_OUT="$OPTARG"
			v_val="$OPTARG";;	
		i)  i_flag=1
			i_val="$OPTARG";;
		u)  u_flag=1
			u_val="$OPTARG";;
		h)   usage 
		exit 2;;
	esac
done


#######################################
# 2015-04-06
# Just core scripts install script
# Using composer because
#	- we're running in a LAMP environment
#	- you need composer for the package this works with
#	- package management is easier 
#
# 	Composer home: 			https://getcomposer.org
# 	interactive quick ref:  	http://composer.json.jolicode.com/
# 
# 
# STEPS:
# - install composer 
# - self update
# - install dependencies (composer.json)
#
# safe to re-run 
# 
# 
#######################################


#######################################
#validate the input - check the environment is set
#######################################

if [ ! -z "$i_flag" ] && [ "$i_val" == "Y" ]; then
	echo -e "${GREEN} INSTALL COMPOSER ${NC}" 
	curl -sS https://getcomposer.org/installer | php
	php composer.phar self-update
	COMPOSER_VENDOR_DIR=lib php composer.phar install
	COMPOSER_VENDOR_DIR=lib php composer.phar update	
else
	echo -e "${YELLOW}COMPOSER NOT RUN ${NC}" 
	
fi


#######################################
# SCHEMA SYNCRONIZATION
# SchemaSyncWrapper.sh
#
# DB Differentiation
# this can work upstream/downstream to diff the schema of your data stores
# basic MySQL connections.
# dev and production environments are added by default 
# add other environments by prefix 
# - db_config.dev
# - db_config.prod
# - db_config.uat
# 
# you will still propagate to environments in a serial fashion
# 
#
# 
#######################################


echo -e "${GREEN}DEFAULT CONFIGURATION FILES ${NC}" 
source "$DIR/"install_config.sh

echo -e "${GREEN} CHECK SYMBOLIC LINKS ${NC}" 
echo -e "${CYAN} composer added scripts ${NC}" 

file="mysql-sync-db.sh"
if [ -f $file ]; then	
	echo -e "${CYAN} $file EXISTS ${NC}" 
else
	
	echo -e "${CYAN} $file RELATIVE PATH CREATED  ${NC}" 
	ln -s lib/chglongstone/mysql-db-sync/mysql-sync-db.sh mysql-sync-db.sh
	
fi

exit 0
