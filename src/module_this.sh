################################################################################
################################################################################

SOAF_MODULE_THIS_APPLI_NATURE_ATTR="soaf_module_this_appli_nature"

################################################################################
################################################################################

soaf_module_this_set_appli_nature() {
	local APPLI_NATURE=$1
	soaf_map_extend $SOAF_NAME $SOAF_MODULE_THIS_APPLI_NATURE_ATTR \
		$APPLI_NATURE
}

soaf_module_this_appli_nature() {
	soaf_map_get $SOAF_NAME $SOAF_MODULE_THIS_APPLI_NATURE_ATTR
}

soaf_module_this_appli_name() {
	soaf_map_get $(soaf_module_this_appli_nature) $SOAF_APPLI_NAME_ATTR
}

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
