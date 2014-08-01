################################################################################
################################################################################

soaf_info_add_var SOAF_NOEXEC_PROG_LIST

SOAF_UTIL_NOEXEC_FN_ATTR="soaf_util_noexec_fn"

SOAF_UTIL_DAY_PROP="soaf_util_day"

################################################################################
################################################################################

soaf_map_extend() {
	local NAME=$1
	local FIELD=$2
	local VAL=$3
	local VAR_NAME=__$(echo $NAME | tr '.-' '__')__$FIELD
	eval $VAR_NAME=\$VAL
}

soaf_map_get() {
	local NAME=$1
	local FIELD=$2
	local DFT=$3
	local VAR_NAME=__$(echo $NAME | tr '.-' '__')__$FIELD
	eval local VAL=\${$VAR_NAME:-\$DFT}
	echo "$VAL"
}

################################################################################
################################################################################

soaf_cmd() {
	local CMD=$1
	local LOG_LEVEL=${2:-$SOAF_LOG_DEBUG}
	local LOG_NAME=$3
	soaf_log $LOG_LEVEL "Execute command : [$CMD]." $LOG_NAME
	local CMD_PROG=$(echo "$CMD" | awk '{print $1}')
	local NOEXEC_PROG=$(echo "$SOAF_NOEXEC_PROG_LIST" | grep -w "$CMD_PROG")
	local RET=
	if [ -z "$NOEXEC_PROG" ]
	then
		eval "$CMD"
		RET=$?
		soaf_log $LOG_LEVEL "Command return : [$RET]." $LOG_NAME
	else
		local CMD_PROG_VAR=$(echo $CMD_PROG | tr '.-' '__')
		local NOEXEC_FN=$(soaf_map_get $CMD_PROG_VAR $SOAF_UTIL_NOEXEC_FN_ATTR)
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
	soaf_cmd "$CMD" $SOAF_LOG_INFO $LOG_NAME
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
		SOAF_DAY_DIFF=$(expr $DAY \- $DAY_LAST 2>> $SOAF_LOG_FILE)
		[ -z "$SOAF_DAY_DIFF" ] && SOAF_DAY_DIFF=0
		if [ $SOAF_DAY_DIFF -lt 0 ]
		then
			SOAF_DAY_DIFF=$(expr $SOAF_DAY_DIFF + 365)
		fi
		SOAF_RET="OK"
	fi
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
	local LOG_NAME=$3
	local RET=0
	for dir in $DIR_LIST
	do
		if [ ! -d "$dir" ]
		then
			soaf_cmd "mkdir -p $dir >> $SOAF_LOG_FILE 2>&1" "" $LOG_NAME
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
		soaf_cmd "rm -rf $PATH_LIST >> $SOAF_LOG_FILE 2>&1" "" $LOG_NAME
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
