################################################################################
################################################################################

SOAF_USAGE_LOG_NAME="soaf.usage"

SOAF_USAGE_ACTION=$SOAF_DEFINE_USAGE_ACTION

SOAF_USAGE_VAR_FN_ATTR="soaf_usage_var_fn"
SOAF_USAGE_VAR_ACTION_LIST_ATTR="soaf_usage_var_action_list"
SOAF_USAGE_VAR_DIS_BY_ACTION_ATTR="soaf_usage_var_dis_by_action"

################################################################################
################################################################################

soaf_usage_init() {
	soaf_create_action $SOAF_USAGE_ACTION soaf_usage "" $SOAF_POS_PRE
	soaf_no_prepenv_action $SOAF_USAGE_ACTION
}

soaf_define_add_this_init_fn soaf_usage_init

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

soaf_usage_dis_var() {
	local VAR=$1
	local ENUM=$(soaf_map_get $VAR $SOAF_VAR_ENUM_ATTR)
	local DFT_VAL=$(soaf_map_get $VAR $SOAF_VAR_DFT_VAL_ATTR)
	local A_E=$(soaf_map_get $VAR $SOAF_VAR_ACCEPT_EMPTY_ATTR)
	local ACTION_LIST=$(soaf_map_get $VAR $SOAF_USAGE_VAR_ACTION_LIST_ATTR)
	local DIS_BY_ACTION=$(soaf_map_get $VAR $SOAF_USAGE_VAR_DIS_BY_ACTION_ATTR)
	local FN=$(soaf_map_get $VAR $SOAF_USAGE_VAR_FN_ATTR)
	local TXT="$VAR:"
	if [ -n "$ENUM" ]
	then
		local ENUM_DIS=$(soaf_dis_echo_list "$ENUM")
		[ -n "$A_E" ] && ENUM_DIS="$ENUM_DIS|"
		TXT="$TXT [$ENUM_DIS]"
	else
		TXT="$TXT '...'"
	fi
	[ -n "$DFT_VAL" ] && TXT="$TXT (default: '$DFT_VAL')"
	soaf_dis_txt "$TXT"
	if [ -n "$ACTION_LIST" -a -z "$DIS_BY_ACTION" ]
	then
		TXT=$(soaf_dis_echo_list "$ACTION_LIST")
		TXT="ACTION=[$TXT]"
		soaf_dis_txt_off "$TXT" 2
	fi
	[ -n "$FN" ] && $FN $VAR
}

################################################################################
################################################################################

soaf_usage() {
	soaf_dis_title "USAGE"
	soaf_pmp_list_cat SOAF_USAGE_VAR
	local VAR_LIST=$(soaf_dis_echo_list "$SOAF_RET_LIST")
	soaf_dis_txt_stdin << _EOF_
usage: $0 ([variable]=[value])*
variable: [$VAR_LIST]
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
	local ACTION_LIST=$(soaf_map_get $VAR $SOAF_USAGE_VAR_ACTION_LIST_ATTR)
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
