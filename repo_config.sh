#!/bin/bash
#######################################
# 2016-02-20
# basic configuration script 
#######################################

RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
PURPLE='\e[1;35m'
CYAN='\e[1;36m'
GREY='\e[1;37m'
NC='\e[0m'              # No Color
MUTED='\e[1;22m'             # HELLO!!
DAFUQ='\e[0m'              # DAFUQ!!


#######################################
# PERMS
# depends on your environment...
# as long as your application server is in the same group as your server user
# you can tighten the perms down as much as you need to
#  - this is just a maintenance/helper script 
# 
#######################################
TIGHT_PERM="644"
SANDBOX_PERM="750"
USER_EX_PROTECTED="744"
GROUP_EX_PROTECTED="754"
LOOSE_PERM="755"
PROJECT_DEF_PERM=$LOOSE_PERM


#######################################
# PATHS
# depends on your environment...
#expecting it to be available in the user home directory here
#######################################
just_core_scripts="$HOME/just-core-scripts"

WORKING_DIR="/var/www/vhosts/blackwatch_dev/"
#######################################
# active project directories
#######################################
declare -A WORKING_DIRS
#
WORKING_DIRS["APIS"]=$PROJECT_DEF_PERM
WORKING_DIRS["CONFIG"]=$PROJECT_DEF_PERM
WORKING_DIRS["HTTP_ASSETS"]=$PROJECT_DEF_PERM
WORKING_DIRS["SERVICES"]=$PROJECT_DEF_PERM
WORKING_DIRS["TEMPLATES"]=$PROJECT_DEF_PERM
WORKING_DIRS["data"]=$PROJECT_DEF_PERM

#######################################
# dependency list
#######################################
BLACKWATCH_DEP_DIR_LIST="
vendor/just-core/auth-login/
vendor/just-core/auth-page/
vendor/just-core/cli-harness/
vendor/just-core/dao-orm/
vendor/just-core/data-postgres/
vendor/just-core/foundation/
vendor/just-core/http-optimization/
vendor/just-core/metronic/
./
"






