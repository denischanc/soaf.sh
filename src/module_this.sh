################################################################################
################################################################################

SOAF_MODULE_THIS_USER_NATURE_ATTR="soaf_module_this_user_nature"

################################################################################
################################################################################

soaf_module_this_user_nature() {
	local MODULE_NAME=$1
	local USER_NATURE=$2
	soaf_map_extend $MODULE_NAME $SOAF_MODULE_THIS_USER_NATURE_ATTR \
		$USER_NATURE
}

################################################################################
################################################################################

soaf_module_this_call_fn_list() {
	local MODULE_NAME=$1
	local FN_LIST=$2
	local USER_NATURE=$(soaf_map_get $MODULE_NAME \
		$SOAF_MODULE_THIS_USER_NATURE_ATTR)
	local fn
	for fn in $FN_LIST
	do
		$fn $USER_NATURE
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

soaf_module_this_preplog() {
	local MODULE_NAME=$1
	soaf_module_this_call_fn_list $MODULE_NAME "$SOAF_THIS_PREPLOG_FN_LIST"
}

soaf_module_this_prepenv() {
	local MODULE_NAME=$1
	soaf_module_this_call_fn_list $MODULE_NAME "$SOAF_THIS_PREPENV_FN_LIST"
}

################################################################################
################################################################################

soaf_create_module $SOAF_NAME $SOAF_VERSION \
	soaf_module_this_cfg soaf_module_this_init soaf_module_this_prepenv
soaf_module_do_log $SOAF_NAME soaf_module_this_preplog
