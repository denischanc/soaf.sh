################################################################################
################################################################################

soaf_arg_parse() {
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

################################################################################
################################################################################

while [ $# -ge 1 ]
do
	case $1 in
		--help | -h) ACTION=$SOAF_DEFINE_USAGE_ACTION;;
		*) soaf_arg_parse "$1";;
	esac
	shift
done
