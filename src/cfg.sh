################################################################################
################################################################################

soaf_cfg__() {
	soaf_cfg_set SOAF_WORK_DIR $HOME/work/$SOAF_USER_NAME
	soaf_cfg_set SOAF_LOG_DIR $SOAF_WORK_DIR/log
}

soaf_cfg_init() {
	soaf_info_add_var "SOAF_WORK_DIR SOAF_LOG_DIR"
	soaf_info_add_var "SOAF_EXT_GLOB_DIR SOAF_EXT_LOC_DIR"
}

soaf_define_add_engine_cfg_fn soaf_cfg__
soaf_define_add_engine_init_fn soaf_cfg_init

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
