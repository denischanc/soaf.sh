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

soaf_module_this_appli_name() {
	local APPLI_NATURE=$(soaf_map_get $SOAF_NAME \
		$SOAF_MODULE_THIS_APPLI_NATURE_ATTR)
	soaf_map_get $APPLI_NATURE $SOAF_APPLI_NAME_ATTR
}

################################################################################
################################################################################

soaf_module_this_call_fn_list() {
	local MODULE_NAME=$1
	local FN_LIST=$2
	local APPLI_NATURE=$(soaf_map_get $MODULE_NAME \
		$SOAF_MODULE_THIS_APPLI_NATURE_ATTR)
	local fn
	for fn in $FN_LIST
	do
		$fn $APPLI_NATURE
	done
}

################################################################################
################################################################################

soaf_module_this_cfg() {
	local MODULE_NAME=$1
	soaf_module_this_call_fn_list $MODULE_NAME "$SOAF_THIS_CFG_FN_LIST"
}

soaf_module_this_init() {
	local MODULE_NAME=$1
	soaf_module_this_call_fn_list $MODULE_NAME "$SOAF_THIS_INIT_FN_LIST"
}

soaf_module_this_prepenv() {
	local MODULE_NAME=$1
	soaf_module_this_call_fn_list $MODULE_NAME "$SOAF_THIS_PREPENV_FN_LIST"
}

################################################################################
################################################################################

soaf_create_module $SOAF_NAME $SOAF_VERSION \
	soaf_module_this_cfg soaf_module_this_init soaf_module_this_prepenv
