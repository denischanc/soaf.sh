################################################################################
################################################################################

SOAF_USER_SH_DIR=$(dirname $(realpath $(which $0)))

SOAF_USER_NAME_ATTR="soaf_user_name"
SOAF_USER_VERSION_ATTR="soaf_user_version"
SOAF_USER_CFG_FN_ATTR="soaf_user_cfg_fn"
SOAF_USER_INIT_FN_ATTR="soaf_user_init_fn"
SOAF_USER_PREPENV_FN_ATTR="soaf_user_prepenv_fn"
SOAF_USER_PRE_ACTION_FN_ATTR="soaf_user_pre_action_fn"
SOAF_USER_POST_ACTION_FN_ATTR="soaf_user_post_action_fn"

SOAF_USER_ATTR_LIST="NAME VERSION CFG_FN INIT_FN PREPENV_FN"
SOAF_USER_ATTR_LIST="$SOAF_USER_ATTR_LIST PRE_ACTION_FN POST_ACTION_FN"

################################################################################
################################################################################

soaf_user_init() {
	soaf_info_add_var SOAF_USER_SH_DIR
}

soaf_define_add_engine_init_fn soaf_user_init

################################################################################
################################################################################

soaf_create_user_nature() {
	local NATURE=$1
	local NAME=${2:-$SOAF_NAME}
	local VERSION=$3
	local CFG_FN=$4
	local INIT_FN=$5
	local PREPENV_FN=$6
	local PRE_ACTION_FN=$7
	local POST_ACTION_FN=$8
	local attr
	for attr in $SOAF_USER_ATTR_LIST
	do
		eval soaf_map_extend $NATURE \$SOAF_USER_${attr}_ATTR \"\$$attr\"
	done
}
