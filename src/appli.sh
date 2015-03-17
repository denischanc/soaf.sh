################################################################################
################################################################################

SOAF_APPLI_SH_DIR=$(dirname $(realpath $(which $0)))

SOAF_APPLI_NAME_ATTR="soaf_appli_name"
SOAF_APPLI_MODULE_NAME_ATTR="soaf_appli_module_name"

################################################################################
################################################################################

soaf_appli_init() {
	soaf_info_add_var SOAF_APPLI_SH_DIR
}

soaf_define_add_this_init_fn soaf_appli_init

################################################################################
################################################################################

soaf_create_appli_nature() {
	local NATURE=$1
	local NAME=${2:-$SOAF_NAME}
	local VERSION=$3
	local CFG_FN=$4
	local INIT_FN=$5
	local PREPENV_FN=$6
	local PRE_ACTION_FN=$7
	local POST_ACTION_FN=$8
	local EXIT_FN=$9
	local MODULE_NAME="soaf.appli.module.$NAME"
	soaf_create_module $MODULE_NAME $VERSION "$CFG_FN" "$INIT_FN" \
		"$PREPENV_FN" "$PRE_ACTION_FN" "$POST_ACTION_FN" "$EXIT_FN"
	soaf_map_extend $NATURE $SOAF_APPLI_NAME_ATTR $NAME
	soaf_map_extend $NATURE $SOAF_APPLI_MODULE_NAME_ATTR $MODULE_NAME
}
