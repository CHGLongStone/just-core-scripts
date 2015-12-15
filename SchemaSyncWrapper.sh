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


#######################################
# load the utils script
#######################################
source "$DIR/"management_utils.sh

source "$DIR/"db_config.sh

function usage(){

	echo -e "
	"${GREEN}"usage: $0 options"${NC}"
	
	This creates a SQL *diff* between 2 databases , 
	- git clone a copy of trunk/master
	- create a branch for the user
	- set vhost configuration
	
	\033[1m OPTIONS:\033[0m 
	\033[1m	-h \033[0m     Show this message
	\033[1m	-l \033[0m     log directory (local $DIR  if not otherwise specified)
	\033[1m	-t \033[0m     target name
	\033[1m	-s \033[0m     source name
	
	
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
		l)  lflag=1
			lval="$OPTARG";;
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
#######################################

if [ ! -z "$lflag" ]; then
	LOG_DIR=$lval
	echo -e "${purple} LOG_DIR SET:" $lval "{NC}"
else
	LOG_DIR=$DIR
	echo -e "${purple}NO LOG_DIR SET using :" $DIR "{NC}"
fi

if [ ! -z "$sflag" ] || [ ! -z "$tflag" ] || ; then
	echo -e "${RED}source:" $sval " OR target :" $tval " MISSING{NC}"
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
file `$DIR/db_config.$sval`

if [ -f $file ]; then 
	sync_source="mysql://${hostdata[USER]}:${hostdata[PASS]}@${hostdata[SERVER]}:${hostdata[PORT]}/${hostdata[DATABASE]}"
else
	echo "failed to load target db_config.$sval"
fi


file `$DIR/db_config.$tval`
if [ -f $file ]; then 
	sync_target="mysql://${hostdata[USER]}:${hostdata[PASS]}@${hostdata[SERVER]}:${hostdata[PORT]}/${hostdata[DATABASE]}"
else
	echo "failed to load target db_config.$tval"
fi


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
file=`ls ${hostdata[DATABASE]}.*.patch.sql 2> /dev/null`
if [ -f "${file}" ]; then
   echo "File $file created. Check into Source Control";
else
   echo "Schemas identical";
   rm $LOG_DIR/schemasync.log
fi
exit 0;