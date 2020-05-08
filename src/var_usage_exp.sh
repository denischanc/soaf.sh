################################################################################
################################################################################

SOAF_VAR_USAGE_EXP_FN_ATTR="soaf_var_usage_exp_fn"
SOAF_VAR_USAGE_EXP_ACTION_LIST_ATTR="soaf_var_usage_exp_action_list"
SOAF_VAR_USAGE_EXP_DIS_BY_ACTION_ATTR="soaf_var_usage_exp_dis_by_action"

################################################################################
################################################################################

soaf_create_var_usage_exp() {
	local VAR=$1
	local FN=$2
	local ENUM=$3
	local DFT_VAL=$4
	local ACCEPT_EMPTY=$5
	local ACTION_LIST=$6
	local DIS_BY_ACTION=$7
	local PREFIX=$8
	local USAGE_POS=$9
	soaf_create_var_nature $VAR "$ENUM" "$DFT_VAL" $ACCEPT_EMPTY
	soaf_map_extend $VAR $SOAF_VAR_USAGE_EXP_FN_ATTR $FN
	soaf_map_extend $VAR $SOAF_VAR_USAGE_EXP_ACTION_LIST_ATTR "$ACTION_LIST"
	soaf_map_extend $VAR $SOAF_VAR_USAGE_EXP_DIS_BY_ACTION_ATTR $DIS_BY_ACTION
	soaf_usage_add_var $VAR "$PREFIX" $USAGE_POS
	if [ -n "$DIS_BY_ACTION" -a -n "$ACTION_LIST" ]
	then
		local action
		for action in $ACTION_LIST
		do
			soaf_action_add_usage_var $action $VAR
		done
	else
		soaf_usage_add_var_exp $VAR $USAGE_POS
	fi
}

################################################################################
################################################################################

soaf_var_usage_exp_dis() {
	local VAR=$1
	soaf_var_dis $VAR
	soaf_map_get $VAR $SOAF_VAR_USAGE_EXP_ACTION_LIST_ATTR
	local ACTION_LIST=$SOAF_RET
	soaf_map_get $VAR $SOAF_VAR_USAGE_EXP_DIS_BY_ACTION_ATTR
	local DIS_BY_ACTION=$SOAF_RET
	if [ -n "$ACTION_LIST" -a -z "$DIS_BY_ACTION" ]
	then
		soaf_list_join "$ACTION_LIST"
		TXT="ACTION=[$SOAF_RET_LIST]"
		soaf_dis_txt_off "$TXT" 2
	fi
	soaf_map_get $VAR $SOAF_VAR_USAGE_EXP_FN_ATTR
	[ -n "$SOAF_RET" ] && $SOAF_RET $VAR
}

################################################################################
################################################################################

soaf_var_usage_exp_check_required() {
	local VAR=$1
	local RET="OK"
	soaf_map_get $VAR $SOAF_VAR_USAGE_EXP_ACTION_LIST_ATTR
	local ACTION_LIST=$SOAF_RET
	if [ -n "$ACTION_LIST" ]
	then
		soaf_list_found "$ACTION_LIST" $SOAF_ACTION
		[ -z "$SOAF_RET_LIST" ] && RET=
	fi
	SOAF_VAR_USAGE_RET=$RET
}
