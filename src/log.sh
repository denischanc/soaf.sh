################################################################################
################################################################################

SOAF_LOG_ERR="ERR__"
SOAF_LOG_WARN="WARN_"
SOAF_LOG_INFO="INFO_"
SOAF_LOG_DEBUG="DEBUG"

SOAF_LOG_NATURE_INT="soaf.log.native"
SOAF_LOG_ROLL_NATURE_INT="soaf.log.roll"

SOAF_LOG_LEVEL_ATTR="soaf_log_level"

SOAF_LOG_FN_ATTR="soaf_log_fn"

################################################################################
################################################################################

soaf_log_cfg() {
	soaf_cfg_set SOAF_LOG_LEVEL $SOAF_LOG_INFO
	###---------------
	soaf_cfg_set SOAF_LOG_USED_NATURE $SOAF_LOG_NATURE_INT
	soaf_cfg_set SOAF_LOG_ROLL_NATURE $SOAF_LOG_ROLL_NATURE_INT
	###---------------
	soaf_cfg_set SOAF_LOG_FILE $SOAF_LOG_DIR/$SOAF_USER_NAME.log
	soaf_cfg_set SOAF_LOG_CMD_OUT_ERR_DIR $SOAF_LOG_DIR
	SOAF_LOG_CMD_OUT_FILE=$SOAF_LOG_CMD_OUT_ERR_DIR/$SOAF_USER_NAME.cmd.out
	SOAF_LOG_CMD_ERR_FILE=$SOAF_LOG_CMD_OUT_ERR_DIR/$SOAF_USER_NAME.cmd.err
}

soaf_log_init() {
	soaf_info_add_var "SOAF_LOG_LEVEL SOAF_LOG_FILE SOAF_LOG_USED_NATURE"
	soaf_info_add_var SOAF_LOG_CMD_OUT_ERR_DIR
	###---------------
	soaf_create_log_nature $SOAF_LOG_NATURE_INT soaf_log_int
	soaf_create_roll_cond_gt_nature $SOAF_LOG_ROLL_NATURE_INT $SOAF_LOG_FILE
}

soaf_log_preplog() {
	[ "$SOAF_LOG_USED_NATURE" = "$SOAF_LOG_NATURE_INT" ] && \
		mkdir -p $(dirname $SOAF_LOG_FILE)
}

soaf_define_add_this_cfg_fn soaf_log_cfg
soaf_define_add_this_init_fn soaf_log_init
soaf_define_add_this_preplog_fn soaf_log_preplog

################################################################################
################################################################################

soaf_create_log_nature() {
	local NATURE=$1
	local FN=$2
	soaf_map_extend $NATURE $SOAF_LOG_FN_ATTR $FN
}

################################################################################
################################################################################

soaf_all_log_level() {
	local LOG_LEVEL=$1 fn
	for fn in $SOAF_NAME_LOGLVL_FN_LIST
	do
		$fn $LOG_LEVEL
	done
}

soaf_log_name_log_level() {
	local NAME=$1
	local LEVEL=$2
	soaf_map_extend "$NAME" $SOAF_LOG_LEVEL_ATTR $LEVEL
}

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

soaf_log_filter() {
	local FN=$1
	local LEVEL=$2
	local MSG=$3
	local NAME=$4
	local MSG_LEVEL_NUM=$(soaf_log_num_level $LEVEL)
	local CUR_LEVEL=$SOAF_LOG_LEVEL
	[ -n "$NAME" ] && \
		CUR_LEVEL=$(soaf_map_get $NAME $SOAF_LOG_LEVEL_ATTR $CUR_LEVEL)
	local CUR_LEVEL_NUM=$(soaf_log_num_level $CUR_LEVEL)
	[ $MSG_LEVEL_NUM -ge $CUR_LEVEL_NUM ] && $FN $LEVEL "$MSG" $NAME
}

################################################################################
################################################################################

soaf_log_add_msg_int() {
	local LEVEL=$1
	local MSG=$2
	local NAME=$3
	if [ -z "$SOAF_LOG_ROLL_IN" ]
	then
		SOAF_LOG_ROLL_IN="OK"
		soaf_roll_nature $SOAF_LOG_ROLL_NATURE
		SOAF_LOG_ROLL_IN=
	fi
	[ -n "$NAME" ] && MSG="{$NAME} $MSG"
	cat << _EOF_ >> $SOAF_LOG_FILE
[$(date '+%x_%X')][$LEVEL]  $MSG
_EOF_
}

soaf_log_int() {
	local LEVEL=$1
	local MSG=$2
	local NAME=$3
	soaf_log_filter soaf_log_add_msg_int $LEVEL "$MSG" $NAME
}

################################################################################
################################################################################

soaf_log() {
	local LEVEL=$1
	local MSG=$2
	local NAME=$3
	local FN=$(soaf_map_get $SOAF_LOG_USED_NATURE $SOAF_LOG_FN_ATTR)
	[ -n "$FN" ] && $FN $LEVEL "$MSG" $NAME
}

################################################################################
################################################################################

soaf_log_err() {
	local MSG=$1
	local NAME=$2
	soaf_log $SOAF_LOG_ERR "$MSG" $NAME
}

soaf_log_warn() {
	local MSG=$1
	local NAME=$2
	soaf_log $SOAF_LOG_WARN "$MSG" $NAME
}

soaf_log_info() {
	local MSG=$1
	local NAME=$2
	soaf_log $SOAF_LOG_INFO "$MSG" $NAME
}

soaf_log_debug() {
	local MSG=$1
	local NAME=$2
	soaf_log $SOAF_LOG_DEBUG "$MSG" $NAME
}

################################################################################
################################################################################

soaf_log_stdin() {
	local LEVEL=${1:-$SOAF_LOG_ERR}
	local NAME=$2
	local line
	while read line
	do
		soaf_log $LEVEL "$line" $NAME
	done
}

soaf_log_from_file() {
	local FILE=$1
	local LEVEL=$2
	local NAME=$3
	if [ -s "$FILE" ]
	then
		cat $FILE | soaf_log_stdin "$LEVEL" $NAME
	fi
	rm -f $FILE 2> /dev/null
}

################################################################################
################################################################################

soaf_log_prep_cmd_out_err() {
	local NAME=$1
	[ ! -d "$SOAF_LOG_CMD_OUT_ERR_DIR" ] && \
		mkdir -p $SOAF_LOG_CMD_OUT_ERR_DIR |& soaf_log_stdin "" $NAME
}

soaf_log_cmd_out() {
	local NAME=$1
	local LEVEL=${2:-$SOAF_LOG_DEBUG}
	soaf_log_from_file $SOAF_LOG_CMD_OUT_FILE $LEVEL $NAME
}

soaf_log_cmd_err() {
	local NAME=$1
	local LEVEL=${2:-$SOAF_LOG_ERR}
	soaf_log_from_file $SOAF_LOG_CMD_ERR_FILE $LEVEL $NAME
}

soaf_log_cmd_out_err() {
	local NAME=$1
	local OUT_LEVEL=$2
	local ERR_LEVEL=$3
	soaf_log_cmd_out "$NAME" $OUT_LEVEL
	soaf_log_cmd_err "$NAME" $ERR_LEVEL
}
