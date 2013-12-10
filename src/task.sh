################################################################################
################################################################################

soaf_create_task() {
	local TASK=$1
	local CMD=$2
	local LOG_DIR=$3
	local ROLL_SIZE=$4
	SOAF_TASK_LIST="$SOAF_TASK_LIST $TASK"
	soaf_map_extend $TASK "TASK_CMD" "$CMD"
	soaf_map_extend $TASK "TASK_LOG_DIR" $LOG_DIR
	soaf_map_extend $TASK "TASK_ROLL_SIZE" $ROLL_SIZE
}

################################################################################
################################################################################

soaf_task() {
	soaf_do_task $SOAF_TASK
	if [ -z "$SOAF_TASK_RET" ]
	then
		cat << _EOF_
${SOAF_TXT_PRE}Unable to process task : '$SOAF_TASK'.
${SOAF_TXT_PRE}  See log file : '$SOAF_LOG_FILE'.
_EOF_
	fi
}

soaf_task_usage() {
	soaf_dis_txt "TASK: [$(echo $SOAF_TASK_LIST | tr ' ' '|')]"
}

soaf_task_init() {
	if [ -n "$SOAF_TASK_LIST" ]
	then
		soaf_create_action "task" soaf_task soaf_task_usage
		soaf_usage_add_var TASK
	fi
}

################################################################################
################################################################################

soaf_do_task_roll() {
	local FILE=$1
	local SIZE=$2
	soaf_create_roll_nature "task" "$FILE" $SIZE
	soaf_roll_nature "task"
}

################################################################################
################################################################################

soaf_do_task_process() {
	local TASK=$1
	local TASK_UPPER=$2
	local LOG_TASK_DIR=$3
	local LOG_TASK_FILE=$LOG_TASK_DIR/$TASK.log
	local LOG_TASK_ERR_FILE=$LOG_TASK_DIR/$TASK-err.log
	local ROLL_SIZE=$(soaf_map_get $TASK "TASK_ROLL_SIZE")
	soaf_do_task_roll $LOG_TASK_FILE $ROLL_SIZE
	soaf_do_task_roll $LOG_TASK_ERR_FILE $ROLL_SIZE
	local CMD=$(soaf_map_get $TASK "TASK_CMD")
	if [ -z "$CMD" ]
	then
		soaf_log_err "No command for task : '$TASK' ???"
	else
		CMD="$CMD > $LOG_TASK_FILE 2> $LOG_TASK_ERR_FILE"
		soaf_log_info "Start $TASK_UPPER ..."
		soaf_cmd_info "$CMD"
		if [ "$SOAF_RET" = "0" ]
		then
			SOAF_TASK_RET="OK"
			soaf_log_info "$TASK_UPPER OK."
		else
			soaf_log_err "$TASK_UPPER KO."
		fi
	fi
}

################################################################################
################################################################################

soaf_do_task_valid() {
	local TASK=$1
	local TASK_UPPER=$(soaf_to_upper $TASK)
	local TASK_LOG_DIR=$(soaf_map_get $TASK "TASK_LOG_DIR")
	soaf_mkdir $TASK_LOG_DIR
	local TASK_INPROG_FILE=$TASK_LOG_DIR/inprog.$TASK
	if [ ! -f $TASK_INPROG_FILE ]
	then
		touch $TASK_INPROG_FILE
		soaf_do_task_process $TASK $TASK_UPPER $TASK_LOG_DIR
		rm -f $TASK_INPROG_FILE
	else
		local MSG="$TASK_UPPER already in progress"
		MSG="$MSG (file : [$TASK_INPROG_FILE]) ..."
		soaf_log_warn "$MSG"
	fi
}

################################################################################
################################################################################

soaf_do_task() {
	local TASK=$1
	SOAF_TASK_RET=""
	local TASK_VALID=$(echo $SOAF_TASK_LIST | grep -w $TASK)
	if [ -n "$TASK_VALID" ]
	then
		soaf_do_task_valid $TASK
	else
		soaf_log_err "Unknown task : '$TASK'."
	fi
}

################################################################################
################################################################################

soaf_do_task_list() {
	local TASK_LIST="$1"
	SOAF_TASK_RET="OK"
	for task in $TASK_LIST
	do
		[ -n "$SOAF_TASK_RET" ] && soaf_do_task $task
	done
}
