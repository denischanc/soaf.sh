################################################################################
################################################################################

SOAF_LOG_ERR="ERR__"
SOAF_LOG_WARN="WARN_"
SOAF_LOG_INFO="INFO_"
SOAF_LOG_DEBUG="DEBUG"

SOAF_LOG_ROLL_NATURE_INT="soaf_log"

################################################################################
################################################################################

SOAF_LOG_LEVEL=$SOAF_LOG_INFO

SOAF_LOG_ROLL_NATURE=$SOAF_LOG_ROLL_NATURE_INT
SOAF_LOG_FILE=$SOAF_NAME.log

soaf_info_add_var "SOAF_LOG_LEVEL SOAF_LOG_FILE"

################################################################################
################################################################################

soaf_log_num_level() {
	local LEVEL=$1
	case $LEVEL in
		$SOAF_LOG_INFO) echo "2";;
		$SOAF_LOG_WARN) echo "3";;
		$SOAF_LOG_ERR) echo "4";;
		*) echo "1";;
	esac
}

################################################################################
################################################################################

soaf_log() {
	local LEVEL=$1
	local MSG=$2
	local LEVEL_LOC_NUM=$(soaf_log_num_level $LEVEL)
	local LEVEL_GLOB_NUM=$(soaf_log_num_level $SOAF_LOG_LEVEL)
	if [ $LEVEL_LOC_NUM -ge $LEVEL_GLOB_NUM ]
	then
		if [ -z "$SOAF_LOG_ROLL_IN" ]
		then
			SOAF_LOG_ROLL_IN="OK"
			soaf_roll_nature $SOAF_LOG_ROLL_NATURE
			SOAF_LOG_ROLL_IN=
		fi
		cat << _EOF_ >> $SOAF_LOG_FILE
[$(date '+%x_%X')][$LEVEL]  $MSG
_EOF_
	fi
}

################################################################################
################################################################################

soaf_log_err() {
	local MSG=$1
	soaf_log $SOAF_LOG_ERR "$MSG"
}

soaf_log_warn() {
	local MSG=$1
	soaf_log $SOAF_LOG_WARN "$MSG"
}

soaf_log_info() {
	local MSG=$1
	soaf_log $SOAF_LOG_INFO "$MSG"
}

soaf_log_debug() {
	local MSG=$1
	soaf_log $SOAF_LOG_DEBUG "$MSG"
}

################################################################################
################################################################################

soaf_log_init() {
	if [ $SOAF_LOG_ROLL_NATURE = $SOAF_LOG_ROLL_NATURE_INT ]
	then
		soaf_create_roll_cond_gt_nature $SOAF_LOG_ROLL_NATURE $SOAF_LOG_FILE
		mkdir -p $(dirname $SOAF_LOG_FILE)
	fi
}
