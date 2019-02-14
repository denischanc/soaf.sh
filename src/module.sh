################################################################################
################################################################################

SOAF_MODULE_VERSION_ATTR="soaf_module_version"
SOAF_MODULE_CFG_FN_ATTR="soaf_module_cfg_fn"
SOAF_MODULE_INIT_FN_ATTR="soaf_module_init_fn"
SOAF_MODULE_PREPENV_FN_ATTR="soaf_module_prepenv_fn"
SOAF_MODULE_PRE_ACTION_FN_ATTR="soaf_module_pre_action_fn"
SOAF_MODULE_POST_ACTION_FN_ATTR="soaf_module_post_action_fn"
SOAF_MODULE_EXIT_FN_ATTR="soaf_module_exit_fn"
SOAF_MODULE_DEP_LIST_ATTR="soaf_module_dep_list"
SOAF_MODULE_DEP_STATE_ATTR="soaf_module_dep_state"

SOAF_MODULE_DEP_UNKNOWN_S="UNKNOWN"
SOAF_MODULE_DEP_INPROG_S="INPROG"
SOAF_MODULE_DEP_OK_S="OK"

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
	local DEP_LIST=$9
	SOAF_MODULE_LIST="$SOAF_MODULE_LIST $NAME"
	soaf_map_extend $NAME $SOAF_MODULE_VERSION_ATTR $VERSION
	soaf_map_extend $NAME $SOAF_MODULE_CFG_FN_ATTR $CFG_FN
	soaf_map_extend $NAME $SOAF_MODULE_INIT_FN_ATTR $INIT_FN
	soaf_map_extend $NAME $SOAF_MODULE_PREPENV_FN_ATTR $PREPENV_FN
	soaf_map_extend $NAME $SOAF_MODULE_PRE_ACTION_FN_ATTR $PRE_ACTION_FN
	soaf_map_extend $NAME $SOAF_MODULE_POST_ACTION_FN_ATTR $POST_ACTION_FN
	soaf_map_extend $NAME $SOAF_MODULE_EXIT_FN_ATTR $EXIT_FN
	soaf_map_extend $NAME $SOAF_MODULE_DEP_LIST_ATTR "$DEP_LIST"
	soaf_map_extend $NAME $SOAF_MODULE_DEP_STATE_ATTR \
		$SOAF_MODULE_DEP_UNKNOWN_S
}

################################################################################
################################################################################

soaf_module_resolve_dep_module() {
	local MODULE=$1
	local DEP_LIST_MSG=$2
	local ERR_MSG=
	soaf_list_found "$SOAF_MODULE_LIST" $MODULE
	if [ -z "$SOAF_RET_LIST" ]
	then
		local ERR_MSG="Module not found : [$MODULE]."
	else
		DEP_LIST_MSG="$DEP_LIST_MSG -> [$MODULE]"
		local DEP_STATE
		soaf_map_get_var DEP_STATE $MODULE $SOAF_MODULE_DEP_STATE_ATTR
		if [ "$DEP_STATE" = "$SOAF_MODULE_DEP_INPROG_S" ]
		then
			local ERR_MSG="Module dependance deadlock : $DEP_LIST_MSG."
		elif [ "$DEP_STATE" != "$SOAF_MODULE_DEP_OK_S" ]
		then
			soaf_map_extend $MODULE $SOAF_MODULE_DEP_STATE_ATTR \
				$SOAF_MODULE_DEP_INPROG_S
			local DEP_LIST dep_module
			soaf_map_get_var DEP_LIST $MODULE $SOAF_MODULE_DEP_LIST_ATTR
			for dep_module in $DEP_LIST
			do
				soaf_module_resolve_dep_module $dep_module "$DEP_LIST_MSG"
			done
			SOAF_MODULE_SORT_LIST="$SOAF_MODULE_SORT_LIST $MODULE"
			SOAF_MODULE_SORT_R_LIST="$MODULE $SOAF_MODULE_SORT_R_LIST"
			soaf_map_extend $MODULE $SOAF_MODULE_DEP_STATE_ATTR \
				$SOAF_MODULE_DEP_OK_S
		fi
	fi
	[ -n "$ERR_MSG" ] && soaf_engine_exit_dev "$ERR_MSG"
}

soaf_module_resolve_dep() {
	local module
	for module in $SOAF_MODULE_LIST
	do
		soaf_module_resolve_dep_module $module
	done
}

################################################################################
################################################################################

soaf_module_version() {
	local MODULE_NAME=$1
	local VERSION
	soaf_map_get_var VERSION $MODULE_NAME $SOAF_MODULE_VERSION_ATTR
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
	local FN
	soaf_map_get_var FN $MODULE_NAME $FN_ATTR
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
	for module in $SOAF_MODULE_SORT_LIST
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
	for module in $SOAF_MODULE_SORT_R_LIST
	do
		$FN $module "$ARG_1" "$ARG_2" "$ARG_3"
	done
}
