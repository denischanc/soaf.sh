################################################################################
################################################################################

SOAF_LOG_ERR="ERR  "
SOAF_LOG_WARN="WARN "
SOAF_LOG_INFO="INFO "
SOAF_LOG_DEBUG="DEBUG"

################################################################################
################################################################################

GENTOP_ROLL_NATURE_LOG="log"
log_ROLL_FILE="$GENTOP_LOG_FILE"
log_ROLL_COND_FN="gentop_roll_cond_gt_size"

################################################################################
################################################################################

gentop_log_num_level() {
	local LEVEL="$1"
	case "$LEVEL" in
		"$GENTOP_LOG_INFO") echo "2";;
		"$GENTOP_LOG_WARN") echo "3";;
		"$GENTOP_LOG_ERR") echo "4";;
		*) echo "1";;
	esac
}

################################################################################
################################################################################

gentop_log() {
	local LEVEL="$1"
	local MSG="$2"
	local LEVEL_LOC_NUM=$(gentop_log_num_level "$LEVEL")
	local LEVEL_GLOB_NUM=$(gentop_log_num_level "$GENTOP_LOG_LEVEL")
	if [ $LEVEL_LOC_NUM -ge $LEVEL_GLOB_NUM ]
	then
		cat << _EOF_ >> $GENTOP_LOG_FILE
[$(date '+%x_%X')][$LEVEL]  $MSG
_EOF_
	fi
}

################################################################################
################################################################################

gentop_log_err() {
	local MSG="$1"
	gentop_log "$GENTOP_LOG_ERR" "$MSG"
}

gentop_log_warn() {
	local MSG="$1"
	gentop_log "$GENTOP_LOG_WARN" "$MSG"
}

gentop_log_info() {
	local MSG="$1"
	gentop_log "$GENTOP_LOG_INFO" "$MSG"
}

gentop_log_debug() {
	local MSG="$1"
	gentop_log "$GENTOP_LOG_DEBUG" "$MSG"
}

################################################################################
################################################################################

gentop_log_init() {
	gentop_roll_nature "$GENTOP_ROLL_NATURE_LOG"
}
