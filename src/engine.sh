################################################################################
################################################################################

SOAF_ENGINE_LOG_NAME="soaf.engine"

SOAF_ENGINE_EXT_CFG_FILE="cfg.sh"
SOAF_ENGINE_EXT_INIT_FILE="init.sh"
SOAF_ENGINE_EXT_PREPENV_FILE="prepenv.sh"

SOAF_ENGINE_EXT_VF_L="SOAF_ENGINE_EXT_CFG_FILE SOAF_ENGINE_EXT_INIT_FILE"
SOAF_ENGINE_EXT_VF_L="$SOAF_ENGINE_EXT_VF_L SOAF_ENGINE_EXT_PREPENV_FILE"

################################################################################
################################################################################

### cfg : SOAF_VAR_MKDIR_LIST

################################################################################
################################################################################

soaf_engine_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_ENGINE_LOG_NAME $LOG_LEVEL
}

soaf_define_add_name_log_level_fn soaf_engine_log_level

################################################################################
################################################################################

soaf_engine_source_ext() {
	local FILE=$1
	local DIR_LIST=${SOAF_EXT_OTHER_DIR:-$SOAF_EXT_GLOB_DIR $SOAF_EXT_LOC_DIR}
	local d
	for d in $DIR_LIST
	do
		local PATH_=$d/$FILE
		[ -f $PATH_ ] && . $PATH_
	done
}

################################################################################
################################################################################

soaf_engine_cfg() {
	local APPLI_NATURE=$1
	local APPLI_NAME=$(soaf_map_get $APPLI_NATURE $SOAF_APPLI_NAME_ATTR)
	### FILEs
	soaf_cfg_set SOAF_EXT_GLOB_DIR /etc/$APPLI_NAME
	soaf_cfg_set SOAF_EXT_LOC_DIR $HOME/.$APPLI_NAME
	soaf_engine_source_ext $SOAF_ENGINE_EXT_CFG_FILE
	### MODULEs
	soaf_module_apply_all_reverse_fn soaf_module_call_cfg_fn
}

################################################################################
################################################################################

soaf_engine_init() {
	### FILEs
	soaf_engine_source_ext $SOAF_ENGINE_EXT_INIT_FILE
	### MODULEs
	soaf_module_apply_all_reverse_fn soaf_module_call_init_fn
	### ENGINE
	soaf_pmp_list_cat SOAF_ACTION
	soaf_usage_def_var ACTION "" "$SOAF_RET_LIST" "" $SOAF_POS_PRE
	soaf_info_add_var "$SOAF_ENGINE_EXT_VF_L"
}

################################################################################
################################################################################

soaf_engine_preplog() {
	local PREP_FN=$(soaf_map_get $SOAF_LOG_USED_NATURE $SOAF_LOG_PREP_FN_ATTR)
	[ -n "$PREP_FN" ] && $PREP_FN $SOAF_LOG_USED_NATURE
	soaf_log_prepared_ok
}

################################################################################
################################################################################

soaf_engine_mkdir() {
	for var in $SOAF_VAR_MKDIR_LIST
	do
		eval local DIR=\$$var
		soaf_mkdir "$DIR" $SOAF_LOG_INFO $SOAF_ENGINE_LOG_NAME
	done
}

soaf_engine_prepenv() {
	### ENGINE
	soaf_engine_mkdir
	### MODULEs
	soaf_module_apply_all_fn soaf_module_call_prepenv_fn
	### FILEs
	soaf_engine_source_ext $SOAF_ENGINE_EXT_PREPENV_FILE
}

################################################################################
################################################################################

soaf_engine_action() {
	local APPLI_NATURE=$1
	local IS_ACTION=$(echo $SOAF_ACTION_LIST | grep -w "$SOAF_ACTION")
	if [ -z "$IS_ACTION" ]
	then
		soaf_usage
		soaf_engine_exit
	fi
	local NOPREPENV=$(echo $SOAF_ACTION_NOPREPENV_LIST | \
		grep -w "$SOAF_ACTION")
	if [ -z "$NOPREPENV" ]
	then
		soaf_engine_preplog
		soaf_engine_prepenv
	fi
	local FN=$(soaf_map_get $SOAF_ACTION $SOAF_ACTION_FN_ATTR)
	if [ -z "$FN" ]
	then
		soaf_dis_txt "No function defined for action [$SOAF_ACTION]."
	else
		soaf_module_apply_all_fn soaf_module_call_pre_action_fn
		$FN $SOAF_ACTION $APPLI_NATURE
		soaf_module_apply_all_fn soaf_module_call_post_action_fn
	fi
}

################################################################################
################################################################################

soaf_engine_exit() {
	local ERR=${1:-1}
	soaf_module_apply_all_reverse_fn soaf_module_call_exit_fn $ERR
	exit $ERR
}

soaf_engine() {
	local APPLI_NATURE=$1
	soaf_module_this_set_appli_nature $APPLI_NATURE
	soaf_engine_cfg $APPLI_NATURE
	soaf_engine_init
	soaf_engine_action $APPLI_NATURE
	soaf_engine_exit 0
}
