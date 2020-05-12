################################################################################
################################################################################

readonly SOAF_UTIL_NOEXEC_FN_ATTR="soaf_util_noexec_fn"

readonly SOAF_UTIL_DAY_PROP="soaf.util.day"

readonly SOAF_IN_PROG_RET="in_prog"
readonly SOAF_ERR_RET="err"
readonly SOAF_OK_RET="ok"

################################################################################
################################################################################

soaf_util_init_() {
	soaf_info_add_var SOAF_NOEXEC_PROG_LIST
}

soaf_create_module soaf.core.util $SOAF_VERSION "" "" soaf_util_init_

################################################################################
################################################################################

soaf_upper() {
	local NAME=$1
	SOAF_RET=${NAME^^}
}

soaf_lower() {
	local NAME=$1
	SOAF_RET=${NAME,,}
}

soaf_to_upper_var() {
	local NAME=$1
	soaf_to_var $NAME
	soaf_upper $SOAF_RET
}

################################################################################
################################################################################

soaf_noexec_prog() {
	local PROG=$1
	local FN=$2
	SOAF_NOEXEC_PROG_LIST+=" $PROG"
	soaf_map_extend $PROG $SOAF_UTIL_NOEXEC_FN_ATTR $FN
}

soaf_cmd() {
	local CMD=$1
	local LOG_LEVEL=${2:-$SOAF_LOG_DEBUG}
	local LOG_NAME=$3
	local NO_CMD_OUT_ERR_LOG=$4
	soaf_log $LOG_LEVEL "Execute command : [$CMD]." $LOG_NAME
	local CMD_PROG=$(echo "$CMD" | awk '{print $1}')
	local RET
	soaf_list_found "$SOAF_NOEXEC_PROG_LIST" $CMD_PROG
	if [ -z "$SOAF_RET_LIST" ]
	then
		if [ -n "$NO_CMD_OUT_ERR_LOG" ]
		then
			eval "$CMD"
			RET=$?
		else
			soaf_log_prep_cmd_out_err "$CMD" $LOG_NAME
			eval "$SOAF_LOG_RET"
			RET=$?
			local LOG_LEVEL_ERR=
			[ $RET -eq 0 ] && LOG_LEVEL_ERR=$LOG_LEVEL
			soaf_log_cmd_out_err $LOG_NAME $LOG_LEVEL $LOG_LEVEL_ERR
		fi
		soaf_log $LOG_LEVEL "Command return : [$RET]." $LOG_NAME
	else
		soaf_map_get $CMD_PROG $SOAF_UTIL_NOEXEC_FN_ATTR
		local NOEXEC_FN=$SOAF_RET
		SOAF_RET=
		if [ -n "$NOEXEC_FN" ]
		then
			$NOEXEC_FN "$CMD" $CMD_PROG
		fi
		RET=${SOAF_RET:-0}
	fi
	SOAF_RET=$RET
}

soaf_cmd_info() {
	local CMD=$1
	local LOG_NAME=$2
	local NO_CMD_OUT_ERR_LOG=$3
	soaf_cmd "$CMD" $SOAF_LOG_INFO "$LOG_NAME" $NO_CMD_OUT_ERR_LOG
}

################################################################################
################################################################################

soaf_day_cur() {
	SOAF_DAY_CUR=$(date '+%j')
}

soaf_day_upd_file() {
	local DAY=$1
	local PROP_FILE_NATURE=$2
	local PROP=${3:-$SOAF_UTIL_DAY_PROP}
	if [ -z "$DAY" ]
	then
		soaf_day_cur
		DAY=$SOAF_DAY_CUR
	fi
	soaf_prop_file_set $PROP_FILE_NATURE $PROP $DAY
	[ -n "$SOAF_PROP_FILE_RET" ] && SOAF_RET="OK" || SOAF_RET=
}

soaf_day_since_last() {
	local DAY=$1
	local PROP_FILE_NATURE=$2
	local PROP=${3:-$SOAF_UTIL_DAY_PROP}
	if [ -z "$DAY" ]
	then
		soaf_day_cur
		DAY=$SOAF_DAY_CUR
	fi
	soaf_prop_file_get $PROP_FILE_NATURE $PROP
	if [ -z "$SOAF_PROP_FILE_RET" ]
	then
		SOAF_RET=
	else
		local DAY_LAST=$SOAF_PROP_FILE_VAL
		[ -z "$DAY_LAST" ] && DAY_LAST=1
		SOAF_DAY_DIFF=$(($DAY - $DAY_LAST))
		if [ $SOAF_DAY_DIFF -lt 0 ]
		then
			SOAF_DAY_DIFF=$(($SOAF_DAY_DIFF + 365))
		fi
		SOAF_RET="OK"
	fi
}

################################################################################
################################################################################

soaf_mkdir() {
	local DIR_LIST=$1 dir
	local LOG_LEVEL=${2:-$SOAF_LOG_DEBUG}
	local LOG_NAME=$3
	local RET=0
	for dir in $DIR_LIST
	do
		if [ ! -d "$dir" ]
		then
			soaf_cmd "mkdir -p $dir" "" $LOG_NAME
			[ $RET -eq 0 ] && RET=$SOAF_RET
			if [ $SOAF_RET -eq 0 ]
			then
				soaf_log $LOG_LEVEL "Directory created : [$dir]." $LOG_NAME
			else
				soaf_log_err "Directory not created : [$dir]." $LOG_NAME
			fi
		fi
	done
	SOAF_RET=$RET
}

################################################################################
################################################################################

soaf_rm() {
	local PATH_LIST=$1
	local LOG_LEVEL=${2:-$SOAF_LOG_DEBUG}
	local LOG_NAME=$3
	local RET=0
	if [ -n "$PATH_LIST" ]
	then
		soaf_cmd "rm -rf $PATH_LIST" "" $LOG_NAME
		RET=$SOAF_RET
		if [ $SOAF_RET -eq 0 ]
		then
			soaf_log $LOG_LEVEL "Path(s) removed : [$PATH_LIST]." $LOG_NAME
		else
			soaf_log_err "Path(s) not removed : [$PATH_LIST]." $LOG_NAME
		fi
	fi
	SOAF_RET=$RET
}

################################################################################
################################################################################

soaf_check_var_list() {
	local VAR_LIST=$1
	local RET="OK" var VAL
	for var in $VAR_LIST
	do
		eval VAL=\$$var
		if [ -z "$VAL" ]
		then
			soaf_log_err "Empty variable : [$var] ???"
			RET=
		fi
	done
	SOAF_RET=$RET
}

################################################################################
################################################################################

soaf_fn_args_set_pid_() {
	local FN_ARGS=$1
	local PID_FILE=$2
	local LOG_NAME=$3
	soaf_mkdir $(dirname $PID_FILE) "" $LOG_NAME
	echo "$$" > $PID_FILE 2> /dev/null
	if [ $? -eq 0 ]
	then
		eval "$FN_ARGS"
		soaf_rm $PID_FILE
		SOAF_RET="OK"
	else
		soaf_log_err "Unable to write pid in [$PID_FILE]." $LOG_NAME
		SOAF_RET=
	fi
}

soaf_fn_args_check_pid() {
	local FN_ARGS=$1
	local PID_FILE=$2
	local LOG_NAME=$3
	local ERR_ON_PID_WITHOUT_PROC=$4
	local PID=
	if [ -f $PID_FILE ]
	then
		PID=$(cat $PID_FILE 2> /dev/null)
		if [ $? -ne 0 ]
		then
			soaf_log_err "Unable to read pid file : [$PID_FILE]." $LOG_NAME
			SOAF_RET=$SOAF_ERR_RET
			return
		fi
	fi
	local RET=$SOAF_OK_RET
	local DO_FN_ARGS=
	if [ -n "$PID" ]
	then
		if [ -d /proc/$PID ]
		then
			RET=$SOAF_IN_PROG_RET
		else
			if [ -n "$ERR_ON_PID_WITHOUT_PROC" ]
			then
				soaf_log_err "No process for pid in [$PID_FILE]." $LOG_NAME
				RET=$SOAF_ERR_RET
			else
				DO_FN_ARGS="OK"
			fi
		fi
	else
		DO_FN_ARGS="OK"
	fi
	if [ -n "$DO_FN_ARGS" ]
	then
		soaf_fn_args_set_pid_ "$FN_ARGS" $PID_FILE $LOG_NAME
		[ -z "$SOAF_RET" ] && RET=$SOAF_ERR_RET
	fi
	SOAF_RET=$RET
}

################################################################################
################################################################################

soaf_read_stdin() {
	read -r
}
