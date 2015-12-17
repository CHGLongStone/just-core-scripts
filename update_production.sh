#!/bin/bash
# update_production.sh
#
# Utilities (version 1)
# Jason Medland <jason.medland@gmail.com>
##########################################
# run this file to update your production release
# assumes structure defined in README.md was followed
# and env_config.sh has been updated
#
##########################################


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


#######################################
# load the utils script
#######################################
source "$DIR/"management_utils.sh

source "$DIR/"env_config.sh


function usage(){

	echo -e "
	"${GREEN}"usage: $0 options"${NC}"
	make sure you this in your sand box directory

	
	This creates a developer sandbox, 
	- git clone a copy of trunk/master
	- create a branch for the user
	- set vhost configuration
	
	\033[1m OPTIONS:\033[0m 
	\033[1m	-h \033[0m     Show this message
	\033[1m	-e \033[0m     environment name [uat/prod]
	\033[1m	-t \033[0m     tag name
	\033[1m	-m \033[0m     execute MySQL update in v#.data.sql [Y]
	
	"
}


#######################################
# ARGS HAVE BEEN PASSED CHECK THE OPTIONS FIRST
#######################################

vflag=
tflag=


#echo -e ${BLUE}"$0 $#args[$@] OPTIND[$OPTIND] OPTARG[$OPTARG]"${NC}
while getopts ":v:e:t:m:h" name; do
	echo -e "		${purple}FLAG:" $name "VALUE: $OPTARG${NC}"
	#execution_string=$execution_string" -"$name" $OPTARG"
	case $name in
		v)  vflag=1
			VERBOSE_OUT="$OPTARG"
			vval="$OPTARG";;	
		e)  eflag=1
			eval="$OPTARG";;
		t)  tflag=1
			tval="$OPTARG";;
		m)  mflag=1
			mval="$OPTARG";;
		h)   usage 
		exit 2;;
	esac
done

#######################################
#validate the input - check the tag is set
#######################################
if [ ! -z "$tflag" ]; then
	echo -e "${green}Using Tag  ${NC}'"$tval"'"
else
	echo -e "${red}NO TAG NAME SET${NC}" 
	echo echo "TAG NAME tval='" $tval "'"
	usage
	exit 2
fi

#	* checking out the release tag into directory `[project_name]_release/[release_tag]`

#$checkout_dir #env_config.sh release_dir
if [ ! -z "$eflag" ] && [ "uat" == $eval ]; then
	echo -e "${green}Using ENVIRONMENT  ${NC}$eval "
	checkout_dir=$candidate_dir
	http_serve_path=$uat_dir
else
	echo -e "${green}Using ENVIRONMENT  ${NC} PROD "
	checkout_dir=$release_dir
	http_serve_path=$prod_dir
fi
echo -e "${green}checkout_dir[$checkout_dir] http_serve_path[$http_serve_path] ${NC} PROD "

#######################################
#check out the project
#######################################
cd $checkout_dir

if [[ "$checkout_dir" == "$PWD" ]]; then
	echo -e "${GREEN}GO TO WORK HERE${NC} PWD-" $PWD "   checkout_dir-" $checkout_dir
	#ls -lah $checkout_dir
else
	echo -e "${red}NO WORKING DIRECTORY GIVEN${NC} PWD-" $PWD "   checkout_dir-" $checkout_dir
	usage
	exit 2
fi
#######################################
# VERIFY THE RELEASE DOESNT ALREADY EXIST
#######################################
INSTALL_PATH=$checkout_dir/$tval 
if [[ -d $INSTALL_PATH ]]; then
	echo -e "${red}CAN NOT RE-INSTALL $tval ${NC}" 
	exit 1
fi
#exit 0
#######################################
#check out the project
#######################################
echo -e "${green}EXECUTING GIT CLONE  ${NC}'"$tval"'"
git clone  $project_path "$tval"

cd $checkout_dir/$tval
git checkout $tval

#######################################
#	* setting a maintenance notice in the existing `[project_name]/` directory 
#######################################

cp "$http_serve_path"/update_notice.php "$http_serve_path"/update.php 

#######################################
#initialize the project
#	* updates composer in the new checkout 
#######################################
echo -e "${green}EXECUTING COMPOSER INSTALL  ${NC}'"$tval"'"
curl -sS https://getcomposer.org/installer | php
composer_self_update_notes=`php composer.phar self-update`
composer_install_notes=`php composer.phar install`
composer_update_notes=`php composer.phar update`





#######################################
#	* copying any files in `CONFIG/AUTOLOAD/` with the mask of `*.global.php` into `[project_name]_release/cfg/`
#		* consuming upstream changes
#		* preserving local changes (with the mask of `*.local.php` )
#######################################
echo -e "${green}UPDATING CONFIGURATION FILES  ${NC}'"$tval"'"

cp -R -f $checkout_dir/$tval/CONFIG/AUTOLOAD/*.global.php $checkout_dir/cfg/


#######################################
#	* creating the symlink `AUTOLOAD -> ../../cfg`
#######################################
rm -R -f $checkout_dir/$tval/CONFIG/AUTOLOAD
ln -s $checkout_dir/cfg/ $checkout_dir/$tval/CONFIG/AUTOLOAD



#######################################
# check out the documentation
#######################################
cd $checkout_dir/$tval
git clone  git@github.com:CHGLongStone/blackwatch.wiki.git blackwatch.wiki


#######################################
#	* doing any database operations
#######################################
if [ ! -z "$mflag" ] && [ "$mval" == "Y" ]; then
	file="$checkout_dir/$tval/data/updates/$tval.schema.sql"
	echo -e "${green}EXECUTING SQL UPDATE WTIH ${NC} $file"   
	[ -f $file ] && SQLUPDATE=`mysql --defaults-file=$DIR/lib/chglongstone/mysql-db-sync/my.prod.cnf <  "$file" 2>&1;`
	echo -e "${green}UPDATE RESULT ${NC} $SQLUPDATE"   
	
else
	echo -e "${red}NO SQL SCHEMA CHANGE EXECUTED${NC}" 
fi


if [ ! -z "$mflag" ] && [ "$mval" == "Y" ]; then
	file=" $checkout_dir/$tval/data/updates/$tval.data.sql"
	echo -e "${green}EXECUTING SQL UPDATE WTIH ${NC} $file"   
	[ -f $file ] && SQLUPDATE=`mysql --defaults-file=$DIR/lib/chglongstone/mysql-db-sync/my.prod.cnf <  "$file" 2>&1;`
	echo -e "${green}UPDATE RESULT ${NC} $SQLUPDATE"   
	
else
	echo -e "${red}NO SQL RECORD UPDATE EXECUTED${NC}" 
fi

#######################################
#	* deleting and recreating the symlink `[project_name]_release/current` to the updated release version
#######################################
echo $tval > build.txt
rm -R -f $checkout_dir/current
ln -s $checkout_dir/$tval $checkout_dir/current
chown $app_user:$app_group -R $checkout_dir

#######################################
#	* maintenance notice is automatically taken down
#######################################





















