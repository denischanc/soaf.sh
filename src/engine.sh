################################################################################
################################################################################

### VAR_LIST : SOAF_VAR_MKDIR_LIST

soaf_usage_add_var ACTION

SOAF_ENGINE_LOG_NAME="engine"

################################################################################
################################################################################

soaf_engine_log_level() {
	local LOG_LEVEL=$1
	soaf_map_extend $SOAF_ENGINE_LOG_NAME "LOG_LEVEL" $LOG_LEVEL
}

################################################################################
################################################################################

soaf_usage() {
	local USAGE_VAR_LIST=$(soaf_map_get $SOAF_USER_MAP "USAGE_VAR_LIST")
	USAGE_VAR_LIST="$SOAF_USAGE_VAR_LIST $USAGE_VAR_LIST"
	cat << _EOF_
${SOAF_TITLE_PRE}USAGE
${SOAF_TXT_PRE}usage: $0 ([variable]=[value])*
${SOAF_TXT_PRE}variable: [$(echo $USAGE_VAR_LIST | tr ' ' '|')]
${SOAF_TXT_PRE}ACTION: [$(echo $SOAF_ACTION_LIST | tr ' ' '|')]
_EOF_
	for action in $SOAF_ACTION_LIST
	do
		local USAGE_FN=$(soaf_map_get $action "ACTION_USAGE_FN")
		if [ -n "$USAGE_FN" ]
		then
			soaf_dis_title "ACTION=$action"
			$USAGE_FN
		fi
	done
}

################################################################################
################################################################################

soaf_init_mkdir() {
	for var in $SOAF_VAR_MKDIR_LIST
	do
		eval local DIR=\$$var
		soaf_mkdir "$DIR" $SOAF_LOG_INFO $SOAF_ENGINE_LOG_NAME
	done
}

soaf_init() {
	soaf_log_init
	soaf_init_mkdir
	local INIT_FN=$(soaf_map_get $SOAF_USER_MAP "INIT_FN")
	[ -n "$INIT_FN" ] && $INIT_FN
	[ -n "$SOAF_CFG_INIT_FN" ] && $SOAF_CFG_INIT_FN
}

################################################################################
################################################################################

soaf_engine() {
	soaf_job_init
	soaf_mng_glob_var
	local IS_ACTION=$(echo $SOAF_ACTION_LIST | grep -w "$SOAF_ACTION")
	if [ -z "$IS_ACTION" ]
	then
		soaf_usage
		exit
	fi
	local NOINIT=$(echo $SOAF_ACTION_NOINIT_LIST | grep -w "$SOAF_ACTION")
	if [ -z "$NOINIT" ]
	then
		soaf_init
	fi
	local FN=$(soaf_map_get $SOAF_ACTION "ACTION_FN")
	if [ -z "$FN" ]
	then
		soaf_dis_txt "No function defined for action [$SOAF_ACTION]."
	else
		$FN
	fi
}
