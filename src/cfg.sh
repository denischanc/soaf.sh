################################################################################
################################################################################

soaf_cfg__() {
	local USER_NATURE=$1
	local USER_NAME=$(soaf_map_get $USER_NATURE $SOAF_USER_NAME_ATTR)
	soaf_cfg_set SOAF_WORK_DIR $HOME/work/$USER_NAME
	soaf_cfg_set SOAF_LOG_DIR $SOAF_WORK_DIR/log
}

soaf_cfg_init() {
	soaf_info_add_var "SOAF_WORK_DIR SOAF_LOG_DIR"
	soaf_info_add_var "SOAF_EXT_GLOB_DIR SOAF_EXT_LOC_DIR"
}

soaf_engine_add_cfg_fn soaf_cfg__
soaf_engine_add_init_fn soaf_cfg_init

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
		local __VAL_TMP=${__ARG_TMP#$__VAR_TMP=}
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
	local USER_NATURE=$1
	soaf_mng_glob_var_loop "SOAF" "$SOAF_USAGE_VAR_LIST"
	local VAR_PRE=$(soaf_map_get $USER_NATURE $SOAF_USER_VAR_PRE_ATTR)
	local USAGE_VAR_LIST=$(soaf_map_get $USER_NATURE \
		$SOAF_USER_USAGE_VAR_LIST_ATTR)
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

################################################################################
################################################################################

while [ $# -ge 1 ]
do
	soaf_parse_arg "$1"
	shift
done
