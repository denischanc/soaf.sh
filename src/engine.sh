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

soaf_engine_call_user_fn() {
	local USER_NATURE=$1
	local FN_ATTR=$2
	local FN=$(soaf_map_get $USER_NATURE $FN_ATTR)
	[ -n "$FN" ] && $FN $USER_NATURE
}

soaf_engine_call_fn_list() {
	local USER_NATURE=$1
	local FN_LIST=$2
	local fn
	for fn in $FN_LIST
	do
		$fn $USER_NATURE
	done
}

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
	local USER_NATURE=$1
	### FILEs
	soaf_cfg_set SOAF_EXT_GLOB_DIR /etc/$SOAF_USER_NAME
	soaf_cfg_set SOAF_EXT_LOC_DIR $HOME/.$SOAF_USER_NAME
	soaf_engine_source_ext $SOAF_ENGINE_EXT_CFG_FILE
	### USER
	soaf_engine_call_user_fn $USER_NATURE $SOAF_USER_CFG_FN_ATTR
	### SOAF
	soaf_engine_call_fn_list $USER_NATURE "$SOAF_ENGINE_CFG_FN_LIST"
}

################################################################################
################################################################################

soaf_engine_create_action() {
	local ACTION=$1
	local FN=$2
	soaf_create_action $ACTION $FN
	soaf_no_prepenv_action $ACTION
}

soaf_engine_init() {
	local USER_NATURE=$1
	### ENGINE
	soaf_engine_create_action $SOAF_USAGE_ACTION soaf_usage
	soaf_engine_create_action $SOAF_VERSION_ACTION soaf_version
	soaf_engine_create_action $SOAF_INFO_ACTION soaf_info
	### USER
	soaf_engine_call_user_fn $USER_NATURE $SOAF_USER_INIT_FN_ATTR
	### FILEs
	soaf_engine_source_ext $SOAF_ENGINE_EXT_INIT_FILE
	### SOAF
	soaf_engine_call_fn_list $USER_NATURE "$SOAF_ENGINE_INIT_FN_LIST"
	soaf_info_add_var "$SOAF_ENGINE_EXT_VF_L"
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
	local USER_NATURE=$1
	### SOAF
	soaf_engine_call_fn_list $USER_NATURE \
		"soaf_log_prepenv $SOAF_ENGINE_PREPENV_FN_LIST"
	### ENGINE
	soaf_engine_mkdir
	### USER
	soaf_engine_call_user_fn $USER_NATURE $SOAF_USER_PREPENV_FN_ATTR
	### FILEs
	soaf_engine_source_ext $SOAF_ENGINE_EXT_PREPENV_FILE
}

################################################################################
################################################################################

soaf_engine_action() {
	local USER_NATURE=$1
	local IS_ACTION=$(echo $SOAF_ACTION_LIST | grep -w "$SOAF_ACTION")
	if [ -z "$IS_ACTION" ]
	then
		soaf_usage $USER_NATURE
		exit
	fi
	local NOPREPENV=$(echo $SOAF_ACTION_NOPREPENV_LIST | \
		grep -w "$SOAF_ACTION")
	if [ -z "$NOPREPENV" ]
	then
		soaf_engine_prepenv $USER_NATURE
	fi
	local FN=$(soaf_map_get $SOAF_ACTION $SOAF_ACTION_FN_ATTR)
	if [ -z "$FN" ]
	then
		soaf_dis_txt "No function defined for action [$SOAF_ACTION]."
	else
		$FN $USER_NATURE
	fi
}

################################################################################
################################################################################

soaf_engine() {
	local USER_NATURE=$1
	SOAF_USER_NAME=$(soaf_map_get $USER_NATURE $SOAF_USER_NAME_ATTR)
	soaf_engine_cfg $USER_NATURE
	soaf_engine_init $USER_NATURE
	soaf_engine_action $USER_NATURE
}
