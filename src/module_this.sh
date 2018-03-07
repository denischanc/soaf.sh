################################################################################
################################################################################

soaf_module_this_call_fn_list() {
	local FN_LIST=$1
	local fn
	for fn in $FN_LIST
	do
		$fn
	done
}

################################################################################
################################################################################

soaf_module_this_cfg() {
	soaf_pmp_list_cat SOAF_THIS_CFG_FN
	soaf_module_this_call_fn_list "$SOAF_RET_LIST"
}

soaf_module_this_init() {
	soaf_pmp_list_cat SOAF_THIS_INIT_FN
	soaf_module_this_call_fn_list "$SOAF_RET_LIST"
}

soaf_module_this_prepenv() {
	soaf_pmp_list_cat SOAF_THIS_PREPENV_FN
	soaf_module_this_call_fn_list "$SOAF_RET_LIST"
}

################################################################################
################################################################################

soaf_create_module $SOAF_NAME $SOAF_VERSION \
	soaf_module_this_cfg soaf_module_this_init soaf_module_this_prepenv
