#!/bin/sh
# SchemaSyncWrapper (version 1)
# Jason Medland <jason.medland@gmail.com>
##########################################
# dependancy:
#	https://github.com/mmatuson/SchemaSync
#	
#
# assumes structure defined in README.md was followed
# and db_config.base was copied and recreated for each data base
#
##########################################


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

OUTPUT_PATH="/var/www/vhosts/blackwatch_dev/data/updates/"

#######################################
# load the utils script
#######################################
source "$DIR/"management_utils.sh

#source "$DIR/"db_config.sh

function usage(){

	echo -e "
	"${GREEN}"usage: $0 options"${NC}"
	
	This creates a SQL *diff* between 2 databases , 
	- git clone a copy of trunk/master
	- create a branch for the user
	- set vhost configuration
	
	\033[1m OPTIONS:\033[0m 
	\033[1m	-h \033[0m     Show this message
	\033[1m	-l \033[0m     log directory 
							(local $DIR  if not otherwise specified)
	\033[1m	-r \033[0m     redirect 
							(redirect the generated *.patch.sql and *.revert.sql files. 
							 pushes them to the path defined in OUTPUT_PATH in this file
							 $OUTPUT_PATH.[revert/patch].sql
							 )
	\033[1m	-s \033[0m     source name
	\033[1m	-t \033[0m     target name
	
	
	"
}


#######################################
# ARGS HAVE BEEN PASSED CHECK THE OPTIONS FIRST
#######################################

vflag=
tflag=


#echo -e ${BLUE}"$0 $#args[$@] OPTIND[$OPTIND] OPTARG[$OPTARG]"${NC}
while getopts ":v:l:r:s:t:h" name; do
	echo -e "		${purple}FLAG:" $name "VALUE: $OPTARG ${NC}"
	#execution_string=$execution_string" -"$name" $OPTARG"
	case $name in
		v)  vflag=1
			VERBOSE_OUT="$OPTARG"
			vval="$OPTARG";;	
		l)  lflag=1
			lval="$OPTARG";;
		r)  rflag=1
			rval="$OPTARG";;
		s)  sflag=1
			sval="$OPTARG";;
		t)  tflag=1
			tval="$OPTARG";;
		h)   usage 
		exit 2;;
	esac
done



#######################################
# validate params
#
# set the log dir 
#######################################
if [ ! -z "$lflag" ]; then
	LOG_DIR=$lval
	echo -e "${purple} LOG_DIR SET:" $lval " ${NC}"
else
	LOG_DIR=$DIR
	echo -e "${purple}NO LOG_DIR SET using :" $DIR " ${NC}"
fi

#######################################
# check the redirect flag (copy the sql files to repo)
#######################################
if [ ! -z "$rflag" ] ; then
	echo -e "${GREEN}redirect: prefix $rval  to $OUTPUT_PATH ${NC}"
else
	echo -e "${RED}NO redirect: $rval writing files to local dir ${NC}"
	#exit 1;
fi

#######################################
# set the soruce DB
#######################################
if [ ! -z "$sflag" ] ; then
	echo -e "${GREEN}source: $sval  FOUND ${NC}"
else
	echo -e "${RED}source: $sval  MISSING ${NC}"
	exit 1;
fi


#######################################
# set the target DB
#######################################
if [ ! -z "$tflag" ]; then
	echo -e "${GREEN}target: $tval  FOUND ${NC}"
else
	echo -e "${RED}target: $tval  MISSING ${NC}"
	exit 1;
fi


#######################################
# Clean up first
########################################
rm -f $DIR/*$sflag*.sql $LOG_DIR/schemasync.log

########################################
# verify there is a config file for the source and target databases
# generate the commands for schemasync 
# This will compare the two databases and create a migration script to upgrade from
# one to the other.
########################################
file="$DIR/db_config.$sval"
#echo "file $file"
#echo "hostdata $hostdata"

if [ -f $file ]; then 
	source $file
	sync_source="mysql://${hostdata[USER]}:${hostdata[PASS]}@${hostdata[SERVER]}:${hostdata[PORT]}/${hostdata[DATABASE]}"
	echo -e "${GREEN}sync_source ${hostdata[SERVER]}.${hostdata[DATABASE]} ${NC}"
else
	echo -e "${RED}failed to load target db_config.$sval ${NC}"
fi


file="$DIR/db_config.$tval"
#echo -e "file $file"

if [ -f $file ]; then 
	source $file
	sync_target="mysql://${hostdata[USER]}:${hostdata[PASS]}@${hostdata[SERVER]}:${hostdata[PORT]}/${hostdata[DATABASE]}"
	echo -e "${GREEN}sync_target ${hostdata[SERVER]}.${hostdata[DATABASE]} ${NC}"
else
	echo -e "${RED}failed to load target db_config.$tval ${NC}"
	
fi

#	schemasync [options] <source> <target>
#	source/target format: mysql://user:pass@host:port/database

schemasync $sync_source $sync_target 2> /dev/null
ec=$?

#
# If there is an error we could not connect. The erro will be in the log file.
#
if [ "$ec" -ne 0 ]; then
   cat $LOG_DIR/schemasync.log
   exit $ec;
fi

#
# If we are here we will look for the schema scripts. If they exist then 
# the schemas were not the same.
#
set=`chmod 1755 ${hostdata[DATABASE]}.*.sql 2> /dev/null`
patch=`ls ${hostdata[DATABASE]}.*.patch.sql 2> /dev/null`
revert=`ls ${hostdata[DATABASE]}.*.revert.sql 2> /dev/null`


if [ -f "${patch}" ]; then
   echo "File $patch created. Check into Source Control";
	if [ ! -z "$rflag" ] ; then
		echo -e "${GREEN}redirect:  $DIR/${patch} $OUTPUT_PATH$rval.patch.sql${NC}"
		cp -R "$DIR/${patch}"  "$OUTPUT_PATH$rval.patch.sql"

		echo -e "${GREEN} ${revert}                 $OUTPUT_PATH$rval.revert.sql ${NC}"
		cp -R "$DIR/${revert}"  "$OUTPUT_PATH$rval.revert.sql"
		#echo -e "${GREEN}${revert}                  $OUTPUT_PATH$rval.revert.sql ${NC}"
		
	else
		echo -e "${RED}redirect: $OUTPUT_PATH$rval  MISSING ${NC}"
		exit 1
	fi
   
   
   
   
else
   echo "Schemas identical";
   rm $LOG_DIR/schemasync.log
fi
exit 0;