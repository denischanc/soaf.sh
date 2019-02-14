################################################################################
################################################################################

SOAF_UTIL_NOEXEC_FN_ATTR="soaf_util_noexec_fn"

SOAF_UTIL_DAY_PROP="soaf.util.day"

################################################################################
################################################################################

soaf_util_init() {
	soaf_info_add_var SOAF_NOEXEC_PROG_LIST
}

soaf_define_add_this_init_fn soaf_util_init

################################################################################
################################################################################

soaf_to_var() {
	local NAME=$1
	SOAF_RET=$(tr '.\-/' '___' << _EOF_
$NAME
_EOF_)
}

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

soaf_cfg_set() {
	local VAR=$1
	local VAL=$2
	eval $VAR=\${$VAR:-\$VAL}
}

################################################################################
################################################################################

soaf_map_var() {
	local NAME=$1
	local FIELD=$2
	soaf_to_var __${NAME}__$FIELD
}

soaf_map_extend() {
	local NAME=$1
	local FIELD=$2
	local VAL=$3
	soaf_map_var $NAME $FIELD
	eval $SOAF_RET=\$VAL
}

soaf_map_cat() {
	local NAME=$1
	local FIELD=$2
	local VAL=$3
	soaf_map_var $NAME $FIELD
	eval $SOAF_RET=\"\$$SOAF_RET \$VAL\"
}

soaf_map_get_var() {
	local VAR_DST=$1
	local NAME=$2
	local FIELD=$3
	local DFT=$4
	soaf_map_var $NAME $FIELD
	eval $VAR_DST=\${$SOAF_RET:-\$DFT}
}

################################################################################
################################################################################

soaf_noexec_prog() {
	local PROG=$1
	local FN=$2
	SOAF_NOEXEC_PROG_LIST="$SOAF_NOEXEC_PROG_LIST $PROG"
	soaf_map_extend $PROG $SOAF_UTIL_NOEXEC_FN_ATTR $FN
}

soaf_cmd() {
	local CMD=$1
	local LOG_LEVEL=${2:-$SOAF_LOG_DEBUG}
	local LOG_NAME=$3
	local NO_CMD_OUT_ERR_LOG=$4
	soaf_log $LOG_LEVEL "Execute command : [$CMD]." $LOG_NAME
	local CMD_PROG=$(echo "$CMD" | awk '{print $1}')
	local RET=
	soaf_list_found "$SOAF_NOEXEC_PROG_LIST" $CMD_PROG
	if [ -z "$SOAF_RET_LIST" ]
	then
		if [ -n "$NO_CMD_OUT_ERR_LOG" ]
		then
			eval "$CMD"
			RET=$?
		else
			soaf_log_prep_cmd_out_err $LOG_NAME
			eval "$CMD > $SOAF_LOG_CMD_OUT_FILE 2> $SOAF_LOG_CMD_ERR_FILE"
			RET=$?
			local LOG_LEVEL_ERR=
			[ $RET -eq 0 ] && LOG_LEVEL_ERR=$LOG_LEVEL
			soaf_log_cmd_out_err $LOG_NAME $LOG_LEVEL $LOG_LEVEL_ERR
		fi
		soaf_log $LOG_LEVEL "Command return : [$RET]." $LOG_NAME
	else
		local NOEXEC_FN
		soaf_map_get_var NOEXEC_FN $CMD_PROG $SOAF_UTIL_NOEXEC_FN_ATTR
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

soaf_fn_args_set_pid() {
	local FN_ARGS=$1
	local PID_FILE=$2
	local LOG_NAME=$3
	soaf_mkdir $(dirname $PID_FILE) "" $LOG_NAME
	echo "$$" > $PID_FILE
	eval "$FN_ARGS"
	rm -f $PID_FILE
}

soaf_fn_args_check_pid() {
	local FN_ARGS=$1
	local PID_FILE=$2
	local LOG_NAME=$3
	local PID_IN_PROG_MSG=$4
	local PID_IN_PROG_MSG_LVL=${5:-$SOAF_LOG_WARN}
	local ERR_ON_PID_WITHOUT_PROC=$6
	local RET="OK"
	local DO_FN_ARGS=
	local PID=$(cat $PID_FILE 2> /dev/null)
	if [ -n "$PID" ]
	then
		if [ -d /proc/$PID ]
		then
			soaf_var_subst_proc "$PID_IN_PROG_MSG" PID
			soaf_log $PID_IN_PROG_MSG_LVL "$SOAF_VAR_RET" $LOG_NAME
		else
			[ -n "$ERR_ON_PID_WITHOUT_PROC" ] && RET= || DO_FN_ARGS="OK"
		fi
	else
		DO_FN_ARGS="OK"
	fi
	[ -n "$DO_FN_ARGS" ] && soaf_fn_args_set_pid "$FN_ARGS" $PID_FILE $LOG_NAME
	SOAF_RET=$RET
}
