################################################################################
################################################################################

SOAF_USAGE_LOG_NAME="soaf.usage"

SOAF_USAGE_ACTION=$SOAF_DEFINE_USAGE_ACTION

SOAF_USAGE_VAR_FN_ATTR="soaf_usage_var_fn"
SOAF_USAGE_VAR_ACTION_LIST_ATTR="soaf_usage_var_action_list"
SOAF_USAGE_VAR_DIS_BY_ACTION_ATTR="soaf_usage_var_dis_by_action"

################################################################################
################################################################################

soaf_usage_cfg() {
	SOAF_USAGE_DEF_NAME_COLOR=$SOAF_CONSOLE_FG_B_MAGENTA
}

soaf_usage_init() {
	soaf_create_action $SOAF_USAGE_ACTION soaf_usage "" $SOAF_POS_PRE
	soaf_no_prepenv_action $SOAF_USAGE_ACTION
}

soaf_create_module soaf.core.usage $SOAF_VERSION soaf_usage_cfg soaf_usage_init

################################################################################
################################################################################

soaf_usage_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_USAGE_LOG_NAME $LOG_LEVEL
}

soaf_define_add_name_log_level_fn soaf_usage_log_level

################################################################################
################################################################################

soaf_usage_add_var() {
	local VAR_LIST=$1
	local PREFIX=$2
	local USAGE_POS=$3
	soaf_pmp_list_fill "$USAGE_POS" SOAF_USAGE_VAR "$VAR_LIST"
	if [ -n "$PREFIX" ]
	then
		local var
		for var in $VAR_LIST
		do
			soaf_var_prefix_name $var $PREFIX
		done
	fi
}

################################################################################
################################################################################

soaf_usage_def_var() {
	local VAR=$1
	local FN=$2
	local ENUM=$3
	local DFT_VAL=$4
	local ACCEPT_EMPTY=$5
	local ACTION_LIST=$6
	local DIS_BY_ACTION=$7
	local USAGE_POS=$8
	[ $VAR != ACTION ] && \
		SOAF_USAGE_CHECK_VAR_LIST="$SOAF_USAGE_CHECK_VAR_LIST $VAR"
	soaf_create_var $VAR "$ENUM" "$DFT_VAL" $ACCEPT_EMPTY
	soaf_map_extend $VAR $SOAF_USAGE_VAR_FN_ATTR $FN
	soaf_map_extend $VAR $SOAF_USAGE_VAR_ACTION_LIST_ATTR "$ACTION_LIST"
	soaf_map_extend $VAR $SOAF_USAGE_VAR_DIS_BY_ACTION_ATTR $DIS_BY_ACTION
	if [ -n "$DIS_BY_ACTION" -a -n "$ACTION_LIST" ]
	then
		local action
		for action in $ACTION_LIST
		do
			soaf_action_add_usage_var $action $VAR
		done
	else
		soaf_pmp_list_fill "$USAGE_POS" SOAF_USAGE_DEF $VAR
	fi
}

################################################################################
################################################################################

### TODO : move into var.sh
soaf_usage_dis_var() {
	local VAR=$1
	local ENUM DFT_VAL A_E ACTION_LIST DIS_BY_ACTION FN
	soaf_map_get_var ENUM $VAR $SOAF_VAR_ENUM_ATTR
	soaf_map_get_var DFT_VAL $VAR $SOAF_VAR_DFT_VAL_ATTR
	soaf_map_get_var A_E $VAR $SOAF_VAR_ACCEPT_EMPTY_ATTR
	soaf_map_get_var ACTION_LIST $VAR $SOAF_USAGE_VAR_ACTION_LIST_ATTR
	soaf_map_get_var DIS_BY_ACTION $VAR $SOAF_USAGE_VAR_DIS_BY_ACTION_ATTR
	soaf_map_get_var FN $VAR $SOAF_USAGE_VAR_FN_ATTR
	soaf_console_msg_ctl $VAR $SOAF_USAGE_DEF_NAME_COLOR
	local TXT="$SOAF_CONSOLE_RET:"
	if [ -n "$ENUM" ]
	then
		soaf_list_join "$ENUM"
		local ENUM_DIS=$SOAF_RET_LIST
		[ -n "$A_E" ] && ENUM_DIS="$ENUM_DIS|"
		TXT="$TXT [$ENUM_DIS]"
	else
		TXT="$TXT '...'"
	fi
	if [ -n "$DFT_VAL" ]
	then
		soaf_console_msg_ctl "$DFT_VAL" $SOAF_CONSOLE_CTL_BOLD
		TXT="$TXT (default: '$SOAF_CONSOLE_RET')"
	fi
	soaf_dis_txt "$TXT"
	if [ -n "$ACTION_LIST" -a -z "$DIS_BY_ACTION" ]
	then
		soaf_list_join "$ACTION_LIST"
		TXT="ACTION=[$SOAF_RET_LIST]"
		soaf_dis_txt_off "$TXT" 2
	fi
	[ -n "$FN" ] && $FN $VAR
}

################################################################################
################################################################################

soaf_usage() {
	soaf_dis_title "USAGE"
	soaf_pmp_list_cat SOAF_USAGE_VAR
	soaf_list_join "$SOAF_RET_LIST"
	local VAR_LIST=$SOAF_RET_LIST
	soaf_console_msg_ctl "usage" $SOAF_USAGE_DEF_NAME_COLOR
	local USAGE_DIS=$SOAF_CONSOLE_RET
	soaf_console_msg_ctl "variable" $SOAF_USAGE_DEF_NAME_COLOR
	local VARIABLE_DIS=$SOAF_CONSOLE_RET
	soaf_dis_txt_stdin << _EOF_
$USAGE_DIS: $0 ([variable]=[value])*
$VARIABLE_DIS: [$VAR_LIST]
_EOF_
	### Variables
	local var
	soaf_pmp_list_cat SOAF_USAGE_DEF
	for var in $SOAF_RET_LIST
	do
		soaf_usage_dis_var $var
	done
	### Actions
	soaf_action_list
	local action
	for action in $SOAF_ACTION_RET_LIST
	do
		soaf_action_dis_usage $action
	done
}

################################################################################
################################################################################

soaf_usage_check_var_required() {
	local VAR=$1
	local ACTION_LIST
	soaf_map_get_var ACTION_LIST $VAR $SOAF_USAGE_VAR_ACTION_LIST_ATTR
	SOAF_USAGE_RET="OK"
	if [ -n "$ACTION_LIST" ]
	then
		soaf_list_found "$ACTION_LIST" $SOAF_ACTION
		[ -z "$SOAF_RET_LIST" ] && SOAF_USAGE_RET=
	fi
}

soaf_usage_check_var() {
	local VAR=$1
	soaf_var_check $VAR
	[ -z "$SOAF_VAR_RET" ] && \
		soaf_engine_exit "" "$SOAF_VAR_ERR_MSG" $SOAF_USAGE_LOG_NAME
}

soaf_usage_check() {
	soaf_usage_check_var ACTION
	local var
	for var in $SOAF_USAGE_CHECK_VAR_LIST
	do
		soaf_usage_check_var_required $var
		[ -n "$SOAF_USAGE_RET" ] && soaf_usage_check_var $var
	done
}
