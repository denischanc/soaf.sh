################################################################################
################################################################################

SOAF_ACTION="usage"

soaf_info_add_var SOAF_ACTION

SOAF_ACTION_FN_ATTR="soaf_action_fn"
SOAF_ACTION_USAGE_FN_ATTR="soaf_action_usage_fn"

################################################################################
################################################################################

soaf_create_action() {
	local ACTION=$1
	local FN=$2
	local USAGE_FN=$3
	SOAF_ACTION_LIST="$SOAF_ACTION_LIST $ACTION"
	soaf_map_extend $ACTION $SOAF_ACTION_FN_ATTR $FN
	soaf_map_extend $ACTION $SOAF_ACTION_USAGE_FN_ATTR $USAGE_FN
}

soaf_no_init_action() {
	local ACTION=$1
	SOAF_ACTION_NOINIT_LIST="$SOAF_ACTION_NOINIT_LIST $ACTION"
}

################################################################################
################################################################################

soaf_action_init_proc() {
	local ACTION=$1
	local FN=$2
	soaf_create_action $ACTION $FN
	soaf_no_init_action $ACTION
}
