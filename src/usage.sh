################################################################################
################################################################################

readonly SOAF_USAGE_ACTION="usage"

################################################################################
################################################################################

soaf_usage_init_() {
	soaf_create_action $SOAF_USAGE_ACTION soaf_usage_ "" $SOAF_POS_PRE
	soaf_no_prepenv_action $SOAF_USAGE_ACTION
}

soaf_create_module soaf.core.usage $SOAF_VERSION "" "" soaf_usage_init_

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

soaf_usage_add_var_exp() {
	local VAR=$1
	local USAGE_POS=$2
	soaf_pmp_list_fill "$USAGE_POS" SOAF_USAGE_VAR_EXP $VAR
}

################################################################################
################################################################################

soaf_usage_() {
	soaf_dis_title "USAGE"
	soaf_pmp_list_cat SOAF_USAGE_VAR
	soaf_list_join "$SOAF_RET_LIST" "" "$SOAF_THEME_ENUM_CTL_LIST"
	local VAR_LIST=$SOAF_RET_LIST
	soaf_console_msg_ctl "usage" "$SOAF_THEME_VAR_CTL_LIST"
	local USAGE_DIS=$SOAF_CONSOLE_RET
	soaf_console_msg_ctl "variable" "$SOAF_THEME_VAR_CTL_LIST"
	local VARIABLE_DIS=$SOAF_CONSOLE_RET
	soaf_dis_txt_stdin << _EOF_
$USAGE_DIS: $0 ([variable]=[value])*
$VARIABLE_DIS: [$VAR_LIST]
_EOF_
	### Variables
	local var
	soaf_pmp_list_cat SOAF_USAGE_VAR_EXP
	for var in $SOAF_RET_LIST
	do
		soaf_var_usage_exp_dis $var
	done
	### Actions
	soaf_action_list
	local action
	for action in $SOAF_ACTION_RET_LIST
	do
		soaf_action_dis_usage $action
	done
}
