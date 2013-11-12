################################################################################
################################################################################

soaf_create_action() {
	local ACTION="$1"
	local NO_INIT="$2"
	local FN="$3"
	SOAF_ACTION_LIST="$SOAF_ACTION_LIST $ACTION"
	if [ -n "$NO_INIT" ]
	then
		SOAF_ACTION_NOINIT_LIST="$SOAF_ACTION_NOINIT_LIST $ACTION"
	fi
	soaf_map_extend $ACTION "FN" $FN
}

################################################################################
################################################################################

soaf_create_action "usage" "NI" soaf_usage
soaf_create_action "version" "NI" soaf_version
soaf_create_action "info" "NI" soaf_info
### soaf_create_action "changelog" "NI" soaf_changelog



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
