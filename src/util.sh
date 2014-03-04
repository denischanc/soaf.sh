################################################################################
################################################################################

soaf_info_add_var SOAF_NOEXEC_PROG_LIST

################################################################################
################################################################################

soaf_map_extend() {
	local NAME=$1
	local FIELD=$2
	local VAL=$3
	eval ${NAME}__$FIELD=\$VAL
}

soaf_map_get() {
	local NAME=$1
	local FIELD=$2
	local DFT=$3
	eval local VAL=\${${NAME}__$FIELD:-\$DFT}
	echo "$VAL"
}

################################################################################
################################################################################

soaf_cmd() {
	local CMD=$1
	local LOG_LEVEL=${2:-$SOAF_LOG_DEBUG}
	soaf_log $LOG_LEVEL "Execute command : [$CMD]."
	local CMD_PROG=$(echo "$CMD" | awk '{print $1}')
	local NOEXEC_PROG=$(echo "$SOAF_NOEXEC_PROG_LIST" | grep -w "$CMD_PROG")
	local RET=
	if [ -z "$NOEXEC_PROG" ]
	then
		eval "$CMD"
		RET=$?
		soaf_log $LOG_LEVEL "Command return : [$RET]."
	else
		local CMD_PROG_VAR=$(echo $CMD_PROG | tr '.-' '__')
		local NOEXEC_FN=$(soaf_map_get $CMD_PROG_VAR "NOEXEC_FN")
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
	soaf_cmd "$CMD" $SOAF_LOG_INFO
}

################################################################################
################################################################################

soaf_day_curr() {
	local DAY_CURR=$(date '+%j')
	echo $DAY_CURR
}

soaf_day_upd_file() {
	local DAY_CURR=$1
	local FILE=$2
	local ROLL_NATURE=$3
	[ -n "$ROLL_NATURE" ] && soaf_roll_nature $ROLL_NATURE
	echo "$DAY_CURR" > $FILE
}

soaf_day_since_last() {
	local DAY_CURR=$1
	local FILE=$2
	[ -z "$DAY_CURR" ] && DAY_CURR=$(soaf_day_curr)
	local DAY_LAST=
	[ -f "$FILE" ] && DAY_LAST=$(cat $FILE | head -1)
	[ -z "$DAY_LAST" ] && DAY_LAST=1
	local DAY_DIFF=$(expr $DAY_CURR \- $DAY_LAST 2> /dev/null)
	[ -z "$DAY_DIFF" ] && DAY_DIFF=0
	if [ $DAY_DIFF -lt 0 ]
	then
		DAY_DIFF=$(expr $DAY_DIFF + 365)
	fi
	echo $DAY_DIFF
}

################################################################################
################################################################################

soaf_to_upper() {
	local VAL=$1
	local VAL_TO_UPPER=$(echo "$VAL" | tr 'a-z' 'A-Z')
	echo "$VAL_TO_UPPER"
}

################################################################################
################################################################################

soaf_mkdir() {
	local DIR_LIST=$1 dir
	local LOG_LEVEL=${2:-$SOAF_LOG_DEBUG}
	local RET=0
	for dir in $DIR_LIST
	do
		if [ ! -d "$dir" ]
		then
			soaf_cmd "mkdir -p $dir >> $SOAF_LOG_FILE 2>&1"
			[ $RET -eq 0 ] && RET=$SOAF_RET
			if [ $SOAF_RET -eq 0 ]
			then
				soaf_log $LOG_LEVEL "Directory created : [$dir]."
			else
				soaf_log_err "Directory not created : [$dir]."
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
	local RET=0
	if [ -n "$PATH_LIST" ]
	then
		soaf_cmd "rm -rf $PATH_LIST >> $SOAF_LOG_FILE 2>&1"
		RET=$SOAF_RET
		if [ $SOAF_RET -eq 0 ]
		then
			soaf_log $LOG_LEVEL "Path(s) removed : [$PATH_LIST]."
		else
			soaf_log_err "Path(s) not removed : [$PATH_LIST]."
		fi
	fi
	SOAF_RET=$RET
}
