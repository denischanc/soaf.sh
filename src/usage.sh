################################################################################
################################################################################

SOAF_USAGE_ACTION="usage"

################################################################################
################################################################################

soaf_usage() {
	local USER_NATURE=$1
	local USAGE_VAR_LIST=$(soaf_map_get $USER_NATURE \
		$SOAF_USER_USAGE_VAR_LIST_ATTR)
	USAGE_VAR_LIST="$SOAF_USAGE_VAR_LIST $USAGE_VAR_LIST"
	cat << _EOF_
${SOAF_TITLE_PRE}USAGE
${SOAF_TXT_PRE}usage: $0 ([variable]=[value])*
${SOAF_TXT_PRE}variable: [$(echo $USAGE_VAR_LIST | tr ' ' '|')]
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
