################################################################################
################################################################################

soaf_create_action() {
	local ACTION="$1"
	local FN="$2"
	SOAF_ACTION_LIST="$SOAF_ACTION_LIST $ACTION"
	if [ -n "$NO_INIT" ]
	then
		SOAF_ACTION_NOINIT_LIST="$SOAF_ACTION_NOINIT_LIST $ACTION"
	fi
	soaf_map_extend $ACTION "FN" $FN
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

soaf_action_init() {
	soaf_action_init_proc "usage" soaf_usage
	soaf_action_init_proc "version" soaf_version
	soaf_action_init_proc "info" soaf_info
}
