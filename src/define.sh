################################################################################
################################################################################

SOAF_NAME="soaf.sh"
SOAF_VERSION="0.10.0-dev"

################################################################################
################################################################################

SOAF_DEFINE_VAR_PREFIX="SOAF"

SOAF_DEFINE_USAGE_ACTION="usage"

################################################################################
################################################################################

soaf_define_add_name_log_level_fn() {
	local FN_LIST=$1
	local POS=${2:-$SOAF_POS_MAIN}
	soaf_pmp_list_fill $POS SOAF_NAME_LOGLVL_FN "$FN_LIST"
}

################################################################################
################################################################################

soaf_define_add_use_usermsgproc_fn() {
	local FN_LIST=$1
	local POS=${2:-$SOAF_POS_MAIN}
	soaf_pmp_list_fill $POS SOAF_USE_USERMSGPROC_FN "$FN_LIST"
}
