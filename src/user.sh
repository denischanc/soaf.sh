################################################################################
################################################################################

SOAF_USER_SH_DIR=$(dirname $(realpath $(which $0)))

soaf_info_add_var SOAF_USER_SH_DIR

SOAF_USER_MAP="soaf_user"

SOAF_USER_VERSION_FN_ATTR="soaf_user_version_fn"
SOAF_USER_INIT_FN_ATTR="soaf_user_init_fn"
SOAF_USER_VAR_PRE_ATTR="soaf_user_var_pre"
SOAF_USER_USAGE_VAR_LIST_ATTR="soaf_user_usage_var_list"

################################################################################
################################################################################

soaf_def_user() {
	local VERSION_FN=$1
	local VAR_PRE=$2
	local USAGE_VAR_LIST=$3
	local INIT_FN=$4
	soaf_map_extend $SOAF_USER_MAP $SOAF_USER_VERSION_FN_ATTR $VERSION_FN
	soaf_map_extend $SOAF_USER_MAP $SOAF_USER_INIT_FN_ATTR $INIT_FN
	soaf_map_extend $SOAF_USER_MAP $SOAF_USER_VAR_PRE_ATTR $VAR_PRE
	soaf_map_extend $SOAF_USER_MAP $SOAF_USER_USAGE_VAR_LIST_ATTR \
		"$USAGE_VAR_LIST"
}
