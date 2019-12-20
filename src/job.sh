################################################################################
################################################################################

SOAF_JOB_ROLL_NATURE="soaf.job.roll"

SOAF_JOB_LOG_NAME="soaf.job"

SOAF_JOB_CMD_ATTR="soaf_job_cmd"
SOAF_JOB_LOG_DIR_ATTR="soaf_job_log_dir"
SOAF_JOB_ROLL_SIZE_ATTR="soaf_job_roll_size"
SOAF_JOB_NOTIF_ON_ERR_ATTR="soaf_job_notif_on_err"

SOAF_JOB_ACTION="job"

################################################################################
################################################################################

soaf_job_init() {
	if [ -n "$SOAF_JOB_LIST" -a -z "$SOAF_JOB_NO_ACTION" ]
	then
		soaf_usage_add_var JOB $SOAF_DEFINE_VAR_PREFIX $SOAF_POS_POST
		soaf_usage_def_var JOB "" "$SOAF_JOB_LIST" "" "" \
			"$SOAF_JOB_ACTION" "OK"
		soaf_create_action $SOAF_JOB_ACTION soaf_job "" $SOAF_POS_POST
	fi
}

soaf_create_module soaf.extra.job $SOAF_VERSION "" soaf_job_init

################################################################################
################################################################################

soaf_job_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_JOB_LOG_NAME $LOG_LEVEL
}

soaf_define_add_name_log_level_fn soaf_job_log_level

################################################################################
################################################################################

soaf_create_job() {
	local JOB=$1
	local CMD=$2
	local LOG_DIR=$3
	local ROLL_SIZE=$4
	local NOTIF_ON_ERR=$5
	SOAF_JOB_LIST="$SOAF_JOB_LIST $JOB"
	soaf_map_extend $JOB $SOAF_JOB_CMD_ATTR "$CMD"
	soaf_map_extend $JOB $SOAF_JOB_LOG_DIR_ATTR $LOG_DIR
	soaf_map_extend $JOB $SOAF_JOB_ROLL_SIZE_ATTR $ROLL_SIZE
	soaf_map_extend $JOB $SOAF_JOB_NOTIF_ON_ERR_ATTR $NOTIF_ON_ERR
}

################################################################################
################################################################################

soaf_job() {
	soaf_do_job $SOAF_JOB
	if [ -z "$SOAF_JOB_RET" ]
	then
		soaf_log_err "Unable to process job : [$SOAF_JOB]." $SOAF_JOB_LOG_NAME
	fi
}

################################################################################
################################################################################

soaf_do_job_roll() {
	local FILE=$1
	local SIZE=$2
	soaf_create_roll_nature $SOAF_JOB_ROLL_NATURE $SIZE
	soaf_roll_nature $SOAF_JOB_ROLL_NATURE $FILE
}

################################################################################
################################################################################

soaf_do_job_process() {
	local JOB=$1
	local JOB_UPPER=$2
	local LOG_DIR=$3
	local LOG_FILE=$LOG_DIR/$JOB.log
	local LOG_ERR_FILE=$LOG_DIR/$JOB-err.log
	local ROLL_SIZE
	soaf_map_get_var ROLL_SIZE $JOB $SOAF_JOB_ROLL_SIZE_ATTR
	soaf_do_job_roll $LOG_FILE $ROLL_SIZE
	soaf_do_job_roll $LOG_ERR_FILE $ROLL_SIZE
	local CMD
	soaf_map_get_var CMD $JOB $SOAF_JOB_CMD_ATTR
	if [ -z "$CMD" ]
	then
		soaf_log_err "No command for job : [$JOB] ???" $SOAF_JOB_LOG_NAME
	else
		CMD="$CMD > $LOG_FILE 2> $LOG_ERR_FILE"
		soaf_log_info "Start $JOB_UPPER ..." $SOAF_JOB_LOG_NAME
		soaf_cmd_info "$CMD" $SOAF_JOB_LOG_NAME "OK"
		if [ "$SOAF_RET" = "0" ]
		then
			SOAF_JOB_RET="OK"
			soaf_log_info "$JOB_UPPER OK." $SOAF_JOB_LOG_NAME
		else
			soaf_log_err "$JOB_UPPER KO." $SOAF_JOB_LOG_NAME
			local IS_NOTIF
			soaf_map_get_var IS_NOTIF $JOB $SOAF_JOB_NOTIF_ON_ERR_ATTR
			[ -n "$IS_NOTIF" ] && soaf_notif "$JOB_UPPER job KO."
		fi
	fi
}

################################################################################
################################################################################

soaf_do_job_valid() {
	local JOB=$1
	soaf_upper $JOB
	local JOB_UPPER=$SOAF_RET
	local LOG_DIR
	soaf_map_get_var LOG_DIR $JOB $SOAF_JOB_LOG_DIR_ATTR \
		$SOAF_LOG_DIR/$SOAF_APPLI_NAME.soaf.job.$JOB
	soaf_mkdir $LOG_DIR "" $SOAF_JOB_LOG_NAME
	local PID_FILE=$SOAF_RUN_DIR/$SOAF_APPLI_NAME.soaf.job.$JOB.pid
	local FN_ARGS="soaf_do_job_process $JOB $JOB_UPPER $LOG_DIR"
	local MSG="$JOB_UPPER already in progress (pid: [@[PID]]) ..."
	soaf_fn_args_check_pid "$FN_ARGS" $PID_FILE $SOAF_JOB_LOG_NAME "$MSG"
}

################################################################################
################################################################################

soaf_do_job() {
	local JOB=$1
	SOAF_JOB_RET=
	soaf_list_found "$SOAF_JOB_LIST" $JOB
	if [ -n "$SOAF_RET_LIST" ]
	then
		soaf_do_job_valid $JOB
	else
		soaf_log_err "Unknown job : [$JOB]." $SOAF_JOB_LOG_NAME
	fi
}

################################################################################
################################################################################

soaf_do_job_list() {
	local JOB_LIST=$1
	SOAF_JOB_RET="OK"
	for job in $JOB_LIST
	do
		[ -n "$SOAF_JOB_RET" ] && soaf_do_job $job
	done
}
