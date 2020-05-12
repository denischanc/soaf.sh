################################################################################
################################################################################

readonly SOAF_ENGINE_LOG_NAME="soaf.engine"

readonly SOAF_ENGINE_EXT_MODULE_FILE="module.sh"
readonly SOAF_ENGINE_EXT_STATIC_FILE="static.sh"
readonly SOAF_ENGINE_EXT_CFG_FILE="cfg.sh"
readonly SOAF_ENGINE_EXT_INIT_FILE="init.sh"
readonly SOAF_ENGINE_EXT_PREPENV_FILE="prepenv.sh"

SOAF_ENGINE_EXT_VF_L="SOAF_ENGINE_EXT_MODULE_FILE SOAF_ENGINE_EXT_STATIC_FILE"
SOAF_ENGINE_EXT_VF_L+=" SOAF_ENGINE_EXT_CFG_FILE SOAF_ENGINE_EXT_INIT_FILE"
SOAF_ENGINE_EXT_VF_L+=" SOAF_ENGINE_EXT_PREPENV_FILE"
readonly SOAF_ENGINE_EXT_VF_L

readonly SOAF_ENGINE_UNKNOWN_S="UNKNOWN"
readonly SOAF_ENGINE_MODULE_S="MODULE"
readonly SOAF_ENGINE_STATIC_S="STATIC"
readonly SOAF_ENGINE_CFG_S="CFG"
readonly SOAF_ENGINE_INIT_S="INIT"
readonly SOAF_ENGINE_PREP_S="PREP"
readonly SOAF_ENGINE_ALIVE_S="ALIVE"
readonly SOAF_ENGINE_DEAD_S="DEAD"
SOAF_ENGINE_STATE=$SOAF_ENGINE_UNKNOWN_S

################################################################################
################################################################################

soaf_engine_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_ENGINE_LOG_NAME $LOG_LEVEL
}

################################################################################
################################################################################

soaf_engine_source_ext_cfg_() {
	SOAF_ENGINE_EXT_GLOB_DIR=${SOAF_ENGINE_EXT_GLOB_DIR:-/etc/$SOAF_APPLI_NAME}
	SOAF_ENGINE_EXT_LOC_DIR=${SOAF_ENGINE_EXT_LOC_DIR:-$HOME/.$SOAF_APPLI_NAME}
	local DFT="$SOAF_ENGINE_EXT_GLOB_DIR $SOAF_ENGINE_EXT_LOC_DIR"
	SOAF_ENGINE_EXT_ALL_DIR=${SOAF_ENGINE_EXT_ALL_DIR:-$DFT}
}

soaf_engine_source_ext_() {
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

soaf_engine_module_() {
	SOAF_ENGINE_STATE=$SOAF_ENGINE_MODULE_S
	### FILEs
	soaf_engine_source_ext_ $SOAF_ENGINE_EXT_MODULE_FILE
	### MODULEs
	soaf_module_resolve_dep
}

################################################################################
################################################################################

soaf_engine_static_() {
	SOAF_ENGINE_STATE=$SOAF_ENGINE_STATIC_S
	soaf_log_add_log_level_fn soaf_engine_log_level
	### MODULEs
	soaf_module_apply_all_fn_attr $SOAF_MODULE_STATIC_FN_ATTR
	### FILEs
	soaf_engine_source_ext_ $SOAF_ENGINE_EXT_STATIC_FILE
}

################################################################################
################################################################################

soaf_engine_cfg_() {
	SOAF_ENGINE_STATE=$SOAF_ENGINE_CFG_S
	### MODULEs
	soaf_module_apply_all_fn_attr $SOAF_MODULE_CFG_FN_ATTR
	### FILEs
	soaf_engine_source_ext_ $SOAF_ENGINE_EXT_CFG_FILE
	### ARGs
	soaf_arg_parse_all
	### VARs
	soaf_var_subst_all
}

################################################################################
################################################################################

soaf_engine_init_() {
	SOAF_ENGINE_STATE=$SOAF_ENGINE_INIT_S
	### FILEs
	soaf_engine_source_ext_ $SOAF_ENGINE_EXT_INIT_FILE
	### MODULEs
	soaf_module_apply_all_reverse_fn_attr $SOAF_MODULE_INIT_FN_ATTR
	### ENGINE
	soaf_info_add_var "SOAF_ENGINE_EXT_ALL_DIR $SOAF_ENGINE_EXT_VF_L"
}

################################################################################
################################################################################

soaf_engine_prepenv_() {
	SOAF_ENGINE_STATE=$SOAF_ENGINE_PREP_S
	### MODULEs
	soaf_module_apply_all_fn_attr $SOAF_MODULE_PREPENV_FN_ATTR
	### FILEs
	soaf_engine_source_ext_ $SOAF_ENGINE_EXT_PREPENV_FILE
}

################################################################################
################################################################################

soaf_engine_action_() {
	soaf_list_found "$SOAF_ACTION_NOPREPENV_LIST" $SOAF_ACTION
	[ -z "$SOAF_RET_LIST" ] && soaf_engine_prepenv_
	SOAF_ENGINE_STATE=$SOAF_ENGINE_ALIVE_S
	local VA_NATURE=soaf.engine.va.action
	soaf_create_varargs_nature $VA_NATURE $SOAF_ACTION
	soaf_module_apply_all_fn_attr $SOAF_MODULE_PRE_ACTION_FN_ATTR $VA_NATURE
	soaf_map_get $SOAF_ACTION $SOAF_ACTION_FN_ATTR
	local FN=$SOAF_RET
	[ -n "$FN" ] && $FN $SOAF_ACTION
	soaf_module_apply_all_fn_attr $SOAF_MODULE_POST_ACTION_FN_ATTR $VA_NATURE
}

################################################################################
################################################################################

for sig in EXIT HUP INT QUIT KILL TERM
do
	eval "soaf_engine_trap_$sig() { soaf_engine_trap $sig; }"
	trap soaf_engine_trap_$sig $sig
done

soaf_engine_trap() {
	local SIG=$1
	local MSG="Exit on trap signal : [$SIG]."
	soaf_engine_exit "" "$MSG" $SOAF_ENGINE_LOG_NAME
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
	soaf_engine_source_ext_cfg_
	soaf_engine_module_
	soaf_engine_static_
	soaf_engine_cfg_
	soaf_engine_init_
	soaf_var_check_all
	soaf_engine_action_
	soaf_engine_exit 0
}
