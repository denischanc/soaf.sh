################################################################################
################################################################################

soaf_usage_add_var() {
	local VAR_LIST=$1
	SOAF_USAGE_VAR_LIST="$SOAF_USAGE_VAR_LIST $VAR_LIST"
}

################################################################################
################################################################################

soaf_cfg_set() {
	local VAR=$1
	local VAL=$2
	eval $VAR=\${$VAR:-\$VAL}
}

################################################################################
################################################################################

soaf_parse_arg() {
	local __ARG_TMP=$1
	local __VAR_TMP=$(echo "$__ARG_TMP" | awk -F= '{print $1}')
	if [ -n "$__VAR_TMP" ]
	then
		local __VAL_TMP=$(echo "$__ARG_TMP" | sed -e "s/^$__VAR_TMP=//")
		eval $__VAR_TMP=\$__VAL_TMP
	fi
}

################################################################################
################################################################################

soaf_mng_glob_var_loop() {
	local VAR_PRE=$1
	local LIST=$2
	for var in $LIST
	do
		eval local VAL_TMP=\$$var
		[ -n "$VAL_TMP" ] && eval ${VAR_PRE}_$var=\$VAL_TMP
	done
}

soaf_mng_glob_var() {
	soaf_mng_glob_var_loop "SOAF" "$SOAF_USAGE_VAR_LIST"
	local VAR_PRE=$(soaf_map_get $SOAF_USER_MAP "VAR_PRE")
	local USAGE_VAR_LIST=$(soaf_map_get $SOAF_USER_MAP "USAGE_VAR_LIST")
	soaf_mng_glob_var_loop "$VAR_PRE" "$USAGE_VAR_LIST"
}

################################################################################
################################################################################

soaf_check_var_list() {
	local VAR_LIST=$1
	local RET="OK" var VAL
	for var in $VAR_LIST
	do
		eval VAL=\$$var
		if [ -z "$VAL" ]
		then
			soaf_log_err "Empty variable : [$var] ???"
			RET=
		fi
	done
	SOAF_CHECK_RET=$RET
}
