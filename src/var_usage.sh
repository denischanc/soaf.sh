################################################################################
################################################################################

SOAF_VAR_USAGE_FN_ATTR="soaf_var_usage_fn"
SOAF_VAR_USAGE_ACTION_LIST_ATTR="soaf_var_usage_action_list"
SOAF_VAR_USAGE_DIS_BY_ACTION_ATTR="soaf_var_usage_dis_by_action"

################################################################################
################################################################################

soaf_create_var_usage() {
	local VAR=$1
	local FN=$2
	local ENUM=$3
	local DFT_VAL=$4
	local ACCEPT_EMPTY=$5
	local ACTION_LIST=$6
	local DIS_BY_ACTION=$7
	local USAGE_POS=$8
	soaf_create_var $VAR "$ENUM" "$DFT_VAL" $ACCEPT_EMPTY
	soaf_map_extend $VAR $SOAF_VAR_USAGE_FN_ATTR $FN
	soaf_map_extend $VAR $SOAF_VAR_USAGE_ACTION_LIST_ATTR "$ACTION_LIST"
	soaf_map_extend $VAR $SOAF_VAR_USAGE_DIS_BY_ACTION_ATTR $DIS_BY_ACTION
	if [ -n "$DIS_BY_ACTION" -a -n "$ACTION_LIST" ]
	then
		local action
		for action in $ACTION_LIST
		do
			soaf_action_add_usage_var $action $VAR
		done
	else
		soaf_usage_add_expanded_var $VAR $USAGE_POS
	fi
}

################################################################################
################################################################################

soaf_var_usage_dis() {
	local VAR=$1
	soaf_var_dis $VAR
	local ACTION_LIST DIS_BY_ACTION
	soaf_map_get_var ACTION_LIST $VAR $SOAF_VAR_USAGE_ACTION_LIST_ATTR
	soaf_map_get_var DIS_BY_ACTION $VAR $SOAF_VAR_USAGE_DIS_BY_ACTION_ATTR
	if [ -n "$ACTION_LIST" -a -z "$DIS_BY_ACTION" ]
	then
		soaf_list_join "$ACTION_LIST"
		TXT="ACTION=[$SOAF_RET_LIST]"
		soaf_dis_txt_off "$TXT" 2
	fi
	local FN
	soaf_map_get_var FN $VAR $SOAF_VAR_USAGE_FN_ATTR
	[ -n "$FN" ] && $FN $VAR
}

################################################################################
################################################################################

soaf_var_usage_check_required() {
	local VAR=$1
	local RET="OK"
	local ACTION_LIST
	soaf_map_get_var ACTION_LIST $VAR $SOAF_VAR_USAGE_ACTION_LIST_ATTR
	if [ -n "$ACTION_LIST" ]
	then
		soaf_list_found "$ACTION_LIST" $SOAF_ACTION
		[ -z "$SOAF_RET_LIST" ] && RET=
	fi
	SOAF_VAR_USAGE_RET=$RET
}
