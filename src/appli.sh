################################################################################
################################################################################

readonly SOAF_APPLI_SH_DIR=$(cd $(dirname "$(soaf_which $0)"); pwd)
readonly SOAF_APPLI_SH_FILE=$SOAF_APPLI_SH_DIR/$(basename $0)
readonly SOAF_APPLI_SH_NAME=$(basename $0 .sh)

readonly SOAF_APPLI_NAME_ATTR="soaf_appli_name"

################################################################################
################################################################################

soaf_appli_init_() {
	soaf_info_add_var "SOAF_APPLI_SH_DIR SOAF_APPLI_SH_NAME"
}

soaf_create_module soaf.core.appli $SOAF_DIST_VERSION "" "" soaf_appli_init_

################################################################################
################################################################################

soaf_appli_def_name() {
	local NATURE=$1
	soaf_map_get $NATURE $SOAF_APPLI_NAME_ATTR
	SOAF_APPLI_NAME=$SOAF_RET
}

################################################################################
################################################################################

soaf_create_appli_nature() {
	local NATURE=$1
	local NAME=${2:-$SOAF_APPLI_SH_NAME}
	local VERSION=$3
	local CFG_FN=$4
	local INIT_FN=$5
	local PREPENV_FN=$6
	local PRE_ACTION_FN=$7
	local POST_ACTION_FN=$8
	local EXIT_FN=$9
	if [ -z "$VERSION" ]
	then
		soaf_to_upper_var $NAME
		eval VERSION=\$\{${SOAF_RET}_DIST_VERSION:-0.1.0\}
	fi
	local MODULE_NAME="soaf.appli.$NAME"
	soaf_create_module $MODULE_NAME $VERSION "" "$CFG_FN" "$INIT_FN" \
		"$PREPENV_FN" "$PRE_ACTION_FN" "$POST_ACTION_FN" "$EXIT_FN"
	soaf_map_extend $NATURE $SOAF_APPLI_NAME_ATTR $NAME
}
