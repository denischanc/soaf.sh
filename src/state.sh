################################################################################
################################################################################

SOAF_STATE_LOG_NAME="state"

SOAF_STATE_CUR_PROP="state_cur"

################################################################################
################################################################################

soaf_state_log_level() {
	local LOG_LEVEL=$1
	soaf_map_extend $SOAF_STATE_LOG_NAME "LOG_LEVEL" $LOG_LEVEL
}

################################################################################
################################################################################

soaf_create_wait_state() {
	local STATE=$1
	local DST_WORK_STATE=$2
	local DST_WORK_STATE_FN=$3
	SOAF_WAIT_STATE_LIST="$SOAF_WAIT_STATE_LIST $STATE"
	soaf_map_extend $STATE "DST_WORK_STATE" $DST_WORK_STATE
	soaf_map_extend $STATE "DST_WORK_STATE_FN" $DST_WORK_STATE_FN
}

soaf_create_work_state() {
	local STATE=$1
	local FN=$2
	local JOB_LIST=$3
	local DST_WAIT_STATE=$4
	soaf_map_extend $STATE "STATE_FN" $FN
	soaf_map_extend $STATE "STATE_JOB_LIST" "$JOB_LIST"
	soaf_map_extend $STATE "DST_WAIT_STATE" $DST_WAIT_STATE
}

soaf_create_state_nature() {
	local NATURE=$1
	local WORK_DIR=$2
	local ENTRY_WAIT_STATE=$3
	SOAF_STATE_NATURE_LIST="$SOAF_STATE_NATURE_LIST $NATURE"
	soaf_map_extend $NATURE "STATE_WORK_DIR" $WORK_DIR
	soaf_map_extend $NATURE "ENTRY_WAIT_STATE" $ENTRY_WAIT_STATE
}

################################################################################
################################################################################

SOAF_STATE_STAY_CUR="stay_cur"

soaf_state_stay_cur() {
	soaf_log_debug "Do nothing, stay in current waiting state." \
		$SOAF_STATE_LOG_NAME
}

soaf_create_work_state $SOAF_STATE_STAY_CUR soaf_state_stay_cur

################################################################################
################################################################################

soaf_state_prop_nature() {
	local NATURE=$1
	echo "state_${NATURE}_prop"
}

soaf_state_prop_file() {
	local PROP_NATURE=$1
	local WORK_DIR=$2
	echo "$WORK_DIR/$PROP_NATURE.prop"
}

soaf_state_create_prop_nature() {
	local PROP_NATURE=$1
	local WORK_DIR=$2
	local PROP_FILE=$(soaf_state_prop_file $PROP_NATURE $WORK_DIR)
	soaf_create_prop_file_nature $PROP_NATURE $PROP_FILE
}

################################################################################
################################################################################

soaf_state_get() {
	local NATURE=$1
	local PROP_NATURE=$2
	soaf_prop_file_get $PROP_NATURE $SOAF_STATE_CUR_PROP
	if [ -z "$SOAF_PROP_FILE_RET" ]
	then
		SOAF_STATE_RET=
	else
		SOAF_STATE__=$SOAF_PROP_FILE_VAL
		[ -z "$SOAF_STATE__" ] && \
			SOAF_STATE__=$(soaf_map_get $NATURE "ENTRY_WAIT_STATE")
}

soaf_state_set() {
	local PROP_NATURE=$1
	local STATE=$2
	soaf_prop_file_set $PROP_NATURE $SOAF_STATE_CUR_PROP $STATE
	if [ -z "$SOAF_PROP_FILE_RET" ]
	then
		SOAF_STATE_RET=
	else
		soaf_log_info "State is now : [$STATE]." $SOAF_STATE_LOG_NAME
	fi
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
	local WORK_STATE=$2
	local JOB_LIST=$(soaf_map_get $WORK_STATE "STATE_JOB_LIST")
	soaf_state_do_job_list "$JOB_LIST"
}

################################################################################
################################################################################

soaf_state_get_dst_work() {
	local NATURE=$1
	local WAIT_STATE=$2
	local WORK_DIR=$3
	local FN=$(soaf_map_get $WAIT_STATE "DST_WORK_STATE_FN")
	if [ -n "$FN" ]
	then
		SOAF_STATE_DST_WORK=
		$FN $NATURE $WAIT_STATE $WORK_DIR
	else
		SOAF_STATE_DST_WORK=$(soaf_map_get $WAIT_STATE "DST_WORK_STATE")
	fi
}

soaf_state_get_dst_wait() {
	local WORK_STATE=$1
	SOAF_STATE_DST_WAIT=$(soaf_map_get $WORK_STATE "DST_WAIT_STATE")
}

soaf_state_proc() {
	local NATURE=$1
	local PROP_NATURE=$2
	local WAIT_STATE=$3
	local WORK_DIR=$4
	soaf_state_get_dst_work $NATURE $WAIT_STATE $WORK_DIR
	local WORK_STATE=$SOAF_STATE_DST_WORK
	if [ -z "$WORK_STATE" ]
	then
		local MSG="No dst work state from : [$WAIT_STATE]."
		soaf_log_err "$MSG" $SOAF_STATE_LOG_NAME
		SOAF_STATE_RET=
	else
		soaf_state_set $PROP_NATURE $WORK_STATE
		if [ -n "$SOAF_STATE_RET" ]
		then
			local FN=$(soaf_map_get $WORK_STATE "STATE_FN")
			[ -z "$FN" ] && FN=soaf_state_dft_work
			SOAF_STATE_PROC_RET=
			$FN $NATURE $WORK_STATE $WORK_DIR
			local WAIT_STATE_NEXT=$WAIT_STATE
			if [ -n "$SOAF_STATE_PROC_RET" ]
			then
				soaf_state_get_dst_wait $WORK_STATE
				WAIT_STATE_NEXT=$SOAF_STATE_DST_WAIT
			fi
			soaf_state_set $PROP_NATURE $WAIT_STATE_NEXT
		fi
	fi
}

################################################################################
################################################################################

soaf_state_active() {
	local NATURE=$1
	local WORK_DIR=$2
	local INACTIVE_FILE=$WORK_DIR/$NATURE.inactive
	SOAF_STATE_ACTIVE="OK"
	[ -f $INACTIVE_FILE ] && SOAF_STATE_ACTIVE=
}

soaf_state_proc_nature() {
	local NATURE=$1
	local WORK_DIR=$(soaf_map_get $NATURE "STATE_WORK_DIR" .)
	soaf_state_active $NATURE $WORK_DIR
	if [ -z "$SOAF_STATE_ACTIVE" ]
	then
		local MSG="State nature not active : [$NATURE]."
		soaf_log_debug "$MSG" $SOAF_STATE_LOG_NAME
	else
		local PROP_NATURE=$(soaf_state_prop_nature $NATURE)
		soaf_state_create_prop_nature $PROP_NATURE $WORK_DIR
		soaf_state_get $NATURE $PROP_NATURE
		if [ -n "$SOAF_STATE_RET" ]
		then
			local WAIT=$(echo $SOAF_WAIT_STATE_LIST | grep -w "$SOAF_STATE__")
			if [ -n "$WAIT" ]
			then
				soaf_mkdir $WORK_DIR "" $SOAF_STATE_LOG_NAME
				soaf_state_proc $NATURE $PROP_NATURE $SOAF_STATE__ $WORK_DIR
			else
				local MSG="State nature [$NATURE] in work state :"
				soaf_log_debug "$MSG [$SOAF_STATE__]." $SOAF_STATE_LOG_NAME
			fi
		fi
	fi
}

################################################################################
################################################################################

soaf_state_engine() {
	local NATURE=$1
	local NATURE_KNOWN=$(echo $SOAF_STATE_NATURE_LIST | grep -w "$NATURE")
	if [ -n "$NATURE_KNOWN" ]
	then
		SOAF_STATE_RET="OK"
		soaf_state_proc_nature $NATURE
	else
		SOAF_STATE_RET=
		soaf_log_err "Unknown state nature : [$NATURE]." $SOAF_STATE_LOG_NAME
	fi
}
