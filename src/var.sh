################################################################################
################################################################################

readonly SOAF_VAR_LOG_NAME="soaf.var"

readonly SOAF_VAR_ENUM_ATTR="soaf_var_enum"
readonly SOAF_VAR_DFT_VAL_ATTR="soaf_var_dft_val"
readonly SOAF_VAR_ACCEPT_EMPTY_ATTR="soaf_var_accept_empty"

readonly SOAF_VAR_PREFIX_ATTR="soaf_var_prefix"

readonly SOAF_VAR_PAT_O="@\["
readonly SOAF_VAR_PAT_V="[_a-zA-Z0-9]\+"
readonly SOAF_VAR_PAT_C="\]"
readonly SOAF_VAR_PAT_G="$SOAF_VAR_PAT_O$SOAF_VAR_PAT_V$SOAF_VAR_PAT_C"

################################################################################
################################################################################

soaf_create_var_nature() {
	local VAR=$1
	local ENUM=$2
	local DFT_VAL=$3
	local ACCEPT_EMPTY=$4
	if [ -n "$ENUM" -a -n "$DFT_VAL" ]
	then
		soaf_list_found "$ENUM" $DFT_VAL
		if [ -z "$SOAF_RET_LIST" ]
		then
			soaf_var_err_msg_notinenum_ $VAR "$DFT_VAL" "$ENUM"
			soaf_engine_exit_dev "$SOAF_VAR_ERR_MSG"
		fi
	fi
	[ "$VAR" != "ACTION" ] && SOAF_VAR_ALL_LIST+=" $VAR"
	soaf_map_extend $VAR $SOAF_VAR_ENUM_ATTR "$ENUM"
	soaf_map_extend $VAR $SOAF_VAR_DFT_VAL_ATTR "$DFT_VAL"
	soaf_map_extend $VAR $SOAF_VAR_ACCEPT_EMPTY_ATTR $ACCEPT_EMPTY
}

################################################################################
################################################################################

soaf_var_err_msg_notinenum_() {
	local VAR=$1
	local VAL=$2
	local ENUM=$3
	soaf_list_join "$ENUM"
	SOAF_VAR_ERR_MSG="Val ($VAL) of var [$VAR] not in enum [$SOAF_RET_LIST]."
}

################################################################################
################################################################################

soaf_var_real_name_() {
	local VAR=$1
	soaf_map_get $VAR $SOAF_VAR_PREFIX_ATTR
	local PREFIX=$SOAF_RET
	[ -n "$PREFIX" ] && SOAF_VAR_RET=${PREFIX}_$VAR || SOAF_VAR_RET=$VAR
}

soaf_var_prefix_name() {
	local VAR=$1
	local PREFIX=$2
	if [ -n "$PREFIX" ]
	then
		soaf_map_extend $VAR $SOAF_VAR_PREFIX_ATTR $PREFIX
		eval ${PREFIX}_$VAR=\$$VAR
	fi
}

################################################################################
################################################################################

soaf_var_check_() {
	local VAR=$1
	soaf_map_get $VAR $SOAF_VAR_DFT_VAL_ATTR
	local DFT_VAL=$SOAF_RET
	soaf_var_real_name_ $VAR
	local VAR_REAL=$SOAF_VAR_RET
	eval local VAL=\$$VAR_REAL
	if [ -z "$VAL" -a -n "$DFT_VAL" ]
	then
		### Fix default value
		eval $VAR_REAL=\$DFT_VAL
	else
		if [ -z "$VAL" ]
		then
			### Check if val empty accepted
			soaf_map_get $VAR $SOAF_VAR_ACCEPT_EMPTY_ATTR
			if [ -z "$SOAF_RET" ]
			then
				soaf_console_err  "Variable [$VAR] not filled."
				soaf_engine_exit
			fi
		else
			soaf_map_get $VAR $SOAF_VAR_ENUM_ATTR
			local ENUM=$SOAF_RET
			if [ -n "$ENUM" ]
			then
				### Check val in enum
				soaf_list_found "$ENUM" $VAL
				if [ -z "$SOAF_RET_LIST" ]
				then
					soaf_var_err_msg_notinenum_ $VAR $VAL "$ENUM"
					soaf_console_err "$SOAF_VAR_ERR_MSG"
					soaf_engine_exit
				fi
			fi
		fi
	fi
}

soaf_var_check_all() {
	soaf_var_check_ ACTION
	local var
	for var in $SOAF_VAR_ALL_LIST
	do
		soaf_var_usage_exp_check_required $var
		[ -n "$SOAF_VAR_USAGE_RET" ] && soaf_var_check_ $var
	done
}

################################################################################
################################################################################

soaf_var_add_unsubst() {
	local VAR_LIST=$1
	SOAF_VAR_UNSUBST_LIST+=" $VAR_LIST"
}

soaf_var_subst_proc() {
	local VAL=$1
	local VAR=$2
	eval local VAR_VAL=\$$VAR
	SOAF_VAR_RET=${VAL//$SOAF_VAR_PAT_O$VAR${SOAF_VAR_PAT_C}/$VAR_VAL}
}

soaf_var_subst_() {
	local VAR=$1
	SOAF_VAR_OKSUBST_LIST+=" $VAR"
	eval local VAL=\$$VAR
	local SUBST_OK=
	local __var
	for __var in $(echo "$VAL" | grep -o $SOAF_VAR_PAT_G | \
		sed -e s:$SOAF_VAR_PAT_O:: -e s:$SOAF_VAR_PAT_C:: | sort | uniq)
	do
		soaf_list_found "$SOAF_VAR_OKSUBST_LIST" $__var
		[ -z "$SOAF_RET_LIST" ] && soaf_var_subst_ $__var
		soaf_var_subst_proc "$VAL" $__var
		VAL=$SOAF_VAR_RET
		SUBST_OK="OK"
	done
	[ -n "$SUBST_OK" ] && eval $VAR=\$VAL
}

soaf_var_subst_all() {
	local var
	for var in $SOAF_VAR_UNSUBST_LIST
	do
		soaf_var_subst_ $var
	done
}

################################################################################
################################################################################

soaf_var_dis() {
	local VAR=$1
	soaf_console_msg_ctl $VAR "$SOAF_THEME_VAR_CTL_LIST"
	local TXT="$SOAF_CONSOLE_RET:"
	soaf_map_get $VAR $SOAF_VAR_ENUM_ATTR
	local ENUM=$SOAF_RET
	if [ -n "$ENUM" ]
	then
		soaf_list_join "$ENUM" "" "$SOAF_THEME_ENUM_CTL_LIST"
		local ENUM_DIS=$SOAF_RET_LIST
		soaf_map_get $VAR $SOAF_VAR_ACCEPT_EMPTY_ATTR
		[ -n "$SOAF_RET" ] && ENUM_DIS+="|"
		TXT+=" [$ENUM_DIS]"
	else
		TXT+=" '...'"
	fi
	soaf_map_get $VAR $SOAF_VAR_DFT_VAL_ATTR
	local DFT_VAL=$SOAF_RET
	if [ -n "$DFT_VAL" ]
	then
		soaf_console_msg_ctl "$DFT_VAL" "$SOAF_THEME_VVAL_CTL_LIST"
		TXT+=" (default: '$SOAF_CONSOLE_RET')"
	fi
	soaf_dis_txt "$TXT"
}
