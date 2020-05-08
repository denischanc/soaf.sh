################################################################################
################################################################################

SOAF_ACTION_FN_ATTR="soaf_action_fn"
SOAF_ACTION_USAGE_FN_ATTR="soaf_action_usage_fn"
SOAF_ACTION_USAGE_VAR_LIST_ATTR="soaf_action_usage_var_list"

################################################################################
################################################################################

soaf_action_cfg_() {
	SOAF_ACTION_NAME_COLOR=$SOAF_CONSOLE_FG_B_GREEN
}

soaf_action_init_() {
	soaf_usage_add_var ACTION $SOAF_DEFINE_VAR_PREFIX $SOAF_POS_PRE
}

soaf_create_module soaf.core.action $SOAF_VERSION "" \
	soaf_action_cfg_ soaf_action_init_

################################################################################
################################################################################

soaf_create_action() {
	local ACTION=$1
	local FN=$2
	local USAGE_FN=$3
	local USAGE_POS=$4
	[ -z "$FN" ] && \
		soaf_engine_exit_dev "No function defined for action [$ACTION]."
	soaf_pmp_list_fill "$USAGE_POS" SOAF_ACTION $ACTION
	soaf_map_extend $ACTION $SOAF_ACTION_FN_ATTR $FN
	soaf_map_extend $ACTION $SOAF_ACTION_USAGE_FN_ATTR $USAGE_FN
}

soaf_no_prepenv_action() {
	local ACTION=$1
	SOAF_ACTION_NOPREPENV_LIST="$SOAF_ACTION_NOPREPENV_LIST $ACTION"
}

################################################################################
################################################################################

soaf_action_list() {
	soaf_pmp_list_cat SOAF_ACTION
	SOAF_ACTION_RET_LIST="$SOAF_RET_LIST"
}

################################################################################
################################################################################

soaf_action_add_usage_var() {
	local ACTION=$1
	local VAR_LIST=$2
	soaf_map_cat $ACTION $SOAF_ACTION_USAGE_VAR_LIST_ATTR "$VAR_LIST"
}

################################################################################
################################################################################

soaf_action_dis_usage() {
	local ACTION=$1
	soaf_map_get_var $ACTION $SOAF_ACTION_USAGE_FN_ATTR
	local FN=$SOAF_RET
	soaf_map_get_var $ACTION $SOAF_ACTION_USAGE_VAR_LIST_ATTR
	local VAR_LIST=$SOAF_RET
	if [ -n "$FN" -o -n "$VAR_LIST" ]
	then
		soaf_console_msg_ctl $ACTION $SOAF_ACTION_NAME_COLOR
		soaf_dis_title "ACTION=$SOAF_CONSOLE_RET"
		[ -n "$FN" ] && $FN $ACTION
		for var in $VAR_LIST
		do
			soaf_var_usage_dis $var
		done
	fi
}
