################################################################################
################################################################################

SOAF_DEFINE_VAR_PREFIX="SOAF"

################################################################################
################################################################################

soaf_define_add_engine_cfg_fn() {
	local FN_LIST=$1
	SOAF_ENGINE_CFG_FN_LIST="$SOAF_ENGINE_CFG_FN_LIST $FN_LIST"
}

soaf_define_add_engine_init_fn() {
	local FN_LIST=$1
	SOAF_ENGINE_INIT_FN_LIST="$SOAF_ENGINE_INIT_FN_LIST $FN_LIST"
}

soaf_define_add_engine_prepenv_fn() {
	local FN_LIST=$1
	SOAF_ENGINE_PREPENV_FN_LIST="$SOAF_ENGINE_PREPENV_FN_LIST $FN_LIST"
}

################################################################################
################################################################################

soaf_define_add_name_log_level_fn() {
	local FN_LIST=$1
	SOAF_NAME_LOGLVL_FN_LIST="$SOAF_NAME_LOGLVL_FN_LIST $FN_LIST"
}
