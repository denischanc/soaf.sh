################################################################################
################################################################################

soaf_cfg_cfg() {
	local APPLI_NAME=$(soaf_module_this_appli_name)
	soaf_cfg_set SOAF_WORK_DIR $HOME/work/$APPLI_NAME
	soaf_cfg_set SOAF_LOG_DIR $SOAF_WORK_DIR/log
	soaf_cfg_set SOAF_NOTIF_DIR $SOAF_WORK_DIR/notif
}

soaf_cfg_init() {
	soaf_info_add_var "SOAF_WORK_DIR SOAF_LOG_DIR SOAF_NOTIF_DIR"
	soaf_info_add_var "SOAF_EXT_GLOB_DIR SOAF_EXT_LOC_DIR"
}

soaf_define_add_this_cfg_fn soaf_cfg_cfg
soaf_define_add_this_init_fn soaf_cfg_init

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
	local __VAR_TMP=${__ARG_TMP%%=*}
	if [ -n "$__VAR_TMP" ]
	then
		local __VAL_TMP=${__ARG_TMP#$__VAR_TMP}
		__VAL_TMP=${__VAL_TMP#=}
		eval $(soaf_to_var $__VAR_TMP)=\$__VAL_TMP 2> /dev/null
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
	case $1 in
		--help | -h) ACTION=$SOAF_DEFINE_USAGE_ACTION ;;
		*) soaf_parse_arg "$1" ;;
	esac
	shift
done
