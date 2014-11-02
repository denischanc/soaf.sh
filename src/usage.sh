################################################################################
################################################################################

SOAF_USAGE_ACTION="usage"

SOAF_USAGE_VAR_ENUM_ATTR="soaf_usage_var_enum"
SOAF_USAGE_VAR_FN_ATTR="soaf_usage_var_fn"

################################################################################
################################################################################

soaf_usage_add_var() {
	local VAR_LIST=$1
	local PREFIX=$2
	SOAF_USAGE_VAR_LIST="$SOAF_USAGE_VAR_LIST $VAR_LIST"
	if [ -n "$PREFIX" ]
	then
		local var
		for var in $VAR_LIST
		do
			eval local __VAL_TMP=\$$var
			[ -n "$__VAL_TMP" ] && eval ${PREFIX}_$var=\$__VAL_TMP
		done
	fi
}

################################################################################
################################################################################

soaf_usage_def_var() {
	local VAR=$1
	local ENUM=$2
	local FN=$3
	soaf_map_extend $VAR $SOAF_USAGE_VAR_ENUM_ATTR "$ENUM"
	soaf_map_extend $VAR $SOAF_USAGE_VAR_FN_ATTR $FN
}

################################################################################
################################################################################

soaf_usage() {
	cat << _EOF_
${SOAF_TITLE_PRE}USAGE
${SOAF_TXT_PRE}usage: $0 ([variable]=[value])*
${SOAF_TXT_PRE}variable: [$(echo $SOAF_USAGE_VAR_LIST | tr ' ' '|')]
_EOF_
	### Variables
	local var
	for var in $SOAF_USAGE_VAR_LIST
	do
		local VAR_ENUM=$(soaf_map_get $var $SOAF_USAGE_VAR_ENUM_ATTR)
		local VAR_FN=$(soaf_map_get $var $SOAF_USAGE_VAR_FN_ATTR)
		if [ -n "$VAR_ENUM" -o -n "$VAR_FN" ]
		then
			local VAR_TXT="$var:"
			[ -n "$VAR_ENUM" ] && \
				VAR_TXT="$VAR_TXT [$(echo $VAR_ENUM | tr ' ' '|')]"
			soaf_dis_txt "$VAR_TXT"
			[ -n "$VAR_FN" ] && $VAR_FN $var
		fi
	done
	### Actions
	local action
	for action in $SOAF_ACTION_LIST
	do
		local USAGE_FN=$(soaf_map_get $action $SOAF_ACTION_USAGE_FN_ATTR)
		if [ -n "$USAGE_FN" ]
		then
			soaf_dis_title "ACTION=$action"
			$USAGE_FN
		fi
	done
}
