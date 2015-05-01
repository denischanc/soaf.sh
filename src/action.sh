################################################################################
################################################################################

SOAF_ACTION_FN_ATTR="soaf_action_fn"
SOAF_ACTION_USAGE_FN_ATTR="soaf_action_usage_fn"
SOAF_ACTION_USAGE_VAR_LIST_ATTR="soaf_action_usage_var_list"

################################################################################
################################################################################

soaf_action_init() {
	soaf_usage_add_var ACTION $SOAF_DEFINE_VAR_PREFIX $SOAF_POS_PRE
}

soaf_define_add_this_init_fn soaf_action_init

################################################################################
################################################################################

soaf_create_action() {
	local ACTION=$1
	local FN=$2
	local USAGE_FN=$3
	local USAGE_POS=$4
	SOAF_ACTION_LIST="$SOAF_ACTION_LIST $ACTION"
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

soaf_action_add_usage_var() {
	local ACTION=$1
	local VAR_LIST=$2
	soaf_map_cat $ACTION $SOAF_ACTION_USAGE_VAR_LIST_ATTR "$VAR_LIST"
}

################################################################################
################################################################################

soaf_action_dis_usage() {
	local ACTION=$1
	local FN=$(soaf_map_get $ACTION $SOAF_ACTION_USAGE_FN_ATTR)
	local VAR_LIST=$(soaf_map_get $ACTION $SOAF_ACTION_USAGE_VAR_LIST_ATTR)
	if [ -n "$FN" -o -n "$VAR_LIST" ]
	then
		soaf_dis_title "ACTION=$ACTION"
		[ -n "$FN" ] && $FN $ACTION
		for var in $VAR_LIST
		do
			soaf_usage_dis_var $var
		done
	fi
}
