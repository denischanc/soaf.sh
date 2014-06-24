################################################################################
################################################################################

SOAF_JOB_ROLL_NATURE="soaf_job"

SOAF_JOB_LOG_NAME="job"

################################################################################
################################################################################

soaf_create_job() {
	local JOB=$1
	local CMD=$2
	local LOG_DIR=$3
	local ROLL_SIZE=$4
	SOAF_JOB_LIST="$SOAF_JOB_LIST $JOB"
	soaf_map_extend $JOB "JOB_CMD" "$CMD"
	soaf_map_extend $JOB "JOB_LOG_DIR" $LOG_DIR
	soaf_map_extend $JOB "JOB_ROLL_SIZE" $ROLL_SIZE
}

################################################################################
################################################################################

soaf_job() {
	soaf_do_job $SOAF_JOB
	if [ -z "$SOAF_JOB_RET" ]
	then
		soaf_dis_txt "Unable to process job : [$SOAF_JOB]."
		soaf_dis_txt "  See log file : [$SOAF_LOG_FILE]."
	fi
}

soaf_job_usage() {
	soaf_dis_txt "JOB: [$(echo $SOAF_JOB_LIST | tr ' ' '|')]"
}

soaf_job_init() {
	if [ -n "$SOAF_JOB_LIST" ]
	then
		soaf_create_action "job" soaf_job soaf_job_usage
		soaf_usage_add_var JOB
	fi
}

################################################################################
################################################################################

soaf_do_job_roll() {
	local FILE=$1
	local SIZE=$2
	soaf_create_roll_nature $SOAF_JOB_ROLL_NATURE $FILE $SIZE
	soaf_roll_nature $SOAF_JOB_ROLL_NATURE
}

################################################################################
################################################################################

soaf_do_job_process() {
	local JOB=$1
	local JOB_UPPER=$2
	local LOG_JOB_DIR=$3
	local LOG_JOB_FILE=$LOG_JOB_DIR/$JOB.log
	local LOG_JOB_ERR_FILE=$LOG_JOB_DIR/$JOB-err.log
	local ROLL_SIZE=$(soaf_map_get $JOB "JOB_ROLL_SIZE")
	soaf_do_job_roll $LOG_JOB_FILE $ROLL_SIZE
	soaf_do_job_roll $LOG_JOB_ERR_FILE $ROLL_SIZE
	local CMD=$(soaf_map_get $JOB "JOB_CMD")
	if [ -z "$CMD" ]
	then
		soaf_log_err "No command for job : [$JOB] ???" $SOAF_JOB_LOG_NAME
	else
		CMD="$CMD > $LOG_JOB_FILE 2> $LOG_JOB_ERR_FILE"
		soaf_log_info "Start $JOB_UPPER ..." $SOAF_JOB_LOG_NAME
		soaf_cmd_info "$CMD" $SOAF_JOB_LOG_NAME
		if [ "$SOAF_RET" = "0" ]
		then
			SOAF_JOB_RET="OK"
			soaf_log_info "$JOB_UPPER OK." $SOAF_JOB_LOG_NAME
		else
			soaf_log_err "$JOB_UPPER KO." $SOAF_JOB_LOG_NAME
		fi
	fi
}

################################################################################
################################################################################

soaf_do_job_valid() {
	local JOB=$1
	local JOB_UPPER=$(soaf_to_upper $JOB)
	local JOB_LOG_DIR=$(soaf_map_get $JOB "JOB_LOG_DIR")
	soaf_mkdir $JOB_LOG_DIR "" $SOAF_JOB_LOG_NAME
	local JOB_INPROG_FILE=$JOB_LOG_DIR/$JOB.inprog
	if [ ! -f $JOB_INPROG_FILE ]
	then
		touch $JOB_INPROG_FILE
		soaf_do_job_process $JOB $JOB_UPPER $JOB_LOG_DIR
		rm -f $JOB_INPROG_FILE
	else
		local MSG="$JOB_UPPER already in progress"
		MSG="$MSG (file : [$JOB_INPROG_FILE]) ..."
		soaf_log_warn "$MSG" $SOAF_JOB_LOG_NAME
	fi
}

################################################################################
################################################################################

soaf_do_job() {
	local JOB=$1
	SOAF_JOB_RET=
	local JOB_VALID=$(echo $SOAF_JOB_LIST | grep -w "$JOB")
	if [ -n "$JOB_VALID" ]
	then
		soaf_do_job_valid $JOB
	else
		soaf_log_err "Unknown job : [$JOB]." $SOAF_JOB_LOG_NAME
	fi
}

################################################################################
################################################################################

soaf_do_job_list() {
	local JOB_LIST="$1"
	SOAF_JOB_RET="OK"
	for job in $JOB_LIST
	do
		[ -n "$SOAF_JOB_RET" ] && soaf_do_job $job
	done
}
