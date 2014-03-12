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
	local ARG=$1
	local VAR_TMP=$(echo "$ARG" | awk -F= '{print $1}')
	local VAL_TMP=$(echo "$ARG" | sed -e 's/[^=]*=//')
	if [ -n "$VAR_TMP" ]
	then
		eval $VAR_TMP=\$VAL_TMP
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
