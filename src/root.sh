################################################################################
################################################################################

soaf_root_cfg() {
	local APPLI_NAME=$(soaf_module_this_appli_name)
	SOAF_WORK_DIR=$HOME/work/$APPLI_NAME
	SOAF_RUN_DIR=@[SOAF_WORK_DIR]/run
	soaf_var_add_unsubst SOAF_RUN_DIR
}

soaf_root_init() {
	soaf_info_add_var "SOAF_WORK_DIR SOAF_RUN_DIR"
}

soaf_define_add_this_cfg_fn soaf_root_cfg $SOAF_POS_PRE
soaf_define_add_this_init_fn soaf_root_init $SOAF_POS_PRE
