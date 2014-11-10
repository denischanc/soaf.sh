################################################################################
################################################################################

SOAF_USAGE_ACTION="usage"

SOAF_USAGE_VAR_PRE_ATTR="soaf_usage_var_pre"

SOAF_USAGE_VAR_FN_ATTR="soaf_usage_var_fn"
SOAF_USAGE_VAR_ENUM_ATTR="soaf_usage_var_enum"
SOAF_USAGE_VAR_DFT_VAL_ATTR="soaf_usage_var_dft_val"

################################################################################
################################################################################

soaf_usage_prepenv() {
	local var
	for var in $SOAF_USAGE_DEF_LIST
	do
		soaf_usage_check_var $var
	done
}

soaf_define_add_engine_prepenv_fn soaf_usage_prepenv

################################################################################
################################################################################

soaf_usage_add_var() {
	local VAR_LIST=$1
	local PREFIX=$2
	SOAF_USAGE_VAR_LIST="$SOAF_USAGE_VAR_LIST $VAR_LIST"
	if [ -n "$PREFIX" ]
	then
		local var
		for var in $VAR_LIST
		do
			soaf_map_extend $var $SOAF_USAGE_VAR_PRE_ATTR $PREFIX
			eval local __VAL_TMP=\$$var
			[ -n "$__VAL_TMP" ] && eval ${PREFIX}_$var=\$__VAL_TMP
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
	[ "$VAR" != "ACTION" ] && SOAF_USAGE_DEF_LIST="$SOAF_USAGE_DEF_LIST $VAR"
	soaf_map_extend $VAR $SOAF_USAGE_VAR_FN_ATTR $FN
	soaf_map_extend $VAR $SOAF_USAGE_VAR_ENUM_ATTR "$ENUM"
	soaf_map_extend $VAR $SOAF_USAGE_VAR_DFT_VAL_ATTR $DFT_VAL
}

soaf_usage_check_var() {
	local VAR=$1
	local PRE=$(soaf_map_get $VAR $SOAF_USAGE_VAR_PRE_ATTR)
	local VAR_FINAL=$VAR
	[ -n "$PRE" ] && VAR_FINAL=${PRE}_$VAR_FINAL
	local DFT_VAL=$(soaf_map_get $VAR $SOAF_USAGE_VAR_DFT_VAL_ATTR)
	eval local VAL=\$$VAR_FINAL
	if [ -z "$VAL" -a -n "$DFT_VAL" ]
	then
		eval $VAR_FINAL=\$DFT_VAL
		VAL=$DFT_VAL
	fi
	local ENUM=$(soaf_map_get $VAR $SOAF_USAGE_VAR_ENUM_ATTR)
	if [ -n "$ENUM" ]
	then
		local IN_ENUM=$(echo $ENUM | grep -w "$VAL")
		if [ -z "$IN_ENUM" ]
		then
			soaf_dis_txt "Variable [$VAR] not in [$(echo $ENUM | tr ' ' '|')]."
			soaf_engine_exit
		fi
	fi
}

soaf_usage_dis_var() {
	local VAR=$1
	local ENUM=$(soaf_map_get $VAR $SOAF_USAGE_VAR_ENUM_ATTR)
	local DFT_VAL=$(soaf_map_get $VAR $SOAF_USAGE_VAR_DFT_VAL_ATTR)
	local FN=$(soaf_map_get $VAR $SOAF_USAGE_VAR_FN_ATTR)
	local TXT="$VAR:"
	[ -n "$ENUM" ] && TXT="$TXT [$(echo $ENUM | tr ' ' '|')]"
	[ -n "$DFT_VAL" ] && TXT="$TXT (default: $DFT_VAL)"
	soaf_dis_txt "$TXT"
	[ -n "$FN" ] && $FN $VAR
}

################################################################################
################################################################################

soaf_usage() {
	soaf_dis_title "USAGE"
	soaf_dis_txt_stdin << _EOF_
usage: $0 ([variable]=[value])*
variable: [$(echo $SOAF_USAGE_VAR_LIST | tr ' ' '|')]
_EOF_
	### Variables
	local var
	for var in ACTION $SOAF_USAGE_DEF_LIST
	do
		soaf_usage_dis_var $var
	done
	### Actions
	local action
	for action in $SOAF_ACTION_LIST
	do
		local USAGE_FN=$(soaf_map_get $action $SOAF_ACTION_USAGE_FN_ATTR)
		if [ -n "$USAGE_FN" ]
		then
			soaf_dis_title "ACTION=$action"
			$USAGE_FN
		fi
	done
}
