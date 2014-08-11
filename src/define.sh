################################################################################
################################################################################

soaf_usage_add_var() {
	local VAR_LIST=$1
	SOAF_USAGE_VAR_LIST="$SOAF_USAGE_VAR_LIST $VAR_LIST"
}

################################################################################
################################################################################

soaf_engine_add_cfg_fn() {
	local FN_LIST=$1
	SOAF_ENGINE_CFG_FN_LIST="$SOAF_ENGINE_CFG_FN_LIST $FN_LIST"
}

soaf_engine_add_init_fn() {
	local FN_LIST=$1
	SOAF_ENGINE_INIT_FN_LIST="$SOAF_ENGINE_INIT_FN_LIST $FN_LIST"
}

soaf_engine_add_prepenv_fn() {
	local FN_LIST=$1
	SOAF_ENGINE_PREPENV_FN_LIST="$SOAF_ENGINE_PREPENV_FN_LIST $FN_LIST"
}

################################################################################
################################################################################

soaf_add_name_log_level_fn() {
	local FN_LIST=$1
	SOAF_NAME_LOGLVL_FN_LIST="$SOAF_NAME_LOGLVL_FN_LIST $FN_LIST"
}
