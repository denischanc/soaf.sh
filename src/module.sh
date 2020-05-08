################################################################################
################################################################################

SOAF_MODULE_VERSION_ATTR="soaf_module_version"
SOAF_MODULE_STATIC_FN_ATTR="soaf_module_static_fn"
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
	local STATIC_FN=$3
	local CFG_FN=$4
	local INIT_FN=$5
	local PREPENV_FN=$6
	local PRE_ACTION_FN=$7
	local POST_ACTION_FN=$8
	local EXIT_FN=$9
	local DEP_LIST=${10}
	local POS=${11}
	[ "${NAME#soaf.core.}" = "$NAME" ] && POS=
	soaf_pmp_list_fill "$POS" SOAF_MODULE_LIST $NAME
	soaf_map_extend $NAME $SOAF_MODULE_VERSION_ATTR $VERSION
	soaf_map_extend $NAME $SOAF_MODULE_STATIC_FN_ATTR $STATIC_FN
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

soaf_module_resolve_dep_module_() {
	local MODULE=$1
	local DEP_LIST_MSG=$2
	local ERR_MSG=
	soaf_list_found "$SOAF_MODULE_LIST_" $MODULE
	if [ -z "$SOAF_RET_LIST" ]
	then
		local ERR_MSG="Module not found : [$MODULE]."
	else
		DEP_LIST_MSG="$DEP_LIST_MSG -> [$MODULE]"
		soaf_map_get_var $MODULE $SOAF_MODULE_DEP_STATE_ATTR
		local DEP_STATE=$SOAF_RET
		if [ "$DEP_STATE" = "$SOAF_MODULE_DEP_INPROG_S" ]
		then
			local ERR_MSG="Module dependance deadlock : $DEP_LIST_MSG."
		elif [ "$DEP_STATE" != "$SOAF_MODULE_DEP_OK_S" ]
		then
			soaf_map_extend $MODULE $SOAF_MODULE_DEP_STATE_ATTR \
				$SOAF_MODULE_DEP_INPROG_S
			soaf_map_get_var $MODULE $SOAF_MODULE_DEP_LIST_ATTR
			local dep_module
			for dep_module in $SOAF_RET
			do
				soaf_module_resolve_dep_module_ $dep_module "$DEP_LIST_MSG"
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
	soaf_pmp_list_cat SOAF_MODULE_LIST
	SOAF_MODULE_LIST_=$SOAF_RET_LIST
	local module
	for module in $SOAF_MODULE_LIST_
	do
		soaf_module_resolve_dep_module_ $module
	done
}

################################################################################
################################################################################

soaf_module_version() {
	local MODULE_NAME=$1
	soaf_map_get_var $MODULE_NAME $SOAF_MODULE_VERSION_ATTR
	soaf_dis_txt "$MODULE_NAME-$SOAF_RET"
}

################################################################################
################################################################################

soaf_module_call_fn_() {
	local MODULE_NAME=$1
	local FN=$2
	local VA_NATURE=$3
	if [ -n "$FN" ]
	then
		if [ -n "$VA_NATURE" ]
		then
			soaf_varargs_fn_apply $VA_NATURE $FN $MODULE_NAME
		else
			$FN $MODULE_NAME
		fi
	fi
}

################################################################################
################################################################################

soaf_module_apply_fn_() {
	local MODULE_LIST=$1
	local FN=$2
	local VA_NATURE=$3
	local module
	for module in $MODULE_LIST
	do
		soaf_module_call_fn_ $module $FN $VA_NATURE
	done
}

soaf_module_apply_all_fn() {
	local FN=$1
	local VA_NATURE=$2
	soaf_module_apply_fn_ "$SOAF_MODULE_SORT_LIST" $FN $VA_NATURE
}

soaf_module_apply_all_reverse_fn() {
	local FN=$1
	local VA_NATURE=$2
	soaf_module_apply_fn_ "$SOAF_MODULE_SORT_R_LIST" $FN $VA_NATURE
}

################################################################################
################################################################################

soaf_module_apply_fn_attr_() {
	local MODULE_LIST=$1
	local FN_ATTR=$2
	local VA_NATURE=$3
	local module
	for module in $MODULE_LIST
	do
		soaf_map_get_var $module $FN_ATTR
		local FN=$SOAF_RET
		[ -n "$FN" ] && soaf_module_call_fn_ $module $FN $VA_NATURE
	done
}

soaf_module_apply_all_fn_attr() {
	local FN_ATTR=$1
	local VA_NATURE=$2
	soaf_module_apply_fn_attr_ "$SOAF_MODULE_SORT_LIST" $FN_ATTR $VA_NATURE
}

soaf_module_apply_all_reverse_fn_attr() {
	local FN_ATTR=$1
	local VA_NATURE=$2
	soaf_module_apply_fn_attr_ "$SOAF_MODULE_SORT_R_LIST" $FN_ATTR $VA_NATURE
}
