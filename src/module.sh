################################################################################
################################################################################

SOAF_MODULE_VERSION_ATTR="soaf_module_version"
SOAF_MODULE_CFG_FN_ATTR="soaf_module_cfg_fn"
SOAF_MODULE_INIT_FN_ATTR="soaf_module_init_fn"
SOAF_MODULE_PREPENV_FN_ATTR="soaf_module_prepenv_fn"
SOAF_MODULE_PRE_ACTION_FN_ATTR="soaf_module_pre_action_fn"
SOAF_MODULE_POST_ACTION_FN_ATTR="soaf_module_post_action_fn"
SOAF_MODULE_EXIT_FN_ATTR="soaf_module_exit_fn"

################################################################################
################################################################################

soaf_create_module() {
	local NAME=$1
	local VERSION=$2
	local CFG_FN=$3
	local INIT_FN=$4
	local PREPENV_FN=$5
	local PRE_ACTION_FN=$6
	local POST_ACTION_FN=$7
	local EXIT_FN=$8
	SOAF_MODULE_LIST="$SOAF_MODULE_LIST $NAME"
	SOAF_MODULE_REVERSE_LIST="$NAME $SOAF_MODULE_REVERSE_LIST"
	soaf_map_extend $NAME $SOAF_MODULE_VERSION_ATTR $VERSION
	soaf_map_extend $NAME $SOAF_MODULE_CFG_FN_ATTR $CFG_FN
	soaf_map_extend $NAME $SOAF_MODULE_INIT_FN_ATTR $INIT_FN
	soaf_map_extend $NAME $SOAF_MODULE_PREPENV_FN_ATTR $PREPENV_FN
	soaf_map_extend $NAME $SOAF_MODULE_PRE_ACTION_FN_ATTR $PRE_ACTION_FN
	soaf_map_extend $NAME $SOAF_MODULE_POST_ACTION_FN_ATTR $POST_ACTION_FN
	soaf_map_extend $NAME $SOAF_MODULE_EXIT_FN_ATTR $EXIT_FN
}

################################################################################
################################################################################

soaf_module_version() {
	local MODULE_NAME=$1
	local VERSION=$(soaf_map_get $MODULE_NAME $SOAF_MODULE_VERSION_ATTR)
	soaf_dis_txt "$MODULE_NAME-$VERSION"
}

################################################################################
################################################################################

soaf_module_call_fn() {
	local MODULE_NAME=$1
	local FN_ATTR=$2
	local ARG_1=$3
	local ARG_2=$4
	local ARG_3=$5
	local FN=$(soaf_map_get $MODULE_NAME $FN_ATTR)
	[ -n "$FN" ] && $FN $MODULE_NAME "$ARG_1" "$ARG_2" "$ARG_3"
}

################################################################################
################################################################################

soaf_module_call_cfg_fn() {
	local MODULE_NAME=$1
	local ARG_1=$2
	local ARG_2=$3
	local ARG_3=$4
	soaf_module_call_fn $MODULE_NAME $SOAF_MODULE_CFG_FN_ATTR \
		"$ARG_1" "$ARG_2" "$ARG_3"
}

soaf_module_call_init_fn() {
	local MODULE_NAME=$1
	local ARG_1=$2
	local ARG_2=$3
	local ARG_3=$4
	soaf_module_call_fn $MODULE_NAME $SOAF_MODULE_INIT_FN_ATTR \
		"$ARG_1" "$ARG_2" "$ARG_3"
}

soaf_module_call_prepenv_fn() {
	local MODULE_NAME=$1
	local ARG_1=$2
	local ARG_2=$3
	local ARG_3=$4
	soaf_module_call_fn $MODULE_NAME $SOAF_MODULE_PREPENV_FN_ATTR \
		"$ARG_1" "$ARG_2" "$ARG_3"
}

soaf_module_call_pre_action_fn() {
	local MODULE_NAME=$1
	local ARG_1=$2
	local ARG_2=$3
	local ARG_3=$4
	soaf_module_call_fn $MODULE_NAME $SOAF_MODULE_PRE_ACTION_FN_ATTR \
		"$ARG_1" "$ARG_2" "$ARG_3"
}

soaf_module_call_post_action_fn() {
	local MODULE_NAME=$1
	local ARG_1=$2
	local ARG_2=$3
	local ARG_3=$4
	soaf_module_call_fn $MODULE_NAME $SOAF_MODULE_POST_ACTION_FN_ATTR \
		"$ARG_1" "$ARG_2" "$ARG_3"
}

soaf_module_call_exit_fn() {
	local MODULE_NAME=$1
	local ARG_1=$2
	local ARG_2=$3
	local ARG_3=$4
	soaf_module_call_fn $MODULE_NAME $SOAF_MODULE_EXIT_FN_ATTR \
		"$ARG_1" "$ARG_2" "$ARG_3"
}

################################################################################
################################################################################

soaf_module_apply_all_fn() {
	local FN=$1
	local ARG_1=$2
	local ARG_2=$3
	local ARG_3=$4
	local module
	for module in $SOAF_MODULE_LIST
	do
		$FN $module "$ARG_1" "$ARG_2" "$ARG_3"
	done
}

soaf_module_apply_all_reverse_fn() {
	local FN=$1
	local ARG_1=$2
	local ARG_2=$3
	local ARG_3=$4
	local module
	for module in $SOAF_MODULE_REVERSE_LIST
	do
		$FN $module "$ARG_1" "$ARG_2" "$ARG_3"
	done
}
