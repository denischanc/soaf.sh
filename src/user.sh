################################################################################
################################################################################

SOAF_USER_SH_DIR=$(dirname $(realpath $(which $0)))

SOAF_USER_NAME_ATTR="soaf_user_name"
SOAF_USER_VERSION_ATTR="soaf_user_version"
SOAF_USER_VAR_PRE_ATTR="soaf_user_var_pre"
SOAF_USER_USAGE_VAR_LIST_ATTR="soaf_user_usage_var_list"
SOAF_USER_CFG_FN_ATTR="soaf_user_cfg_fn"
SOAF_USER_INIT_FN_ATTR="soaf_user_init_fn"
SOAF_USER_PREPENV_FN_ATTR="soaf_user_prepenv_fn"

SOAF_USER_ATTR_LIST="NAME VERSION VAR_PRE USAGE_VAR_LIST CFG_FN INIT_FN"
SOAF_USER_ATTR_LIST="$SOAF_USER_ATTR_LIST PREPENV_FN"

################################################################################
################################################################################

soaf_user_init() {
	soaf_info_add_var SOAF_USER_SH_DIR
}

soaf_engine_add_init_fn soaf_user_init

################################################################################
################################################################################

soaf_create_user_nature() {
	local NATURE=$1
	local NAME=${2:-$SOAF_NAME}
	local VERSION=$3
	local VAR_PRE=$4
	local USAGE_VAR_LIST=$5
	local CFG_FN=$6
	local INIT_FN=$7
	local PREPENV_FN=$8
	local attr
	for attr in $SOAF_USER_ATTR_LIST
	do
		eval soaf_map_extend $NATURE \$SOAF_USER_${attr}_ATTR \"\$$attr\"
	done
}
