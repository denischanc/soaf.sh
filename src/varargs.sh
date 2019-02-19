################################################################################
################################################################################

SOAF_VARARGS_ARG_LIST_ATTR="soaf_varargs_arg_list"

SOAF_VARARGS_PP_SEP="--"

################################################################################
################################################################################

soaf_create_varargs_nature() {
	local NATURE=$1
	shift
	local ARGS
	while [ -n "$1" ]
	do
		ARGS="$ARGS \"$1\""
		shift
	done
	soaf_map_extend $NATURE $SOAF_VARARGS_ARG_LIST_ATTR "$ARGS"
}

################################################################################
################################################################################

soaf_varargs_fn_apply() {
	local NATURE=$1
	local FN=$2
	shift 2
	local ARGS
	while [ -n "$1" -a "$1" != "$SOAF_VARARGS_PP_SEP" ]
	do
		ARGS="$ARGS \"$1\""
		shift
	done
	shift
	local ARGS_NATURE
	soaf_map_get_var ARGS_NATURE $NATURE $SOAF_VARARGS_ARG_LIST_ATTR
	ARGS="$ARGS$ARGS_NATURE"
	while [ -n "$1" ]
	do
		ARGS="$ARGS \"$1\""
		shift
	done
	local CMD="$FN$ARGS"
	eval "$CMD"
}
