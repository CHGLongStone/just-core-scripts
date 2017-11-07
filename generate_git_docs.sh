#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#######################################
# load the utils script
# clean up and complete
# - symbolic links for dependency scripts
# - remove base dir redundant files
# 
# php phpDocumentor.phar -d vendor/just-core/foundation/CORE \
#	-d vendor/just-core/auth-login 
#	-d vendor/just-core/auth-page  
#	-d vendor/just-core/cli-harness  
#	-d vendor/just-core/dao-orm  
#	-d vendor/just-core/data-postgres  
#	-d vendor/just-core/http-optimization 
#	-d vendor/just-core/metronic 
#	-t vendor/just-core/foundation/docs/api
# iteration example
# SchemaSyncWrapper.sh
# db_config.*
# https://github.com/CHGLongStone/just-core.wiki.git
# 
# 


#######################################
source "$DIR/"management_utils.sh

source "$DIR/"repo_config.sh


function usage(){

	echo -e "
	${GREEN}usage: $0 options${NC}
	run this against a list of repositories for all your related projects on github into one space to: 
		- create/update:
			wiki documentation 
			phpDocumentor docs
	
	you can use an org or user pages repository as the base
	you ca

	
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

#php phpDocumentor.phar -d vendor/just-core/foundation/CORE -d vendor/just-core/auth-login -d vendor/just-core/auth-page -t vendor/just-core/foundation/docs/api

for i in $BLACKWATCH_DEP_DIR_LIST; do 
	echo -e "${GREEN} WORKING_DIR $WORKING_DIR  i $i ${NC}"
done




#php phpDocumentor.phar -d /var/www/vhosts/blackwatch_dev/vendor/just-core/foundation/CORE -t /var/www/vhosts/blackwatch_dev/vendor/just-core/foundation/docs/api
#php phpDocumentor.phar -d /var/www/vhosts/blackwatch_dev/vendor/just-core/foundation/CORE -t /var/www/vhosts/blackwatch_dev/vendor/just-core/foundation/docs/api

exit 

php phpDocumentor.phar -d /var/www/vhosts/blackwatch_dev/vendor/just-core/foundation/CORE  \ 
	-d /var/www/vhosts/blackwatch_dev/vendor/just-core/auth-login  \
	-d /var/www/vhosts/blackwatch_dev/vendor/just-core/auth-page  \
	-d /var/www/vhosts/blackwatch_dev/vendor/just-core/cli-harness  \
	-d /var/www/vhosts/blackwatch_dev/vendor/just-core/dao-orm  \
	-d /var/www/vhosts/blackwatch_dev/vendor/just-core/data-postgres  \
	-d /var/www/vhosts/blackwatch_dev/vendor/just-core/foundation  \
	-d /var/www/vhosts/blackwatch_dev/vendor/just-core/http-optimization  \
	-d /var/www/vhosts/blackwatch_dev/vendor/just-core/metronic  \
-t /var/www/vhosts/just-core-stub/docs/api



vendor/just-core/auth-login/
vendor/just-core/auth-page/
vendor/just-core/cli-harness/
vendor/just-core/dao-orm/
vendor/just-core/data-postgres/
vendor/just-core/foundation/
vendor/just-core/http-optimization/
vendor/just-core/metronic/


php phpDocumentor.phar -d /var/www/vhosts/blackwatch_dev/vendor/just-core/ -t /var/www/vhosts/just-core-stub/docs/api
























