################################################################################
################################################################################

SOAF_DEFINE_VAR_PREFIX="SOAF"

SOAF_DEFINE_USAGE_ACTION="usage"

SOAF_POS_PRE="pre"
SOAF_POS_MAIN="main"
SOAF_POS_POST="post"

################################################################################
################################################################################

soaf_define_add_this_cfg_fn() {
	local FN_LIST=$1
	local POS=${2:-$SOAF_POS_MAIN}
	soaf_pmp_list_fill $POS SOAF_THIS_CFG_FN "$FN_LIST"
}

soaf_define_add_this_init_fn() {
	local FN_LIST=$1
	local POS=${2:-$SOAF_POS_MAIN}
	soaf_pmp_list_fill $POS SOAF_THIS_INIT_FN "$FN_LIST"
}

soaf_define_add_this_prepenv_fn() {
	local FN_LIST=$1
	local POS=${2:-$SOAF_POS_MAIN}
	soaf_pmp_list_fill $POS SOAF_THIS_PREPENV_FN "$FN_LIST"
}

################################################################################
################################################################################

soaf_define_add_name_log_level_fn() {
	local FN_LIST=$1
	local POS=${2:-$SOAF_POS_MAIN}
	soaf_pmp_list_fill $POS SOAF_NAME_LOGLVL_FN "$FN_LIST"
}
