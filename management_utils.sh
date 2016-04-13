#!/bin/bash
# management_utils.sh
# Utilities (version 1)
# Jason Medland <jason.medland@gmail.com>


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


#######################################
# set display options
#######################################
bakred='\e[41m'   # Red
# Define some colors first:
red='\e[0;31m'
RED='\e[1;31m'
green='\e[0;32m'
GREEN='\e[1;32m'
yellow='\e[0;33m'
YELLOW='\e[1;33m'
blue='\e[0;34m'
BLUE='\e[1;34m'
purple='\e[0;35m'
PURPLE='\e[1;35m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
grey='\e[0;37m'
GREY='\e[1;37m'
nc='\e[0m'              # No Color
NC='\e[0m'              # No Color






#######################################
### FUNCTIONS ###
#######################################


#######################################
# send_email options
# Arg1 - Subject
# Arg2 - Body
#
#######################################
send_email() {
	#echo -e "Arg0 - Subject: "$0
	#echo -e "Arg1 - Subject: "$1
	#echo -e "Arg2 - Body: "$2
	#echo -e "Arg3 - Sendlist: "$3
	#echo -e "Arg4 - Sendlist: "$4
	Subject=$subjectPreface"-"$1
	
	if [ -z "$1" ]; then
		Subject=$Subject"$thisScript-FAILED-TO-SEND-NOTIFICATION-Subject-arg1-$1-arg2-$2"
	fi
		
	
	if [ -z "$2" ]; then	
		Subject=$Subject"-$thisScript-FAILED-TO-SEND-NOTIFICATION-Body"
	fi
	 
	#if [ [ -f $2 ]]; then
	#else
	#fi
	#echo "93"
	#echo "2: $2"
	[ -f $2 ] && LOG_FILE=$(cat $2)
	#echo "95"
	#echo "2: $2"
	#echo "LOG_FILE: $LOG_FILE"
	
		

	
		Body="User: $thisUser \n
		Script: $thisScript\n
		2: $2
		LOG_FILE: $LOG_FILE
		"
	
	#echo "Subject--"$Subject
	#echo "Body--"$Body
	#echo "111"
	if [ -z "$3" ]; then
		echo "113"
		echo -e $Body | mail  -s $Subject" - `date +%F`" $3
	else
		echo "116"
		echo -e $Body | mail  -s $Subject" - `date +%F`" $receiver_emails
	fi
  
 
}

#######################################
# if the file doesn't exist 
#######################################
check_file(){


	echo
}



