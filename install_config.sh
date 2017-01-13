#!/bin/bash
# install_config.sh
#
# Utilities (version 1)
# Jason Medland <jason.medland@gmail.com>
##########################################
# run this file to copy the *.base files into shell scripts
# then modify your entries... basic MySQL connections
#
# create multiple environment configurations by appending an extension 
#
#
#
##########################################
file="email_config.sh"
if [ -f $file ]; then	
	echo -e "${CYAN} $file EXISTS ${NC}" 
else
	cp email_config.base email_config.sh
	echo -e "${CYAN} $file CREATED  ${NC}" 
	
fi

##########################################
file="env_config.sh"
if [ -f $file ]; then	
	echo -e "${CYAN} $file EXISTS ${NC}" 
else
	cp env_config.base env_config.sh
	echo -e "${CYAN} $file CREATED  ${NC}" 
	
fi


