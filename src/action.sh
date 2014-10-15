################################################################################
################################################################################

SOAF_ACTION_FN_ATTR="soaf_action_fn"
SOAF_ACTION_USAGE_FN_ATTR="soaf_action_usage_fn"


################################################################################
################################################################################

soaf_action_cfg() {
	soaf_cfg_set SOAF_ACTION $SOAF_USAGE_ACTION
}

soaf_action_init() {
	soaf_usage_add_var ACTION $SOAF_DEFINE_VAR_PREFIX
	soaf_info_add_var SOAF_ACTION
}

soaf_define_add_engine_cfg_fn soaf_action_cfg
soaf_define_add_engine_init_fn soaf_action_init

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

soaf_no_prepenv_action() {
	local ACTION=$1
	SOAF_ACTION_NOPREPENV_LIST="$SOAF_ACTION_NOPREPENV_LIST $ACTION"
}
