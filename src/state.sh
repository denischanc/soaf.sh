################################################################################
################################################################################

SOAF_STATE_LOG_NAME="soaf.state"

SOAF_STATE_CUR_PROP="cur_state"
SOAF_STATE_PREV_PROP="prev_state"
SOAF_STATE_STEP_PROP="step"

SOAF_STATE_STEP_WAITING="waiting"
SOAF_STATE_STEP_WORKING="working"
SOAF_STATE_STEP_SAVING="saving"
SOAF_STATE_STEP_JUMPING="jumping"

SOAF_STATE_WORKING_FN_ATTR="soaf_state_working_fn"
SOAF_STATE_WORKING_JOB_LIST_ATTR="soaf_state_working_job_list"
SOAF_STATE_NEXT_FN_ATTR="soaf_state_next_fn"
SOAF_STATE_NEXT_ATTR="soaf_state_next"

SOAF_STATE_ENTRY_ATTR="soaf_state_entry"
SOAF_STATE_WORK_DIR_ATTR="soaf_state_work_dir"
SOAF_STATE_PROP_FILE_ATTR="soaf_state_prop_file"

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
	SOAF_STATE_LIST="$SOAF_STATE_LIST $STATE"
	soaf_map_extend $STATE $SOAF_STATE_WORKING_FN_ATTR $WORKING_FN
	soaf_map_extend $STATE $SOAF_STATE_WORKING_JOB_LIST_ATTR \
		"$WORKING_JOB_LIST"
	soaf_map_extend $STATE $SOAF_STATE_NEXT_FN_ATTR $NEXT_STATE_FN
	soaf_map_extend $STATE $SOAF_STATE_NEXT_ATTR $NEXT_STATE
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
	echo "soaf.state.$NATURE.prop"
}

################################################################################
################################################################################

soaf_state_do_job_list() {
	local JOB_LIST=$1
	soaf_do_job_list "$JOB_LIST"
	if [ -n "$SOAF_JOB_RET" ]
	then
		SOAF_STATE_WORKING_RET="OK"
	fi
}

soaf_state_dft_work() {
	local CUR_STATE=$3
	local JOB_LIST=$(soaf_map_get $CUR_STATE $SOAF_STATE_WORKING_JOB_LIST_ATTR)
	soaf_state_do_job_list "$JOB_LIST"
}

################################################################################
################################################################################

soaf_state_init_step() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	local ENTRY_STATE=$(soaf_map_get $NATURE $SOAF_STATE_ENTRY_ATTR)
	if [ -z "$ENTRY_STATE" ]
	then
		soaf_state_err "No entry state for nature : [$NATURE]."
	else
		soaf_prop_file_set $PROP_NATURE $SOAF_STATE_CUR_PROP $ENTRY_STATE
		if [ -z "$SOAF_PROP_FILE_RET" ]
		then
			soaf_state_err
		else
			local MSG="State of nature [$NATURE] is now : [$ENTRY_STATE]."
			soaf_log_info "$MSG" $SOAF_STATE_LOG_NAME
			soaf_prop_file_set $PROP_NATURE $SOAF_STATE_STEP_PROP \
				$SOAF_STATE_STEP_WAITING
			if [ -z "$SOAF_PROP_FILE_RET" ]
			then
				soaf_state_err
			else
				soaf_state_waiting_step_main $NATURE $WORK_DIR $PROP_NATURE \
					$ENTRY_STATE
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
			soaf_list_found "$SOAF_STATE_LIST" $STATE
			if [ -n "$SOAF_RET_LIST" ]
			then
				$FN $NATURE $WORK_DIR $PROP_NATURE $STATE
			else
				soaf_state_err "Unknown state : [$STATE]."
			fi
		fi
	fi
}

################################################################################
################################################################################

soaf_state_waiting_step_working() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	local CUR_STATE=$4
	local FN=$(soaf_map_get $CUR_STATE $SOAF_STATE_WORKING_FN_ATTR)
	[ -z "$FN" ] && FN=soaf_state_dft_work
	SOAF_STATE_WORKING_RET=
	$FN $NATURE $WORK_DIR $CUR_STATE
	if [ -z "$SOAF_STATE_WORKING_RET" ]
	then
		if [ -n "$SOAF_STATE_RET" ]
		then
			soaf_prop_file_set $PROP_NATURE $SOAF_STATE_STEP_PROP \
				$SOAF_STATE_STEP_WAITING
			[ -z "$SOAF_PROP_FILE_RET" ] && soaf_state_err
		fi
	else
		soaf_prop_file_set $PROP_NATURE $SOAF_STATE_STEP_PROP \
			$SOAF_STATE_STEP_SAVING
		if [ -z "$SOAF_PROP_FILE_RET" ]
		then
			soaf_state_err
		else
			soaf_state_saving_step_main $NATURE $WORK_DIR $PROP_NATURE \
				$CUR_STATE
		fi
	fi
}

soaf_state_waiting_step_main() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	local CUR_STATE=$4
	soaf_prop_file_set $PROP_NATURE $SOAF_STATE_STEP_PROP \
		$SOAF_STATE_STEP_WORKING
	if [ -z "$SOAF_PROP_FILE_RET" ]
	then
		soaf_state_err
	else
		soaf_state_waiting_step_working $NATURE $WORK_DIR $PROP_NATURE \
			$CUR_STATE
	fi
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

soaf_state_working_step() {
	local NATURE=$1
	local WORK_DIR=$2
	local PROP_NATURE=$3
	local THIS_SH=$(basename $0)
	local NB_PROC=$(ps -e | grep -w $THIS_SH | grep -v grep | wc -l)
	local MSG="Current state of nature [$NATURE] in"
	MSG="$MSG $SOAF_STATE_STEP_WORKING step"
	if [ "$NB_PROC" != "2" ]
	then
		MSG="$MSG without running process : [$THIS_SH]."
		soaf_log_err "$MSG" $SOAF_STATE_LOG_NAME
		soaf_notif "$MSG"
	else
		soaf_log_debug "$MSG." $SOAF_STATE_LOG_NAME
	fi
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
		soaf_prop_file_set $PROP_NATURE $SOAF_STATE_STEP_PROP \
			$SOAF_STATE_STEP_JUMPING
		if [ -z "$SOAF_PROP_FILE_RET" ]
		then
			soaf_state_err
		else
			soaf_state_jumping_step_main $NATURE $WORK_DIR $PROP_NATURE \
				$CUR_STATE
		fi
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
	local FN=$(soaf_map_get $PREV_STATE $SOAF_STATE_NEXT_FN_ATTR)
	if [ -n "$FN" ]
	then
		SOAF_STATE_NEXT_=
		$FN $NATURE $WORK_DIR $PREV_STATE
	else
		SOAF_STATE_NEXT_=$(soaf_map_get $PREV_STATE $SOAF_STATE_NEXT_ATTR)
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
			soaf_prop_file_set $PROP_NATURE $SOAF_STATE_STEP_PROP \
				$SOAF_STATE_STEP_WAITING
			[ -z "$SOAF_PROP_FILE_RET" ] && soaf_state_err
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
		*)
			local FN=soaf_state_init_step
			;;
		esac
		$FN $NATURE $WORK_DIR $PROP_NATURE
	fi
}

################################################################################
################################################################################

soaf_state_inactive_file() {
	local NATURE=$1
	local WORK_DIR=${2:-$SOAF_WORK_DIR}
	echo "$WORK_DIR/soaf.state.$NATURE.inactive"
}

soaf_state_is_active() {
	local NATURE=$1
	local WORK_DIR=$2
	local INACTIVE_FILE=$(soaf_state_inactive_file $NATURE $WORK_DIR)
	SOAF_STATE_ACTIVE="OK"
	[ -f $INACTIVE_FILE ] && SOAF_STATE_ACTIVE=
}

soaf_state_proc_nature() {
	local NATURE=$1
	local WORK_DIR=$(soaf_map_get $NATURE $SOAF_STATE_WORK_DIR_ATTR \
		$SOAF_WORK_DIR)
	soaf_state_is_active $NATURE $WORK_DIR
	if [ -z "$SOAF_STATE_ACTIVE" ]
	then
		local MSG="State nature not active : [$NATURE]."
		soaf_log_debug "$MSG" $SOAF_STATE_LOG_NAME
	else
		local PROP_NATURE=$(soaf_state_prop_nature $NATURE)
		local PROP_FILE=$(soaf_map_get $NATURE $SOAF_STATE_PROP_FILE_ATTR)
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
