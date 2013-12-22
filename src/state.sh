################################################################################
################################################################################

soaf_create_wait_state() {
	local STATE=$1
	local NEXT_STATE=$2
	local NEXT_STATE_FN=$3
	SOAF_WAIT_STATE_LIST="$SOAF_WAIT_STATE_LIST $STATE"
	soaf_map_extend $STATE "NEXT_STATE" $NEXT_STATE
	soaf_map_extend $STATE "NEXT_STATE_FN" $NEXT_STATE_FN
}

soaf_create_work_state() {
	local STATE=$1
	local FN=$2
	local JOB_LIST=$3
	local WAIT_STATE=$4
	soaf_map_extend $STATE "STATE_FN" $FN
	soaf_map_extend $STATE "STATE_JOB_LIST" "$JOB_LIST"
	soaf_map_extend $STATE "WAIT_STATE" $WAIT_STATE
}

soaf_create_state_nature() {
	local NATURE=$1
	local WORK_DIR=$2
	local ENTRY_STATE=$3
	SOAF_STATE_NATURE_LIST="$SOAF_STATE_NATURE_LIST $NATURE"
	soaf_map_extend $NATURE "STATE_WORK_DIR" $WORK_DIR
	soaf_map_extend $NATURE "ENTRY_STATE" $ENTRY_STATE
}

################################################################################
################################################################################

SOAF_STATE_STAY_CUR="stay_cur"

soaf_create_work_state $SOAF_STATE_STAY_CUR soaf_state_stay_cur

################################################################################
################################################################################

soaf_state_file() {
	local NATURE=$1
	local WORK_DIR=$2
	echo "$WORK_DIR/$NATURE.state"
}

soaf_state_get() {
	local NATURE=$1
	local WORK_DIR=$2
	local FILE=$(soaf_state_file $NATURE $WORK_DIR)
	local STATE=$(cat $FILE 2> /dev/null | head -1)
	if [ -z "$STATE" ]
	then
		STATE=$(soaf_map_get $NATURE "ENTRY_STATE")
	fi
	echo "$STATE"
}

soaf_state_set() {
	local STATE=$1
	local NATURE=$2
	local WORK_DIR=$3
	soaf_log_info "State is now : [$STATE]."
	local FILE=$(soaf_state_file $NATURE $WORK_DIR)
	echo "$STATE" > $FILE
}

################################################################################
################################################################################

soaf_state_stay_cur() {
	soaf_log_debug "Do nothing, stay in current waiting state."
}

################################################################################
################################################################################

soaf_state_do_job_list() {
	local JOB_LIST=$1
	soaf_do_job_list "$JOB_LIST"
	if [ -n "$SOAF_JOB_RET" ]
	then
		SOAF_STATE_PROC_RET="OK"
	fi
}

soaf_state_dft_work() {
	local STATE=$1
	local JOB_LIST=$(soaf_map_get $STATE "STATE_JOB_LIST")
	soaf_state_do_job_list "$JOB_LIST"
}

################################################################################
################################################################################

soaf_state_get_next() {
	local STATE=$1
	local NATURE=$2
	local WORK_DIR=$3
	local NEXT_STATE=""
	local FN=$(soaf_map_get $STATE "NEXT_STATE_FN")
	if [ -n "$FN" ]
	then
		NEXT_STATE=$($FN $STATE $NATURE $WORK_DIR)
	else
		NEXT_STATE=$(soaf_map_get $STATE "NEXT_STATE")
	fi
	echo "$NEXT_STATE"
}

soaf_state_get_wait() {
	local STATE=$1
	local WAIT_STATE=$(soaf_map_get $STATE "WAIT_STATE")
	echo "$WAIT_STATE"
}

soaf_state_process() {
	local STATE=$1
	local NATURE=$2
	local WORK_DIR=$3
	local NEXT_STATE=$(soaf_state_get_next $STATE $NATURE $WORK_DIR)
	soaf_state_set "$NEXT_STATE" $NATURE $WORK_DIR
	local FN=$(soaf_map_get $NEXT_STATE "STATE_FN")
	[ -z "$FN" ] && FN=soaf_state_dft_work
	SOAF_STATE_PROC_RET=""
	$FN "$NEXT_STATE" $NATURE $WORK_DIR
	local WAIT_STATE=$STATE
	if [ -n "$SOAF_STATE_PROC_RET" ]
	then
		WAIT_STATE=$(soaf_state_get_wait $NEXT_STATE)
	fi
	soaf_state_set "$WAIT_STATE" $NATURE $WORK_DIR
}

################################################################################
################################################################################

soaf_state_active() {
	local NATURE=$1
	local WORK_DIR=$2
	local STATE_INACTIVE_FILE=$WORK_DIR/$NATURE.inactive
	[ ! -f $STATE_INACTIVE_FILE ] && echo "OK"
}

soaf_state_engine_valid() {
	local NATURE=$1
	local WORK_DIR=$(soaf_map_get $NATURE "STATE_WORK_DIR" .)
	local ACTIVE=$(soaf_state_active $NATURE $WORK_DIR)
	local STATE=$(soaf_state_get $NATURE $WORK_DIR)
	local WAIT=$(echo $SOAF_WAIT_STATE_LIST | grep -w "$STATE")
	if [ -n "$ACTIVE" -a -n "$WAIT" ]
	then
		soaf_state_process $STATE $NATURE $WORK_DIR
	else
		local MSG="State nature [$NATURE] :"
		MSG="$MSG not active or in work state [$STATE]."
		soaf_log_debug "$MSG"
	fi
}

soaf_state_engine() {
	local NATURE=$1
	local NATURE_VALID=$(echo $SOAF_STATE_NATURE_LIST | grep -w "$NATURE")
	if [ -n "$NATURE_VALID" ]
	then
		soaf_state_engine_valid $NATURE
	else
		soaf_log_err "Unknown state nature : [$NATURE]."
	fi
}
