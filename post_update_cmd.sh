#!/bin/bash
# https://getcomposer.org/doc/articles/scripts.md
# Command Events# post-update-cmd
# Utilities (version 1)
# Jason Medland <jason.medland@gmail.com>


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


#######################################
# load the utils script
#######################################
source "$DIR/"management_utils.sh
echo  -e "${CYAN} ${0##*/} ${NC}";
echo "post-update-cmd"

echo "post-update-cmd" >> test.file