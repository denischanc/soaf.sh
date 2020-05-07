################################################################################
################################################################################

SOAF_ENGINE_LOG_NAME="soaf.engine"

SOAF_ENGINE_EXT_MODULE_FILE="module.sh"
SOAF_ENGINE_EXT_STATIC_FILE="static.sh"
SOAF_ENGINE_EXT_CFG_FILE="cfg.sh"
SOAF_ENGINE_EXT_INIT_FILE="init.sh"
SOAF_ENGINE_EXT_PREPENV_FILE="prepenv.sh"

SOAF_ENGINE_EXT_VF_L="SOAF_ENGINE_EXT_MODULE_FILE SOAF_ENGINE_EXT_STATIC_FILE"
SOAF_ENGINE_EXT_VF_L="$SOAF_ENGINE_EXT_VF_L SOAF_ENGINE_EXT_CFG_FILE"
SOAF_ENGINE_EXT_VF_L="$SOAF_ENGINE_EXT_VF_L SOAF_ENGINE_EXT_INIT_FILE"
SOAF_ENGINE_EXT_VF_L="$SOAF_ENGINE_EXT_VF_L SOAF_ENGINE_EXT_PREPENV_FILE"

SOAF_ENGINE_UNKNOWN_S="UNKNOWN"
SOAF_ENGINE_MODULE_S="MODULE"
SOAF_ENGINE_STATIC_S="STATIC"
SOAF_ENGINE_CFG_S="CFG"
SOAF_ENGINE_INIT_S="INIT"
SOAF_ENGINE_PREP_S="PREP"
SOAF_ENGINE_ALIVE_S="ALIVE"
SOAF_ENGINE_DEAD_S="DEAD"
SOAF_ENGINE_STATE=$SOAF_ENGINE_UNKNOWN_S

################################################################################
################################################################################

soaf_engine_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_ENGINE_LOG_NAME $LOG_LEVEL
}

################################################################################
################################################################################

soaf_engine_source_ext_cfg() {
	soaf_cfg_set SOAF_ENGINE_EXT_GLOB_DIR /etc/$SOAF_APPLI_NAME
	soaf_cfg_set SOAF_ENGINE_EXT_LOC_DIR $HOME/.$SOAF_APPLI_NAME
	soaf_cfg_set SOAF_ENGINE_EXT_ALL_DIR \
		"$SOAF_ENGINE_EXT_GLOB_DIR $SOAF_ENGINE_EXT_LOC_DIR"
}

soaf_engine_source_ext() {
	local FILE=$1
	local d
	for d in $SOAF_ENGINE_EXT_ALL_DIR
	do
		local PATH_=$d/$FILE
		[ -f $PATH_ ] && . $PATH_
	done
}

################################################################################
################################################################################

soaf_engine_module() {
	SOAF_ENGINE_STATE=$SOAF_ENGINE_MODULE_S
	### FILEs
	soaf_engine_source_ext $SOAF_ENGINE_EXT_MODULE_FILE
	### MODULEs
	soaf_module_resolve_dep
}

################################################################################
################################################################################

soaf_engine_static() {
	SOAF_ENGINE_STATE=$SOAF_ENGINE_STATIC_S
	soaf_log_add_log_level_fn soaf_engine_log_level
	### MODULEs
	soaf_module_apply_all_fn_attr $SOAF_MODULE_STATIC_FN_ATTR
	### FILEs
	soaf_engine_source_ext $SOAF_ENGINE_EXT_STATIC_FILE
}

################################################################################
################################################################################

soaf_engine_cfg() {
	SOAF_ENGINE_STATE=$SOAF_ENGINE_CFG_S
	### MODULEs
	soaf_module_apply_all_fn_attr $SOAF_MODULE_CFG_FN_ATTR
	### FILEs
	soaf_engine_source_ext $SOAF_ENGINE_EXT_CFG_FILE
	### VARs
	soaf_var_subst_all
}

################################################################################
################################################################################

soaf_engine_init() {
	SOAF_ENGINE_STATE=$SOAF_ENGINE_INIT_S
	### FILEs
	soaf_engine_source_ext $SOAF_ENGINE_EXT_INIT_FILE
	### MODULEs
	soaf_module_apply_all_reverse_fn_attr $SOAF_MODULE_INIT_FN_ATTR
	### ENGINE
	soaf_action_list
	soaf_usage_def_var ACTION "" "$SOAF_ACTION_RET_LIST" $SOAF_USAGE_ACTION \
		"" "" "" $SOAF_POS_PRE
	soaf_info_add_var "SOAF_ENGINE_EXT_ALL_DIR $SOAF_ENGINE_EXT_VF_L"
}

################################################################################
################################################################################

soaf_engine_prepenv() {
	SOAF_ENGINE_STATE=$SOAF_ENGINE_PREP_S
	### MODULEs
	soaf_module_apply_all_fn_attr $SOAF_MODULE_PREPENV_FN_ATTR
	### FILEs
	soaf_engine_source_ext $SOAF_ENGINE_EXT_PREPENV_FILE
}

################################################################################
################################################################################

soaf_engine_action() {
	soaf_list_found "$SOAF_ACTION_NOPREPENV_LIST" $SOAF_ACTION
	[ -z "$SOAF_RET_LIST" ] && soaf_engine_prepenv
	SOAF_ENGINE_STATE=$SOAF_ENGINE_ALIVE_S
	local VA_NATURE=soaf.engine.va.action
	soaf_create_varargs_nature $VA_NATURE $SOAF_ACTION
	soaf_module_apply_all_fn_attr $SOAF_MODULE_PRE_ACTION_FN_ATTR $VA_NATURE
	local FN
	soaf_map_get_var FN $SOAF_ACTION $SOAF_ACTION_FN_ATTR
	[ -n "$FN" ] && $FN $SOAF_ACTION
	soaf_module_apply_all_fn_attr $SOAF_MODULE_POST_ACTION_FN_ATTR $VA_NATURE
}

################################################################################
################################################################################

soaf_engine_exit() {
	local ERR=${1:-1}
	local ERR_MSG=$2
	local LOG_NAME=$3
	if [ "$SOAF_ENGINE_STATE" != "$SOAF_ENGINE_DEAD_S" ]
	then
		SOAF_ENGINE_STATE=$SOAF_ENGINE_DEAD_S
		[ -n "$ERR_MSG" ] && soaf_log_err "$ERR_MSG" $LOG_NAME
		[ $ERR -ne 0 ] && soaf_log_stop
		local VA_NATURE=soaf.engine.va._exit
		soaf_create_varargs_nature $VA_NATURE $ERR
		soaf_module_apply_all_reverse_fn_attr $SOAF_MODULE_EXIT_FN_ATTR \
			$VA_NATURE
		exit $ERR
	fi
}

soaf_engine_exit_dev() {
	local ERR_MSG=$1
	soaf_log_dev_err "$ERR_MSG"
	soaf_engine_exit
}

soaf_engine() {
	local APPLI_NATURE=$1
	soaf_appli_def_name $APPLI_NATURE
	soaf_engine_source_ext_cfg
	soaf_engine_module
	soaf_engine_static
	soaf_engine_cfg
	soaf_engine_init
	soaf_usage_check
	soaf_engine_action
	soaf_engine_exit 0
}
