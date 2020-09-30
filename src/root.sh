################################################################################
################################################################################

SOAF_ROOT_LOG_NAME="soaf.root"

################################################################################
################################################################################

soaf_root_cfg_() {
	SOAF_WORK_DIR=$HOME/work/$SOAF_APPLI_NAME
	SOAF_RUN_DIR=@[SOAF_WORK_DIR]/run
	SOAF_TMP_DIR=@[SOAF_WORK_DIR]/tmp.$$
	soaf_var_add_unsubst "SOAF_RUN_DIR SOAF_TMP_DIR"
}

soaf_root_init_() {
	soaf_info_add_var "SOAF_WORK_DIR SOAF_RUN_DIR SOAF_TMP_DIR"
	soaf_dis_var_w_fn SOAF_TMP_DIR soaf_root_var_subst_pid_
}

soaf_root_exit_() {
	[ -d $SOAF_TMP_DIR -a -z "$SOAF_KEEP_TMP_DIR" ] && \
		soaf_rm $SOAF_TMP_DIR "" $SOAF_ROOT_LOG_NAME
}

soaf_create_module soaf.core.root $SOAF_VERSION "" \
	soaf_root_cfg_ soaf_root_init_ "" "" "" soaf_root_exit_ "" $SOAF_POS_PRE

################################################################################
################################################################################

soaf_root_var_subst_pid_() {
	local VAR=$1
	local PID_PAT=${SOAF_VAR_PAT_O}PID$SOAF_VAR_PAT_C
	eval SOAF_RET=\${$VAR//$$/$PID_PAT}
}
