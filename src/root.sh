################################################################################
################################################################################

soaf_root_cfg() {
	SOAF_WORK_DIR=$HOME/work/$SOAF_APPLI_NAME
	SOAF_RUN_DIR=@[SOAF_WORK_DIR]/run
	soaf_var_add_unsubst SOAF_RUN_DIR
}

soaf_root_init() {
	soaf_info_add_var "SOAF_WORK_DIR SOAF_RUN_DIR"
}

soaf_create_module soaf.core.root $SOAF_VERSION "" \
	soaf_root_cfg soaf_root_init "" "" "" "" "" $SOAF_POS_PRE
