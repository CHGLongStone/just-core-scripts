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

	${YELLOW} OPTIONS:${NC}
	${YELLOW}	-h ${yellow}     Show this message
	${YELLOW}	-e ${yellow}     environment 
	${YELLOW}	-t ${yellow}     tag name
	${YELLOW}	-m ${yellow}     execute MySQL update in v#.data.sql [Y]
	${NC}
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
			enval="$OPTARG";;
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
if [ ! -z "$eflag" ] ; then  #&& [ "uat" == $enval ]
	
	echo -e "${green}Using ENVIRONMENT  ${NC}$enval "
	test_sym_link="{$enval[\"sym_link\"]}"
	#echo -e "${green}sym_link  "${sevenV["sym_link"]}" ${NC}eval $enval  test_sym_link $test_sym_link"
	#sym_link="$"$test_sym_link
	eval sym_link=\$$test_sym_link
	#echo -e "${green}-- sym_link  $sym_link "${sym_link}"  test_sym_link "${test_sym_link}"  ${NC}"
	if [ -d $sym_link ] ; then
		echo -e "${green} sym_link set  ${NC}$sym_link "
		http_serve_path=$sym_link		
	fi
	
	test_app_dir="{$enval[\"app_dir\"]}"
	eval app_dir=\$$test_app_dir
	#echo -e "${green}app_dir  "${sevenV["app_dir"]}" ${NC}eval $enval  test_app_dir $test_app_dir"
	if [ -d $app_dir ] ; then
		echo -e "${green} app_dir set  ${NC}$app_dir "
		checkout_dir=$app_dir
	fi
	
	
else
	echo -e "${RED}NO  ENVIRONMENT  ${NC} "
	#checkout_dir=$release_dir
	#http_serve_path=$prod_dir
	exit;
fi
#echo -e "${green}checkout_dir[$checkout_dir] http_serve_path[$http_serve_path] ${NC} PROD "


echo -e "${RED}DIE HERE  ${NC} PROD "







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
# check out the documentation...or anything external to the core application
#######################################
cd $checkout_dir/$tval
git clone  git@github.com:CHGLongStone/blackwatch.wiki.git blackwatch.wiki


#######################################
#	* doing any database operations
#######################################
if [ ! -z "$mflag" ] && [ "$mval" == "Y" ]; then
	#file="$checkout_dir/$tval/data/updates/$tval.schema.sql"
	#file="$checkout_dir/$tval/data/updates/$tval"_"$enval.patch.sql" 
	#v1.0.3 	/v1.0.3.patch.uat.from.dev.sql
	file="$checkout_dir/$tval/data/updates/$tval.patch.$enval.from.dev.sql"
	echo -e "${green}EXECUTING SQL UPDATE WTIH ${NC} my.$enval.cnf $file"   
	[ -f $file ] && SQLUPDATE=`mysql --defaults-file=$DIR/lib/chglongstone/mysql-db-sync/my.$enval.cnf <  "$file" 2>&1;`
	echo -e "${green}UPDATE RESULT ${NC} $SQLUPDATE"   
	SQLUPDATE=""
else
	echo -e "${red}NO SQL SCHEMA CHANGE EXECUTED${NC}" 
fi


if [ ! -z "$mflag" ] && [ "$mval" == "Y" ]; then
	file=" $checkout_dir/$tval/data/updates/$tval.data.$enval.from.dev.sql"
	echo -e "${green}EXECUTING SQL UPDATE WTIH ${NC} my.$enval.cnf $file"   
	[ -f $file ] && SQLUPDATE=`mysql --defaults-file=$DIR/lib/chglongstone/mysql-db-sync/my.$enval.cnf <  "$file" 2>&1;`
	echo -e "${green}UPDATE RESULT ${NC} $SQLUPDATE"   
	SQLUPDATE=""
	
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





















