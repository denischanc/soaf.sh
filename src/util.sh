################################################################################
################################################################################

soaf_map_extend() {
	local NAME="$1"
	local FIELD="$2"
	local VAL="$3"
	eval ${NAME}__$FIELD=\"$VAL\"
}

soaf_map_get() {
	local NAME="$1"
	local FIELD="$2"
	local DFT="$3"
	eval local VAL=\"\${${NAME}__$FIELD:-$DFT}\"
	echo "$VAL"
}

################################################################################
################################################################################

soaf_cmd() {
	local CMD="$1"
	local LOG_LEVEL="$2"
	[ -z "$LOG_LEVEL" ] && LOG_LEVEL="$SOAF_LOG_DEBUG"
	soaf_log "$LOG_LEVEL" "Execute command : [$CMD]."
	local CMD_PROG=$(echo "$CMD" | awk '{print $1}')
	local NOEXEC_PROG=$(echo "$SOAF_NOEXEC_PROG_LIST" | grep -w $CMD_PROG)
	if [ -z "$NOEXEC_PROG" ]
	then
		eval "$CMD"
		SOAF_RET="$?"
		soaf_log "$LOG_LEVEL" "Command return : [$SOAF_RET]."
	else
		local CMD_PROG_VAR=$(echo $CMD_PROG | tr '.-' '__')
		eval local NOEXEC_FN=\"\$${CMD_PROG_VAR}__NOEXEC_FN\"
		[ -n "$NOEXEC_FN" ] && $NOEXEC_FN "$CMD"
		SOAF_RET="0"
	fi
}

soaf_cmd_info() {
	local CMD="$1"
	soaf_cmd "$CMD" "$SOAF_LOG_INFO"
}

################################################################################
################################################################################

soaf_day_curr() {
	local DAY_CURR=$(date '+%j')
	echo $DAY_CURR
}

soaf_day_upd_file() {
	local DAY_CURR=$1
	local FILE="$2"
	local ROLL_NATURE="$3"
	[ -n "$ROLL_NATURE" ] && gentop_roll_nature "$ROLL_NATURE"
	echo $DAY_CURR > $FILE
}

soaf_day_since_last() {
	local DAY_CURR=$1
	local FILE="$2"
	[ -z "$DAY_CURR" ] && DAY_CURR=$(soaf_day_curr)
	local DAY_LAST=""
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
	local VAL="$1"
	local VAL_TO_UPPER=$(echo "$VAL" | tr 'a-z' 'A-Z')
	echo "$VAL_TO_UPPER"
}

################################################################################
################################################################################

soaf_mkdir() {
	local DIR="$1"
	if [ -n "$DIR" ]
	then
		[ ! -d "$DIR" ] && gentop_cmd_info "mkdir -p $DIR"
	fi
}
