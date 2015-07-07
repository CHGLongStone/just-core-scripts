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
while getopts ":v:t:m:h" name; do
	echo -e "		${purple}FLAG:" $name "VALUE: $OPTARG${NC}"
	#execution_string=$execution_string" -"$name" $OPTARG"
	case $name in
		v)  vflag=1
			VERBOSE_OUT="$OPTARG"
			vval="$OPTARG";;	
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

$release_dir 

#######################################
#check out the project
#######################################
cd $release_dir

if [[ "$release_dir" == "$PWD" ]]; then
	echo -e "${GREEN}GO TO WORK HERE${NC} PWD-" $PWD "   release_dir-" $release_dir
	#ls -lah $release_dir
else
	echo -e "${red}NO WORKING DIRECTORY GIVEN${NC} PWD-" $PWD "   release_dir-" $release_dir
	usage
	exit 2
fi
#######################################
# VERIFY THE RELEASE DOESNT ALREADY EXIST
#######################################
INSTALL_PATH=$release_dir/$tval 
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

cd $release_dir/$tval
git checkout $tval

#######################################
#	* setting a maintenance notice in the existing `[project_name]/` directory 
#######################################

cp "$prod_dir"/update_notice.php "$prod_dir"/update.php 

#######################################
#initialize the project
#	* updates composer in the new checkout 
#######################################
echo -e "${green}EXECUTING COMPOSER INSTALL  ${NC}'"$tval"'"
composer_self_update_notes=`php composer.phar self-update`
composer_install_notes=`php composer.phar install`
composer_update_notes=`php composer.phar update`





#######################################
#	* copying any files in `CONFIG/AUTOLOAD/` with the mask of `*.global.php` into `[project_name]_release/cfg/`
#		* consuming upstream changes
#		* preserving local changes (with the mask of `*.local.php` )
#######################################
echo -e "${green}UPDATING CONFIGURATION FILES  ${NC}'"$tval"'"

cp -R -f $release_dir/$tval/CONFIG/AUTOLOAD/*.global.php $release_dir/cfg/


#######################################
#	* creating the symlink `AUTOLOAD -> ../../cfg`
#######################################
rm -R -f $release_dir/$tval/CONFIG/AUTOLOAD
ln -s $release_dir/cfg/ $release_dir/$tval/CONFIG/AUTOLOAD


#######################################
#	* doing any database operations
#######################################
if [ ! -z "$mflag" ] && [ "$mval" == "Y" ]; then
	file="$release_dir/$tval/data/updates/$tval.schema.sql"
	echo -e "${green}EXECUTING SQL UPDATE WTIH ${NC} $file"   
	[ -f $file ] && SQLUPDATE=`mysql --defaults-file=$DIR/lib/chglongstone/mysql-db-sync/my.prod.cnf <  "$file" 2>&1;`
	echo -e "${green}UPDATE RESULT ${NC} $SQLUPDATE"   
	
else
	echo -e "${red}NO SQL SCHEMA CHANGE EXECUTED${NC}" 
fi


if [ ! -z "$mflag" ] && [ "$mval" == "Y" ]; then
	file=" $release_dir/$tval/data/updates/$tval.data.sql"
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
rm -R -f $release_dir/current
ln -s $release_dir/$tval $release_dir/current
chown $app_user:$app_group -R $release_dir

#######################################
#	* maintenance notice is automatically taken down
#######################################





















