################################################################################
################################################################################

readonly SOAF_INFO_ACTION="info"

################################################################################
################################################################################

soaf_info_init_() {
	soaf_create_action $SOAF_INFO_ACTION soaf_info_ "" $SOAF_POS_PRE
	soaf_no_prepenv_action $SOAF_INFO_ACTION
}

soaf_create_module soaf.core.info $SOAF_DIST_VERSION "" "" soaf_info_init_

################################################################################
################################################################################

soaf_info_add_var() {
	local VAR_LIST=$1
	SOAF_INFO_VAR_LIST+=" $VAR_LIST"
}

################################################################################
################################################################################

soaf_info_() {
	soaf_dis_var_list "$SOAF_INFO_VAR_LIST"
}
