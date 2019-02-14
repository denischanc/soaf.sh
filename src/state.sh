################################################################################
################################################################################

SOAF_STATE_LOG_NAME="soaf.state"

SOAF_STATE_CUR_PROP="soaf.state.cur"
SOAF_STATE_PREV_PROP="soaf.state.prev"
SOAF_STATE_STEP_PROP="soaf.state.step"

SOAF_STATE_STEP_WAITING="waiting"
SOAF_STATE_STEP_WORKING="working"
SOAF_STATE_STEP_SAVING="saving"
SOAF_STATE_STEP_JUMPING="jumping"
SOAF_STATE_STEP_INERR="in_error"

SOAF_STATE_WORKING_FN_ATTR="soaf_state_working_fn"
SOAF_STATE_WORKING_JOB_LIST_ATTR="soaf_state_working_job_list"
SOAF_STATE_NEXT_FN_ATTR="soaf_state_next_fn"
SOAF_STATE_NEXT_ATTR="soaf_state_next"
SOAF_STATE_AUTO_REWORK_ATTR="soaf_state_auto_rework"
SOAF_STATE_NOTIF_ON_ERR_ATTR="soaf_state_notif_on_err"

SOAF_STATE_ENTRY_ATTR="soaf_state_entry"
SOAF_STATE_WORK_DIR_ATTR="soaf_state_work_dir"
SOAF_STATE_PROP_FILE_ATTR="soaf_state_prop_file"

SOAF_STATE_INACTIVE_FILE_ACTION="state_inactive_file"

################################################################################
################################################################################

soaf_state_init() {
	if [ -n "$SOAF_STATE_NATURE_LIST" ]
	then
		soaf_create_action $SOAF_STATE_INACTIVE_FILE_ACTION \
			soaf_state_display_all_inactive_file \
			soaf_state_display_all_inactive_file_usage $SOAF_POS_POST
	fi
}

soaf_define_add_this_init_fn soaf_state_init

################################################################################
################################################################################

soaf_state_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_STATE_LOG_NAME $LOG_LEVEL
}

soaf_define_add_name_log_level_fn soaf_state_log_level

################################################################################
################################################################################

soaf_create_state() {
	local STATE=$1
	local WORKING_FN=$2
	local WORKING_JOB_LIST=$3
	local NEXT_STATE_FN=$4
	local NEXT_STATE=$5
	local AUTO_REWORK=$6
	local NOTIF_ON_ERR=$7
	SOAF_STATE_LIST="$SOAF_STATE_LIST $STATE"
	soaf_map_extend $STATE $SOAF_STATE_WORKING_FN_ATTR $WORKING_FN
	soaf_map_extend $STATE $SOAF_STATE_WORKING_JOB_LIST_ATTR \
		"$WORKING_JOB_LIST"
	soaf_map_extend $STATE $SOAF_STATE_NEXT_FN_ATTR $NEXT_STATE_FN
	soaf_map_extend $STATE $SOAF_STATE_NEXT_ATTR $NEXT_STATE
	soaf_map_extend $STATE $SOAF_STATE_AUTO_REWORK_ATTR $AUTO_REWORK
	soaf_map_extend $STATE $SOAF_STATE_NOTIF_ON_ERR_ATTR $NOTIF_ON_ERR
}

soaf_create_state_nature() {
	local NATURE=$1
	local ENTRY_STATE=$2
	local WORK_DIR=$3
	local PROP_FILE=$4
	SOAF_STATE_NATURE_LIST="$SOAF_STATE_NATURE_LIST $NATURE"
	soaf_map_extend $NATURE $SOAF_STATE_ENTRY_ATTR $ENTRY_STATE
	soaf_map_extend $NATURE $SOAF_STATE_WORK_DIR_ATTR $WORK_DIR
	soaf_map_extend $NATURE $SOAF_STATE_PROP_FILE_ATTR $PROP_FILE
}

################################################################################
################################################################################

soaf_state_no_work() {
	soaf_log_debug "No work." $SOAF_STATE_LOG_NAME
	SOAF_STATE_WORKING_RET="OK"
}

################################################################################
################################################################################

soaf_state_err() {
	local MSG=$1
	[ -n "$MSG" ] && soaf_log_err "$MSG" $SOAF_STATE_LOG_NAME
	SOAF_STATE_RET=
}

################################################################################
################################################################################

soaf_state_prop_nature() {
	local NATURE=$1
	SOAF_STATE_RET=$NATURE.soaf.state.prop
}

################################################################################
################################################################################

soaf_state_inactive_file() {
	local NATURE=$1
	local WORK_DIR
	soaf_map_get_var WORK_DIR $NATURE $SOAF_STATE_WORK_DIR_ATTR $SOAF_WORK_DIR
	SOAF_STATE_RET=$WORK_DIR/$SOAF_APPLI_NAME.soaf.state.inactive.$NATURE
}

soaf_state_rework_file() {
	local NATURE=$1
	local WORK_DIR
	soaf_map_get_var WORK_DIR $NATURE $SOAF_STATE_WORK_DIR_ATTR $SOAF_WORK_DIR
	SOAF_STATE_RET=$WORK_DIR/$SOAF_APPLI_NAME.soaf.state.rework.$NATURE
}

soaf_state_pid_file() {
	local NATURE=$1
	local CUR_STATE=$2
	SOAF_STATE_RET=$SOAF_RUN_DIR/$SOAF_APPLI_NAME.soaf.state
	SOAF_STATE_RET=$SOAF_STATE_RET.$NATURE.$CUR_STATE.pid
}

################################################################################
################################################################################

soaf_state_display_all_inactive_file() {
	soaf_dis_title "State inactive files"
	local nature
	for nature in $SOAF_STATE_NATURE_LIST
	do
		soaf_state_inactive_file $nature
		soaf_dis_txt "Nature [$nature] ==> File [$SOAF_STATE_RET]"
	done
}

soaf_state_display_all_inactive_file_usage() {
	soaf_dis_txt "Display inactive file for all state natures."
}

################################################################################
################################################################################

soaf_state_do_job_list() {
	local JOB_LIST=$1
	soaf_do_job_list "$JOB_LIST"
	[ -n "$SOAF_JOB_RET" ] && SOAF_STATE_WORKING_RET="OK"
}

soaf_state_dft_work() {
	local CUR_STATE=$3
	local JOB_LIST
	soaf_map_get_var JOB_LIST $CUR_STATE $SOAF_STATE_WORKING_JOB_LIST_ATTR
	soaf_state_do_job_list "$JOB_LIST"
}

################################################################################
################################################################################

soaf_state_advance_step_fn() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	local CUR_STATE=$4
	local STEP=$5
	local FN=$6
	soaf_prop_file_set $PROP_NATURE $SOAF_STATE_STEP_PROP $STEP
	if [ -z "$SOAF_PROP_FILE_RET" ]
	then
		soaf_state_err
	else
		[ -n "$FN" ] && $FN $NATURE $WORK_DIR $PROP_NATURE $CUR_STATE
	fi
}

soaf_state_advance_step() {
	local PROP_NATURE=$1
	local STEP=$2
	soaf_state_advance_step_fn "" "" $PROP_NATURE "" $STEP
}

################################################################################
################################################################################

soaf_state_known() {
	local STATE=$1
	soaf_list_found "$SOAF_STATE_LIST" $STATE
	[ -z "$SOAF_RET_LIST" ] && soaf_state_err "Unknown state : [$STATE]."
}

soaf_state_init_step() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	local ENTRY_STATE
	soaf_map_get_var ENTRY_STATE $NATURE $SOAF_STATE_ENTRY_ATTR
	if [ -z "$ENTRY_STATE" ]
	then
		soaf_state_err "No entry state for nature : [$NATURE]."
	else
		soaf_state_known $ENTRY_STATE
		if [ -n "$SOAF_STATE_RET" ]
		then
			soaf_prop_file_set $PROP_NATURE $SOAF_STATE_CUR_PROP $ENTRY_STATE
			if [ -z "$SOAF_PROP_FILE_RET" ]
			then
				soaf_state_err
			else
				local MSG="State of nature [$NATURE] is now : [$ENTRY_STATE]."
				soaf_log_info "$MSG" $SOAF_STATE_LOG_NAME
				soaf_state_advance_step_fn $NATURE $WORK_DIR $PROP_NATURE \
					$ENTRY_STATE $SOAF_STATE_STEP_WAITING \
					soaf_state_waiting_step_main
			fi
		fi
	fi
}

################################################################################
################################################################################

soaf_state_get_prop_n_call_fn() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	local PROP=$4
	local FN=$5
	soaf_prop_file_get $PROP_NATURE $PROP
	if [ -z "$SOAF_PROP_FILE_RET" ]
	then
		soaf_state_err
	else
		local STATE=$SOAF_PROP_FILE_VAL
		if [ -z "$STATE" ]
		then
			local MSG="Empty state of nature [$NATURE] for property :"
			soaf_state_err "$MSG [$PROP]."
		else
			soaf_state_known $STATE
			[ -n "$SOAF_STATE_RET" ] && \
				$FN $NATURE $WORK_DIR $PROP_NATURE $STATE
		fi
	fi
}

################################################################################
################################################################################

soaf_state_waiting_step_main() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	local CUR_STATE=$4
	soaf_state_advance_step_fn $NATURE $WORK_DIR $PROP_NATURE $CUR_STATE \
		$SOAF_STATE_STEP_WORKING soaf_state_working_step_main
}

soaf_state_waiting_step() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	soaf_state_get_prop_n_call_fn $NATURE $WORK_DIR $PROP_NATURE \
		$SOAF_STATE_CUR_PROP soaf_state_waiting_step_main
}

################################################################################
################################################################################

soaf_state_working_step_inerr() {
	local NATURE=$1
	local PROP_NATURE=$2
	local CUR_STATE=$3
	local MSG="Working error in state [$CUR_STATE] of nature [$NATURE]."
	soaf_log_err "$MSG" $SOAF_STATE_LOG_NAME
	local IS_NOTIF
	soaf_map_get_var IS_NOTIF $CUR_STATE $SOAF_STATE_NOTIF_ON_ERR_ATTR
	[ -n "$IS_NOTIF" ] && soaf_notif "$MSG"
	soaf_state_advance_step $PROP_NATURE $SOAF_STATE_STEP_INERR
}

soaf_state_working_step_main() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	local CUR_STATE=$4
	local FN
	soaf_map_get_var FN $CUR_STATE $SOAF_STATE_WORKING_FN_ATTR
	[ -z "$FN" ] && FN=soaf_state_dft_work
	local FN_ARGS="$FN $NATURE $WORK_DIR $CUR_STATE"
	soaf_state_pid_file $NATURE $CUR_STATE
	local PID_FILE=$SOAF_STATE_RET
	SOAF_STATE_WORKING_RET=
	soaf_fn_args_set_pid "$FN_ARGS" $PID_FILE $SOAF_STATE_LOG_NAME
	if [ -z "$SOAF_STATE_WORKING_RET" ]
	then
		soaf_state_working_step_inerr $NATURE $PROP_NATURE $CUR_STATE
	else
		soaf_state_advance_step_fn $NATURE $WORK_DIR $PROP_NATURE $CUR_STATE \
			$SOAF_STATE_STEP_SAVING soaf_state_saving_step_main
	fi
}

soaf_state_working_step_main_with_pid() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	local CUR_STATE=$4
	soaf_state_pid_file $NATURE $CUR_STATE
	local PID_FILE=$SOAF_STATE_RET
	local FN_ARGS="soaf_state_working_step_inerr"
	FN_ARGS="$FN_ARGS $NATURE $PROP_NATURE $CUR_STATE"
	local MSG="State [$CUR_STATE] of nature [$NATURE] works already"
	MSG="$MSG (pid: [@[PID]])."
	soaf_fn_args_check_pid "$FN_ARGS" $PID_FILE $SOAF_STATE_LOG_NAME \
		"$MSG" $SOAF_LOG_DEBUG
}

soaf_state_working_step() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	soaf_state_get_prop_n_call_fn $NATURE $WORK_DIR $PROP_NATURE \
		$SOAF_STATE_CUR_PROP soaf_state_working_step_main_with_pid
}

################################################################################
################################################################################

soaf_state_saving_step_main() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	local CUR_STATE=$4
	soaf_prop_file_set $PROP_NATURE $SOAF_STATE_PREV_PROP $CUR_STATE
	if [ -z "$SOAF_PROP_FILE_RET" ]
	then
		soaf_state_err
	else
		soaf_state_advance_step_fn $NATURE $WORK_DIR $PROP_NATURE $CUR_STATE \
			$SOAF_STATE_STEP_JUMPING soaf_state_jumping_step_main
	fi
}

soaf_state_saving_step() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	soaf_state_get_prop_n_call_fn $NATURE $WORK_DIR $PROP_NATURE \
		$SOAF_STATE_CUR_PROP soaf_state_saving_step_main
}

################################################################################
################################################################################

soaf_state_jumping_step_main() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	local PREV_STATE=$4
	local FN
	soaf_map_get_var FN $PREV_STATE $SOAF_STATE_NEXT_FN_ATTR
	if [ -n "$FN" ]
	then
		SOAF_STATE_NEXT_=
		$FN $NATURE $WORK_DIR $PREV_STATE
	else
		soaf_map_get_var SOAF_STATE_NEXT_ $PREV_STATE $SOAF_STATE_NEXT_ATTR
		if [ -z "$SOAF_STATE_NEXT_" ]
		then
			local MSG="Empty next state from : [$PREV_STATE]"
			soaf_state_err "$MSG (nature : [$NATURE])."
		fi
	fi
	if [ -n "$SOAF_STATE_NEXT_" ]
	then
		soaf_prop_file_set $PROP_NATURE $SOAF_STATE_CUR_PROP $SOAF_STATE_NEXT_
		if [ -z "$SOAF_PROP_FILE_RET" ]
		then
			soaf_state_err
		else
			local MSG="State of nature [$NATURE] is now : [$SOAF_STATE_NEXT_]."
			soaf_log_info "$MSG" $SOAF_STATE_LOG_NAME
			soaf_state_advance_step $PROP_NATURE $SOAF_STATE_STEP_WAITING
		fi
	fi
}

soaf_state_jumping_step() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	soaf_state_get_prop_n_call_fn $NATURE $WORK_DIR $PROP_NATURE \
		$SOAF_STATE_PREV_PROP soaf_state_jumping_step_main
}

################################################################################
################################################################################

soaf_state_inerr_step_rework() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	local CUR_STATE=$4
	soaf_state_advance_step_fn $NATURE $WORK_DIR $PROP_NATURE $CUR_STATE \
		$SOAF_STATE_STEP_WORKING soaf_state_working_step_main
}

soaf_state_inerr_step_main() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	local CUR_STATE=$4
	local REWORK=
	local AUTO_REWORK
	soaf_map_get_var AUTO_REWORK $CUR_STATE $SOAF_STATE_AUTO_REWORK_ATTR
	if [ -n "$AUTO_REWORK" ]
	then
		REWORK="OK"
	else
		soaf_state_rework_file $NATURE
		local REWORK_FILE=$SOAF_STATE_RET
		if [ -f $REWORK_FILE ]
		then
			soaf_rm $REWORK_FILE "" $SOAF_STATE_LOG_NAME
			if [ $SOAF_RET -ne 0 ]
			then
				soaf_state_err
			else
				REWORK="OK"
			fi
		else
			local MSG="State [$CUR_STATE] of nature [$NATURE] in"
			MSG="$MSG step [$SOAF_STATE_STEP_INERR]"
			MSG="$MSG (touch [$REWORK_FILE] to rework)."
			soaf_log_err "$MSG" $SOAF_STATE_LOG_NAME
			soaf_notif "$MSG"
		fi
	fi
	[ -n "$REWORK" ] && \
		soaf_state_inerr_step_rework $NATURE $WORK_DIR $PROP_NATURE $CUR_STATE
}

soaf_state_inerr_step() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	soaf_state_get_prop_n_call_fn $NATURE $WORK_DIR $PROP_NATURE \
		$SOAF_STATE_CUR_PROP soaf_state_inerr_step_main
}

################################################################################
################################################################################

soaf_state_step_case() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	soaf_prop_file_get $PROP_NATURE $SOAF_STATE_STEP_PROP
	if [ -z "$SOAF_PROP_FILE_RET" ]
	then
		soaf_state_err
	else
		local STEP=$SOAF_PROP_FILE_VAL
		case $STEP in
		$SOAF_STATE_STEP_WAITING)
			local FN=soaf_state_waiting_step
			;;
		$SOAF_STATE_STEP_WORKING)
			local FN=soaf_state_working_step
			;;
		$SOAF_STATE_STEP_SAVING)
			local FN=soaf_state_saving_step
			;;
		$SOAF_STATE_STEP_JUMPING)
			local FN=soaf_state_jumping_step
			;;
		$SOAF_STATE_STEP_INERR)
			local FN=soaf_state_inerr_step
			;;
		*)
			local FN=soaf_state_init_step
			;;
		esac
		$FN $NATURE $WORK_DIR $PROP_NATURE
	fi
}

################################################################################
################################################################################

soaf_state_is_active() {
	local NATURE=$1
	SOAF_STATE_ACTIVE="OK"
	soaf_state_inactive_file $NATURE
	[ -f $SOAF_STATE_RET ] && SOAF_STATE_ACTIVE=
}

soaf_state_proc_nature() {
	local NATURE=$1
	soaf_state_is_active $NATURE
	if [ -z "$SOAF_STATE_ACTIVE" ]
	then
		local MSG="State nature not active : [$NATURE]."
		soaf_log_info "$MSG" $SOAF_STATE_LOG_NAME
	else
		local PROP_FILE WORK_DIR
		soaf_map_get_var PROP_FILE $NATURE $SOAF_STATE_PROP_FILE_ATTR
		soaf_map_get_var WORK_DIR $NATURE $SOAF_STATE_WORK_DIR_ATTR \
			$SOAF_WORK_DIR
		soaf_state_prop_nature $NATURE
		local PROP_NATURE=$SOAF_STATE_RET
		soaf_create_prop_file_nature $PROP_NATURE $PROP_FILE
		soaf_state_step_case $NATURE $WORK_DIR $PROP_NATURE
	fi
}

################################################################################
################################################################################

soaf_state_engine() {
	local NATURE=$1
	SOAF_STATE_RET="OK"
	soaf_list_found "$SOAF_STATE_NATURE_LIST" $NATURE
	if [ -n "$SOAF_RET_LIST" ]
	then
		soaf_state_proc_nature $NATURE
	else
		soaf_state_err "Unknown state nature : [$NATURE]."
	fi
}
