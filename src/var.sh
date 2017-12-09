################################################################################
################################################################################

SOAF_VAR_ENUM_ATTR="soaf_var_enum"
SOAF_VAR_DFT_VAL_ATTR="soaf_var_dft_val"
SOAF_VAR_ACCEPT_EMPTY_ATTR="soaf_var_accept_empty"

SOAF_VAR_PREFIX_ATTR="soaf_var_prefix"

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
	local PREFIX=$(soaf_map_get $VAR $SOAF_VAR_PREFIX_ATTR)
	[ -n "$PREFIX" ] && echo ${PREFIX}_$VAR || echo $VAR
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
	local DFT_VAL=$(soaf_map_get $VAR $SOAF_VAR_DFT_VAL_ATTR)
	local VAR_REAL=$(soaf_var_real_name $VAR)
	eval local VAL=\$$VAR_REAL
	SOAF_VAR_RET="OK"
	if [ -z "$VAL" -a -n "$DFT_VAL" ]
	then
		### Fix default value
		eval $VAR_REAL=\$DFT_VAL
	else
		if [ -z "$VAL" ]
		then
			### Check if val empty accepted
			local A_E=$(soaf_map_get $VAR $SOAF_VAR_ACCEPT_EMPTY_ATTR)
			if [ -z "$A_E" ]
			then
				SOAF_VAR_RET=
				SOAF_VAR_ERR_MSG="Variable [$VAR] not filled."
			fi
		else
			local ENUM=$(soaf_map_get $VAR $SOAF_VAR_ENUM_ATTR)
			if [ -n "$ENUM" ]
			then
				### Check val in enum
				soaf_list_found "$ENUM" $VAL
				if [ -z "$SOAF_RET_LIST" ]
				then
					SOAF_VAR_RET=
					soaf_var_err_msg_notinenum $VAR $VAL "$ENUM"
				fi
			fi
		fi
	fi
}
