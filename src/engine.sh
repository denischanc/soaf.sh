################################################################################
################################################################################

gentop_usage() {
	gentop_version
	cat << _EOF_
usage: $0 ([variable]=[value])*
variable: [$(echo $GENTOP_USAGE_VAR_LIST | tr ' ' '|')]
ACTION: [$(echo $GENTOP_ACTION_LIST | tr ' ' '|')]
(ACTION=task)TASK: [$(echo $GENTOP_TASK_LIST | tr ' ' '|')]
_EOF_
}

################################################################################
################################################################################

gentop_init() {
	gentop_init_mkdir
	gentop_log_init
}

################################################################################
################################################################################

soaf_engine() {
	local IS_ACTION="$(echo $SOAF_ACTION_LIST | grep -w $SOAF_ACTION)"
	if [ -z "$IS_ACTION" ]
	then
		soaf_usage
		exit
	fi
	local NOINIT="$(echo $SOAF_ACTION_NOINIT_LIST | grep -w $SOAF_ACTION)"
	if [ -z "$NOINIT" ]
	then
		soaf_init
	fi
	local VAR_FN=$(soaf_map_get "${GENTOP_ACTION}_FN"
	eval local FN=\"\$$VAR_FN\"
	if [ -z "$FN" ]
	then
		echo "No variable : $VAR_FN."
	else
		$FN
	fi
}
