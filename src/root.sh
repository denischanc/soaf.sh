################################################################################
################################################################################

soaf_root_cfg_() {
	SOAF_WORK_DIR=$HOME/work/$SOAF_APPLI_NAME
	SOAF_RUN_DIR=@[SOAF_WORK_DIR]/run
	soaf_var_add_unsubst SOAF_RUN_DIR
}

soaf_root_init_() {
	soaf_info_add_var "SOAF_WORK_DIR SOAF_RUN_DIR"
}

soaf_create_module soaf.core.root $SOAF_VERSION "" \
	soaf_root_cfg_ soaf_root_init_ "" "" "" "" "" $SOAF_POS_PRE
