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
	local VAR_FN=$(soaf_map_get "${GENTOP_ACTION}_FN")
	eval local FN=\"\$$VAR_FN\"
	if [ -z "$FN" ]
	then
		echo "No variable : $VAR_FN."
	else
		$FN
	fi
}


################################################################################
################################################################################

GENTOP_VAR_MKDIR_LIST="GENTOP_LOG_DAEMON_DIR"

################################################################################
################################################################################

GENTOP_LOG_FILE="$GENTOP_LOG_DIR/gentop.log"

################################################################################
################################################################################

gentop_init_mkdir() {
	if [ ! -d $GENTOP_LOG_DIR ]
	then
		mkdir -p $GENTOP_LOG_DIR
		gentop_log_info "Directory created : [$GENTOP_LOG_DIR]."
	fi
	for var_dir in $GENTOP_VAR_MKDIR_LIST
	do
		eval local DIR=\"\$$var_dir\"
		if [ ! -d $DIR ]
		then
			gentop_log_info "Create directory : [$DIR]."
			mkdir -p $DIR
		fi
	done
}
