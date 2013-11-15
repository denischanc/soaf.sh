################################################################################
################################################################################

soaf_cfg_set SOAF_ACTION "usage"

soaf_info_add_var SOAF_ACTION

################################################################################
################################################################################

soaf_create_action() {
	local ACTION="$1"
	local FN="$2"
	local USAGE_FN="$3"
	SOAF_ACTION_LIST="$SOAF_ACTION_LIST $ACTION"
	soaf_map_extend $ACTION "FN" $FN
	soaf_map_extend $ACTION "USAGE_FN" $USAGE_FN
}

soaf_no_init_action() {
	local ACTION="$1"
	SOAF_ACTION_NOINIT_LIST="$SOAF_ACTION_NOINIT_LIST $ACTION"
}

################################################################################
################################################################################

soaf_action_init_proc() {
	local ACTION="$1"
	local FN="$2"
	soaf_create_action "$ACTION" "$FN"
	soaf_no_init_action "$ACTION"
}

soaf_action_init_proc "usage" soaf_usage
soaf_action_init_proc "version" soaf_version
soaf_action_init_proc "info" soaf_info
