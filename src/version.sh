################################################################################
################################################################################

soaf_info_add_var() {
	while [ $# -ge 1 ]
	do
		SOAF_INFO_VAR_LIST="$SOAF_INFO_VAR_LIST $1"
	done
}

################################################################################
################################################################################

SOAF_NAME="soaf"
SOAF_VERSION="0.1.0"

soaf_info_add_var SOAF_VERSION

GENTOP_INFO_VAR_LIST="GENTOP_VERSION GENTOP_HOME GENTOP_ACTION GENTOP_LOG_DIR"
GENTOP_INFO_VAR_LIST="$GENTOP_INFO_VAR_LIST GENTOP_LOG_LEVEL"
GENTOP_INFO_VAR_LIST="$GENTOP_INFO_VAR_LIST GENTOP_DAEMON_INACTIVE"
GENTOP_INFO_VAR_LIST="$GENTOP_INFO_VAR_LIST GENTOP_TASK"
GENTOP_INFO_VAR_LIST="$GENTOP_INFO_VAR_LIST GENTOP_ACTION_EXT_LIST"
GENTOP_INFO_VAR_LIST="$GENTOP_INFO_VAR_LIST GENTOP_PORTAGE_DIR"
GENTOP_INFO_VAR_LIST="$GENTOP_INFO_VAR_LIST GENTOP_ROLL_FILE_SIZE"
GENTOP_INFO_VAR_LIST="$GENTOP_INFO_VAR_LIST GENTOP_CF_LIST"

GENTOP_INFO_VAR_LIST="$GENTOP_INFO_VAR_LIST GENTOP_NOEXEC_PROG_LIST"

GENTOP_CHANGELOG_FILE="$GENTOP_HOME/lib/ChangeLog"

################################################################################
################################################################################

soaf_version() {
	echo "$SOAF_NAME-$SOAF_VERSION"
}

################################################################################
################################################################################

soaf_info() {
	for var in $SOAF_INFO_VAR_LIST
	do
		eval local VAL=\"\$$var\"
		cat << _EOF_
$var = [$VAL]
_EOF_
	done
}

################################################################################
################################################################################

gentop_changelog() {
	cat $GENTOP_CHANGELOG_FILE
}
