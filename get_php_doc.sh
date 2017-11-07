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

wget http://phpdoc.org/phpDocumentor.phar

php phpDocumentor.phar -d vendor/just-core/foundation/CORE -d vendor/just-core/auth-login -d vendor/just-core/auth-page  -d vendor/just-core/cli-harness  -d vendor/just-core/dao-orm  -d vendor/just-core/data-postgres  -d vendor/just-core/http-optimization -d vendor/just-core/metronic -t vendor/just-core/foundation/docs/api

