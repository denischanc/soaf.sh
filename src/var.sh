################################################################################
################################################################################

SOAF_VAR_ENUM_ATTR="soaf_var_enum"
SOAF_VAR_DFT_VAL_ATTR="soaf_var_dft_val"
SOAF_VAR_ACCEPT_EMPTY_ATTR="soaf_var_accept_empty"

SOAF_VAR_PREFIX_ATTR="soaf_var_prefix"

SOAF_VAR_PAT_O="@\["
SOAF_VAR_PAT_V="[_a-zA-Z0-9]\+"
SOAF_VAR_PAT_C="\]"
SOAF_VAR_PAT_G="$SOAF_VAR_PAT_O$SOAF_VAR_PAT_V$SOAF_VAR_PAT_C"

################################################################################
################################################################################

soaf_create_var() {
	local VAR=$1
	local ENUM=$2
	local DFT_VAL=$3
	local ACCEPT_EMPTY=$4
	if [ -n "$ENUM" -a -n "$DFT_VAL" ]
	then
		soaf_list_found "$ENUM" $DFT_VAL
		if [ -z "$SOAF_RET_LIST" ]
		then
			soaf_var_err_msg_notinenum $VAR "$DFT_VAL" "$ENUM"
			soaf_engine_exit_dev "$SOAF_VAR_ERR_MSG"
		fi
	fi
	soaf_map_extend $VAR $SOAF_VAR_ENUM_ATTR "$ENUM"
	soaf_map_extend $VAR $SOAF_VAR_DFT_VAL_ATTR "$DFT_VAL"
	soaf_map_extend $VAR $SOAF_VAR_ACCEPT_EMPTY_ATTR $ACCEPT_EMPTY
}

################################################################################
################################################################################

soaf_var_err_msg_notinenum() {
	local VAR=$1
	local VAL=$2
	local ENUM=$3
	local ENUM_DIS=$(soaf_dis_echo_list "$ENUM")
	SOAF_VAR_ERR_MSG="Value ($VAL) of variable [$VAR] not in enum [$ENUM_DIS]."
}

################################################################################
################################################################################

soaf_var_real_name() {
	local VAR=$1
	local PREFIX
	soaf_map_get_var PREFIX $VAR $SOAF_VAR_PREFIX_ATTR
	[ -n "$PREFIX" ] && SOAF_VAR_RET=${PREFIX}_$VAR || SOAF_VAR_RET=$VAR
}

################################################################################
################################################################################

soaf_var_prefix_name() {
	local VAR=$1
	local PREFIX=$2
	soaf_map_extend $VAR $SOAF_VAR_PREFIX_ATTR $PREFIX
	eval ${PREFIX}_$VAR=\$$VAR
}

################################################################################
################################################################################

soaf_var_check() {
	local VAR=$1
	local DFT_VAL
	soaf_map_get_var DFT_VAL $VAR $SOAF_VAR_DFT_VAL_ATTR
	soaf_var_real_name $VAR
	local VAR_REAL=$SOAF_VAR_RET
	eval local VAL=\$$VAR_REAL
	local RET="OK"
	local ERR_MSG=
	if [ -z "$VAL" -a -n "$DFT_VAL" ]
	then
		### Fix default value
		eval $VAR_REAL=\$DFT_VAL
	else
		if [ -z "$VAL" ]
		then
			### Check if val empty accepted
			local A_E
			soaf_map_get_var A_E $VAR $SOAF_VAR_ACCEPT_EMPTY_ATTR
			if [ -z "$A_E" ]
			then
				RET=
				ERR_MSG="Variable [$VAR] not filled."
			fi
		else
			local ENUM
			soaf_map_get_var ENUM $VAR $SOAF_VAR_ENUM_ATTR
			if [ -n "$ENUM" ]
			then
				### Check val in enum
				soaf_list_found "$ENUM" $VAL
				if [ -z "$SOAF_RET_LIST" ]
				then
					RET=
					soaf_var_err_msg_notinenum $VAR $VAL "$ENUM"
					ERR_MSG=$SOAF_VAR_ERR_MSG
				fi
			fi
		fi
	fi
	SOAF_VAR_RET=$RET
	SOAF_VAR_ERR_MSG=$ERR_MSG
}

################################################################################
################################################################################

soaf_var_add_unsubst() {
	local VAR_LIST=$1
	SOAF_VAR_UNSUBST_LIST="$SOAF_VAR_UNSUBST_LIST $VAR_LIST"
}

soaf_var_subst_proc() {
	local VAL=$1
	local VAR=$2
	eval local VAR_VAL=\$$VAR
	local RULE="sµ$SOAF_VAR_PAT_O$VAR${SOAF_VAR_PAT_C}µ${VAR_VAL}µg"
	SOAF_VAR_RET=$(echo "$VAL" | sed -e "$RULE")
}

soaf_var_subst() {
	local VAR=$1
	eval local VAL=\$$VAR
	local SUBST_OK=
	local __var
	for __var in $(echo "$VAL" | grep -o $SOAF_VAR_PAT_G | \
		sed -e s:$SOAF_VAR_PAT_O:: -e s:$SOAF_VAR_PAT_C:: | sort | uniq)
	do
		soaf_list_found "$SOAF_VAR_OKSUBST_LIST" $__var
		[ -z "$SOAF_RET_LIST" ] && soaf_var_subst $__var
		soaf_var_subst_proc "$VAL" $__var
		VAL=$SOAF_VAR_RET
		SUBST_OK="OK"
	done
	[ -n "$SUBST_OK" ] && eval $VAR=\$VAL
	SOAF_VAR_OKSUBST_LIST="$SOAF_VAR_OKSUBST_LIST $VAR"
}

soaf_var_subst_all() {
	local var
	for var in $SOAF_VAR_UNSUBST_LIST
	do
		soaf_var_subst $var
	done
}
