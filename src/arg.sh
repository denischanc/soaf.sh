################################################################################
################################################################################

SOAF_ARG_ALL=("$@")

################################################################################
################################################################################

soaf_arg_parse_() {
	local __ARG_TMP=$1
	local __VAR_TMP=${__ARG_TMP%%=*}
	if [ -n "$__VAR_TMP" ]
	then
		local __VAL_TMP=${__ARG_TMP#$__VAR_TMP}
		__VAL_TMP=${__VAL_TMP#=}
		soaf_to_var $__VAR_TMP
		eval $SOAF_RET=\$__VAL_TMP 2> /dev/null
	fi
}

soaf_arg_parse_all() {
	local arg
	for arg in "${SOAF_ARG_ALL[@]}"
	do
		case $arg in
			--help|-h) ACTION=$SOAF_USAGE_ACTION;;
			*) soaf_arg_parse_ "$arg";;
		esac
	done
}
