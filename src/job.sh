################################################################################
################################################################################

readonly SOAF_JOB_ROLL_NATURE="soaf.job.roll"

readonly SOAF_JOB_LOG_NAME="soaf.job"

readonly SOAF_JOB_CMD_ATTR="soaf_job_cmd"
readonly SOAF_JOB_LOG_DIR_ATTR="soaf_job_log_dir"
readonly SOAF_JOB_ROLL_SIZE_ATTR="soaf_job_roll_size"
readonly SOAF_JOB_NOTIF_ON_ERR_ATTR="soaf_job_notif_on_err"
readonly SOAF_JOB_ERR_ON_PID_WO_PROC_ATTR="soaf_job_err_on_pid_wo_proc"

readonly SOAF_JOB_ACTION="job"

################################################################################
################################################################################

soaf_job_static_() {
	soaf_log_add_log_level_fn soaf_job_log_level
}

soaf_job_init_() {
	if [ -n "$SOAF_JOB_LIST" -a -z "$SOAF_JOB_NO_ACTION" ]
	then
		soaf_create_var_usage_exp JOB "" "$SOAF_JOB_LIST" "" "" \
			"$SOAF_JOB_ACTION" "OK" $SOAF_DEFINE_VAR_PREFIX $SOAF_POS_POST
		soaf_create_action $SOAF_JOB_ACTION soaf_job_ "" $SOAF_POS_POST
	fi
}

soaf_create_module soaf.extra.job $SOAF_VERSION soaf_job_static_ \
	"" soaf_job_init_

################################################################################
################################################################################

soaf_job_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_JOB_LOG_NAME $LOG_LEVEL
}

################################################################################
################################################################################

soaf_create_job() {
	local JOB=$1
	local CMD=$2
	local LOG_DIR=$3
	local ROLL_SIZE=$4
	local NOTIF_ON_ERR=$5
	local ERR_ON_PID_WO_PROC=$6
	SOAF_JOB_LIST+=" $JOB"
	soaf_map_extend $JOB $SOAF_JOB_CMD_ATTR "$CMD"
	soaf_map_extend $JOB $SOAF_JOB_LOG_DIR_ATTR $LOG_DIR
	soaf_map_extend $JOB $SOAF_JOB_ROLL_SIZE_ATTR $ROLL_SIZE
	soaf_map_extend $JOB $SOAF_JOB_NOTIF_ON_ERR_ATTR $NOTIF_ON_ERR
	soaf_map_extend $JOB $SOAF_JOB_ERR_ON_PID_WO_PROC_ATTR $ERR_ON_PID_WO_PROC
}

################################################################################
################################################################################

soaf_job_() {
	soaf_do_job $SOAF_JOB
	if [ -z "$SOAF_JOB_RET" ]
	then
		soaf_log_err "Unable to process job : [$SOAF_JOB]." $SOAF_JOB_LOG_NAME
	fi
}

################################################################################
################################################################################

soaf_do_job_roll_() {
	local FILE=$1
	local SIZE=$2
	soaf_create_roll_nature $SOAF_JOB_ROLL_NATURE $SIZE
	soaf_roll_nature $SOAF_JOB_ROLL_NATURE $FILE
}

################################################################################
################################################################################

soaf_do_job_process_() {
	local JOB=$1
	local JOB_UPPER=$2
	local LOG_DIR=$3
	local RET=
	soaf_map_get $JOB $SOAF_JOB_CMD_ATTR
	local CMD=$SOAF_RET
	if [ -z "$CMD" ]
	then
		soaf_log_err "No command for job : [$JOB] ???" $SOAF_JOB_LOG_NAME
	else
		local LOG_FILE=$LOG_DIR/$JOB.log
		local LOG_ERR_FILE=$LOG_DIR/$JOB-err.log
		soaf_map_get $JOB $SOAF_JOB_ROLL_SIZE_ATTR
		local ROLL_SIZE=$SOAF_RET
		soaf_do_job_roll_ $LOG_FILE $ROLL_SIZE
		soaf_do_job_roll_ $LOG_ERR_FILE $ROLL_SIZE
		soaf_log_info "Start $JOB_UPPER ..." $SOAF_JOB_LOG_NAME
		local IN_PROG_FILE=$LOG_DIR/$JOB.inprog
		touch $IN_PROG_FILE 2> /dev/null
		CMD+=" > $LOG_FILE 2> $LOG_ERR_FILE"
		soaf_cmd_info "$CMD" $SOAF_JOB_LOG_NAME "OK"
		RET=$SOAF_RET
		soaf_rm $IN_PROG_FILE "" $SOAF_JOB_LOG_NAME
		if [ $RET -eq 0 ]
		then
			soaf_log_info "$JOB_UPPER OK." $SOAF_JOB_LOG_NAME
			RET="OK"
		else
			soaf_log_err "$JOB_UPPER KO." $SOAF_JOB_LOG_NAME
			soaf_map_get $JOB $SOAF_JOB_NOTIF_ON_ERR_ATTR
			[ -n "$SOAF_RET" ] && soaf_notif "$JOB_UPPER job KO."
			RET=
		fi
	fi
	SOAF_JOB_RET=$RET
}

################################################################################
################################################################################

soaf_do_job_valid_() {
	local JOB=$1
	declare -u JOB_UPPER=$JOB
	soaf_map_get $JOB $SOAF_JOB_LOG_DIR_ATTR \
		$SOAF_LOG_DIR/$SOAF_APPLI_NAME.soaf.job.$JOB
	local LOG_DIR=$SOAF_RET
	soaf_mkdir $LOG_DIR "" $SOAF_JOB_LOG_NAME
	local PID_FILE=$SOAF_RUN_DIR/$SOAF_APPLI_NAME.soaf.job.$JOB.pid
	local FN_ARGS="soaf_do_job_process_ $JOB $JOB_UPPER $LOG_DIR"
	soaf_map_get $JOB $SOAF_JOB_ERR_ON_PID_WO_PROC_ATTR
	soaf_fn_args_check_pid "$FN_ARGS" $PID_FILE $SOAF_JOB_LOG_NAME $SOAF_RET
	if [ "$SOAF_RET" != "$SOAF_OK_RET" ]
	then
		if [ "$SOAF_RET" = "$SOAF_IN_PROG_RET" ]
		then
			local MSG="$JOB_UPPER already in progress (file : [$PID_FILE])."
			soaf_log_err "$MSG" $SOAF_JOB_LOG_NAME
		fi
		SOAF_JOB_RET=
	fi
}

################################################################################
################################################################################

soaf_do_job() {
	local JOB=$1
	soaf_list_found "$SOAF_JOB_LIST" $JOB
	if [ -n "$SOAF_RET_LIST" ]
	then
		soaf_do_job_valid_ $JOB
	else
		soaf_log_err "Unknown job : [$JOB]." $SOAF_JOB_LOG_NAME
		SOAF_JOB_RET=
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
