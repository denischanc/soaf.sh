################################################################################
################################################################################

SOAF_USER_SH_DIR=$(dirname $(realpath $(which $0)))

soaf_info_add_var SOAF_USER_SH_DIR

SOAF_USER_MAP="soaf_user"

################################################################################
################################################################################

soaf_def_user() {
	local VERSION_FN=$1
	local VAR_PRE=$2
	local USAGE_VAR_LIST=$3
	local INIT_FN=$4
	soaf_map_extend $SOAF_USER_MAP "VERSION_FN" $VERSION_FN
	soaf_map_extend $SOAF_USER_MAP "INIT_FN" $INIT_FN
	soaf_map_extend $SOAF_USER_MAP "VAR_PRE" $VAR_PRE
	soaf_map_extend $SOAF_USER_MAP "USAGE_VAR_LIST" "$USAGE_VAR_LIST"
}
