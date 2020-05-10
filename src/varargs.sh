################################################################################
################################################################################

readonly SOAF_VARARGS_ARG_LIST_ATTR="soaf_varargs_arg_list"

readonly SOAF_VARARGS_PP_SEP="--"

################################################################################
################################################################################

soaf_create_varargs_nature() {
	local NATURE=$1
	shift
	local ARGS
	while [ -n "$1" ]
	do
		ARGS+=("$1")
		shift
	done
	soaf_map_w_array_cat $NATURE $SOAF_VARARGS_ARG_LIST_ATTR ARGS
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
		ARGS+=("$1")
		shift
	done
	shift
	soaf_map_w_array_get $NATURE $SOAF_VARARGS_ARG_LIST_ATTR
	ARGS+=("${SOAF_RET[@]}")
	while [ -n "$1" ]
	do
		ARGS+=("$1")
		shift
	done
	local ARGS_WORD arg
	for arg in "${ARGS[@]}"
	do
		ARGS_WORD+=" \"$arg\""
	done
	local CMD="$FN$ARGS_WORD"
	eval "$CMD"
}
