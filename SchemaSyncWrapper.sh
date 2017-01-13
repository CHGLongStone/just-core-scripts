#!/bin/sh
# SchemaSyncWrapper (version 1)
# Jason Medland <jason.medland@gmail.com>
##########################################
# dependency:
#	https://github.com/mmatuson/SchemaSync
#	
#
# assumes structure defined in README.md was followed
# and db_config.base was copied and recreated for each data base
#
##########################################


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

OUTPUT_PATH="./data/updates/"

#######################################
# load the utils script
#######################################
source "$DIR/"management_utils.sh

SKIP="yes"
#######################################
# whoami 
#######################################
echo  -e "${CYAN} ${0##*/} ${NC}";
#source "$DIR/"db_config.sh

function usage(){

	echo -e "
	"${GREEN}"usage: $0 options"${NC}"
	
	This creates a SQL *diff* between 2 databases , 
	- git clone a copy of trunk/master
	- create a branch for the user
	- set vhost configuration
	
	 OPTIONS:
	\033[1m	-h \033[0m     Show this message
	\033[1m	-n \033[0m     passthrough arg --tag=
	\033[1m	-d \033[0m     passthrough arg --output-directory=
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
declare -A OPTS_MAPPING
#
OPTS_MAPPING["v"]="verbose"
OPTS_MAPPING["d"]="output Directory"
OPTS_MAPPING["l"]="Log directory"
OPTS_MAPPING["n"]="tag Name"
OPTS_MAPPING["r"]="redirect"
OPTS_MAPPING["s"]="source db"
OPTS_MAPPING["t"]="target db"
OPTS_MAPPING["h"]="usage"

#echo -e ${BLUE}"$0 $#args[$@] OPTIND[$OPTIND] OPTARG[$OPTARG]"${NC}
while getopts ":v:d:n:l:r:s:t:h" name; do
	#echo -e "		${purple} $name: [" ${OPTS_MAPPING[$name]}  "]: $OPTARG ${NC}"
	
	case $name in
		v)  vflag=1
			VERBOSE_OUT="$OPTARG"
			vval="$OPTARG";;	
		d)  dflag=1
			dval="$OPTARG";;
		l)  lflag=1
			lval="$OPTARG";;
		n)  mflag=1
			mval="$OPTARG";;
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
# check the redirect flag (copy the sql files to repo)
# deprecate this redirect and use the flags
#######################################
#if [ ! -z "$rflag" ] ; then
#	echo -e "${GREEN}redirect: prefix $rval  to $OUTPUT_PATH ${NC}"
#else
#	echo -e "${RED}NO redirect: $rval writing files to local dir ${NC}"
	#exit 1;
#fi

#######################################
# do some basic path setting
#	default OUTPUT_PATH is hard coded to this project
#	if we're using the -d PASSTHROUGH arg we'll set the OUTPUT_PATH_FINAL
#	
#	
#	
#######################################

if [ -z "$dval" ] ; then
	echo -e "${RED}output_directory: $dval  MISSING ${NC}"
	OUTPUT_PATH_FINAL=$OUTPUT_PATH
else
	#echo -e "${GREEN}output_directory: $dval  SET ${NC}"
	OUTPUT_PATH_FINAL=$dval
fi


#######################################
# validate params
# set the log dir, by default the just-core-scripts dir
#
#######################################
if [ ! -z "$lflag" ]; then
	LOG_DIR=$lval
	#echo -e "${purple} LOG_DIR SET:" $lval " ${NC}"
else
	LOG_DIR=$DIR
	if [ ! -z "$vflag" ]; then
		echo -e "${purple}	NO LOG_DIR SET using :" $DIR " ${NC}"
	fi
	
fi



#######################################
# set the source DB
#######################################
if [ ! -z "$sflag" ] ; then
	#echo -e "${GREEN}source: $sval  FOUND ${NC}"
	SKIP="yes"
else
	echo -e "${RED}source: $sval  MISSING ${NC}"
	exit 1;
fi


#######################################
# set the target DB
#######################################
if [ ! -z "$tflag" ]; then
	SKIP="yes"
	#echo -e "${GREEN}target: $tval  FOUND ${NC}"
else
	echo -e "${RED}target: $tval  MISSING ${NC}"
	exit 1;
fi

#######################################
# PASSTHROUGH ARGS
#	--output-directory
#	--tag
#	
#######################################
output_directory="--output-directory=$dval"
if [ ! -z "$dflag" ]; then
	#$output_directory=` --output-directory=$dval `
	SKIP="yes"
	#echo -e "${GREEN} output_directory "$output_directory"  FOUND ${NC}"
else
	$output_directory=""
	echo -e "${RED}output_directory $dval  MISSING ${NC}"
	exit 1;
fi

tag_output="--tag=$mval"
if [ ! -z "$mflag" ]; then
	SKIP="yes"
	#echo -e "${GREEN}tag_output "$tag_output"  FOUND ${NC}"
else
	$tag_output=""
	echo -e "${RED} tag_output $mval  MISSING ${NC}"
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
echo "file $file"
echo "hostdata $hostdata"

if [ -f $file ]; then 
	source $file
	sync_source="mysql://${hostdata[USER]}:${hostdata[PASS]}@${hostdata[SERVER]}:${hostdata[PORT]}/${hostdata[DATABASE]}"
	#echo -e "${GREEN}sync_source ${hostdata[SERVER]}.${hostdata[DATABASE]} ${NC}"
else
	echo -e "${RED}failed to load target db_config.$sval ${NC}"
fi


file="$DIR/db_config.$tval"
#echo -e "file $file"

if [ -f $file ]; then 
	source $file
	sync_target="mysql://${hostdata[USER]}:${hostdata[PASS]}@${hostdata[SERVER]}:${hostdata[PORT]}/${hostdata[DATABASE]}"
	#echo -e "${GREEN}sync_target ${hostdata[SERVER]}.${hostdata[DATABASE]} ${NC}"
else
	echo -e "${RED}failed to load target db_config.$tval ${NC}"
	
fi
#######################################
#	schemasync [options] <source> <target>
#	source/target format: mysql://user:pass@host:port/database
# http://mmatuson.github.io/SchemaSync/
schemasync $output_directory $tag_output $sync_source $sync_target 2> /dev/null
ec=$?
#######################################
#######################################
#
# If there is an error we could not connect. The error will be in the log file.
#
#######################################
if [ "$ec" -ne 0 ]; then
   cat $OUTPUT_PATH_FINAL/schemasync.log
   exit $ec;
fi

#######################################
# If we are here we will look for the schema scripts. If they exist then ${VERSION//.}
# the schemas were not the same.
#
#echo -e "${CYAN}revert: $OUTPUT_PATH_FINAL/${hostdata[DATABASE]}_${mval//.}.*.patch.sql ${NC}"
#######################################
echo -e "${GREEN} patch $tval FROM $sval  ${NC}"
set=`chmod 1755 $OUTPUT_PATH_FINAL/${hostdata[DATABASE]}_*.sql 2> /dev/null`
patch=`ls  $OUTPUT_PATH_FINAL/${hostdata[DATABASE]}_${mval//.}.*.patch.sql 2> /dev/null`
revert=`ls $OUTPUT_PATH_FINAL/${hostdata[DATABASE]}_${mval//.}.*.revert.sql 2> /dev/null`

#echo -e "${CYAN}revert: $OUTPUT_PATH_FINAL/${hostdata[DATABASE]}.*.sql ${NC}"

#echo -e "${CYAN}patch:  $patch  ${NC}"
#echo -e "${CYAN}revert:  $revert  ${NC}"
#######################################
# if a patch was created there is a schema difference
# 
#######################################
if [ -f "${patch}" ]; then
	#patch_new="$OUTPUT_PATH_FINAL/$mval.patch.sql"
	patch_result=` cp -R ${patch}	$OUTPUT_PATH_FINAL/$mval.patch.$tval.from.$sval.sql`
	revert_result=`cp -R ${revert}	$OUTPUT_PATH_FINAL/$mval.revert.$tval.from.$sval.sql`
	#echo -e "${YELLOW} REVERT: ${revert} $OUTPUT_PATH_FINAL/$mval.revert.sql ${NC}"
	set=`chmod 1755 $OUTPUT_PATH_FINAL/${hostdata[DATABASE]}_*.sql 2> /dev/null`
   
	echo -e "${CYAN}";
	echo	"	Files created. ";
	echo	"	Check into Source Control ";
	echo 	"	$OUTPUT_PATH_FINAL$mval.patch.$tval.from.$sval.sql ";
	echo 	"	$OUTPUT_PATH_FINAL$mval.revert.$tval.from.$sval.sql ";
	echo -e "${NC}";
   
	# clean up temp files
	rm ${patch} ${revert}
else
   echo "Schemas identical";
   rm $OUTPUT_PATH_FINAL/schemasync.log
fi
exit 0;