################################################################################
################################################################################

SOAF_USAGE_ACTION="usage"

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

soaf_usage() {
	cat << _EOF_
${SOAF_TITLE_PRE}USAGE
${SOAF_TXT_PRE}usage: $0 ([variable]=[value])*
${SOAF_TXT_PRE}variable: [$(echo $SOAF_USAGE_VAR_LIST | tr ' ' '|')]
${SOAF_TXT_PRE}ACTION: [$(echo $SOAF_ACTION_LIST | tr ' ' '|')]
_EOF_
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
