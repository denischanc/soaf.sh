################################################################################
################################################################################

SOAF_LOG_ERR="ERROR"
SOAF_LOG_WARN="WARN_"
SOAF_LOG_INFO="INFO_"
SOAF_LOG_DEBUG="DEBUG"

SOAF_LOG_ERR_NB=4
SOAF_LOG_WARN_NB=3
SOAF_LOG_INFO_NB=2
SOAF_LOG_DEBUG_NB=1

SOAF_LOG_DFT_NATURE="soaf.log.default"
SOAF_LOG_ROLL_DFT_NATURE="soaf.log.roll.default"

SOAF_LOG_LEVEL_ATTR="soaf_log_level"

SOAF_LOG_FN_ATTR="soaf_log_fn"
SOAF_LOG_PREP_FN_ATTR="soaf_log_prep_fn"

SOAF_LOG_UNKNOWN_S="UNKNOWN"
SOAF_LOG_ALIVE_S="ALIVE"
SOAF_LOG_DEAD_S="DEAD"
SOAF_LOG_STATE=$SOAF_LOG_UNKNOWN_S

SOAF_LOG_COLOR_MAP="soaf.log.color"

################################################################################
################################################################################

soaf_log_cfg() {
	SOAF_LOG_LEVEL=$SOAF_LOG_INFO
	SOAF_LOG_LEVEL_STDERR=$SOAF_LOG_ERR
	###---------------
	SOAF_LOG_ROLL_NATURE=$SOAF_LOG_ROLL_DFT_NATURE
	###---------------
	SOAF_LOG_DIR=@[SOAF_WORK_DIR]/log
	SOAF_LOG_FILE=@[SOAF_LOG_DIR]/$SOAF_APPLI_NAME.log
	SOAF_LOG_CMD_OUT_ERR_DIR=@[SOAF_LOG_DIR]
	SOAF_LOG_CMD_OUT_FILE=@[SOAF_LOG_CMD_OUT_ERR_DIR]/$SOAF_APPLI_NAME.cmd.out
	SOAF_LOG_CMD_ERR_FILE=@[SOAF_LOG_CMD_OUT_ERR_DIR]/$SOAF_APPLI_NAME.cmd.err
	soaf_var_add_unsubst "SOAF_LOG_DIR SOAF_LOG_FILE SOAF_LOG_CMD_OUT_ERR_DIR \
		SOAF_LOG_CMD_OUT_FILE SOAF_LOG_CMD_ERR_FILE"
}

soaf_log_init() {
	soaf_info_add_var "SOAF_LOG_LEVEL SOAF_LOG_LEVEL_STDERR"
	soaf_info_add_var "SOAF_LOG_DIR SOAF_LOG_FILE SOAF_LOG_USED_NATURE"
	soaf_info_add_var SOAF_LOG_CMD_OUT_ERR_DIR
	###---------------
	[ -z "$SOAF_LOG_USED_NATURE" ] && soaf_create_log_dft_
	[ "$SOAF_LOG_ROLL_NATURE" = "$SOAF_LOG_ROLL_DFT_NATURE" ] && \
		soaf_create_roll_cond_gt_nature $SOAF_LOG_ROLL_DFT_NATURE
	###---------------
	soaf_map_extend $SOAF_LOG_COLOR_MAP $SOAF_LOG_ERR 31
	soaf_map_extend $SOAF_LOG_COLOR_MAP DEV.$SOAF_LOG_ERR 31
	soaf_map_extend $SOAF_LOG_COLOR_MAP $SOAF_LOG_WARN 33
	soaf_map_extend $SOAF_LOG_COLOR_MAP $SOAF_LOG_INFO 35
	soaf_map_extend $SOAF_LOG_COLOR_MAP $SOAF_LOG_DEBUG 36
}

soaf_log_prepenv() {
	local PREP_FN
	soaf_map_get_var PREP_FN $SOAF_LOG_USED_NATURE $SOAF_LOG_PREP_FN_ATTR
	[ -n "$PREP_FN" ] && $PREP_FN $SOAF_LOG_USED_NATURE
	SOAF_LOG_STATE=$SOAF_LOG_ALIVE_S
}

soaf_define_add_this_cfg_fn soaf_log_cfg
soaf_define_add_this_init_fn soaf_log_init
soaf_define_add_this_prepenv_fn soaf_log_prepenv $SOAF_POS_PRE

################################################################################
################################################################################

soaf_log_use_usermsgproc() {
	SOAF_LOG_USERMSGPROC_USED="OK"
}

soaf_define_add_use_usermsgproc_fn soaf_log_use_usermsgproc

################################################################################
################################################################################

soaf_create_log_nature() {
	local NATURE=$1
	local FN=$2
	local PREP_FN=$3
	SOAF_LOG_USED_NATURE=$NATURE
	soaf_map_extend $NATURE $SOAF_LOG_FN_ATTR $FN
	soaf_map_extend $NATURE $SOAF_LOG_PREP_FN_ATTR $PREP_FN
}

################################################################################
################################################################################

soaf_create_log_dft_() {
	soaf_create_log_nature $SOAF_LOG_DFT_NATURE soaf_log_dft_ \
		soaf_log_dft_prep_
}

################################################################################
################################################################################

soaf_all_log_level() {
	local LOG_LEVEL=$1 fn
	soaf_pmp_list_cat SOAF_NAME_LOGLVL_FN
	for fn in $SOAF_RET_LIST
	do
		$fn $LOG_LEVEL
	done
}

soaf_log_name_log_level() {
	local NAME=$1
	local LEVEL=$2
	soaf_map_extend "$NAME" $SOAF_LOG_LEVEL_ATTR $LEVEL
}

################################################################################
################################################################################

soaf_log_stop() {
	SOAF_LOG_STATE=$SOAF_LOG_DEAD_S
}

################################################################################
################################################################################

soaf_log_level() {
	local NAME=$1
	if [ "$SOAF_LOG_STATE" = "$SOAF_LOG_ALIVE_S" ]
	then
		SOAF_LOG_RET=$SOAF_LOG_LEVEL
		[ -n "$NAME" ] && soaf_map_get_var SOAF_LOG_RET \
			$NAME $SOAF_LOG_LEVEL_ATTR $SOAF_LOG_RET
	else
		SOAF_LOG_RET=$SOAF_LOG_LEVEL_STDERR
	fi
}

soaf_log_num_level_() {
	local LEVEL=$1
	case "$LEVEL" in
		$SOAF_LOG_INFO) SOAF_LOG_RET=$SOAF_LOG_INFO_NB;;
		$SOAF_LOG_WARN) SOAF_LOG_RET=$SOAF_LOG_WARN_NB;;
		$SOAF_LOG_ERR) SOAF_LOG_RET=$SOAF_LOG_ERR_NB;;
		*) SOAF_LOG_RET=$SOAF_LOG_DEBUG_NB;;
	esac
}

################################################################################
################################################################################

soaf_log_build_msg_() {
	local LEVEL=$1
	local MSG=$2
	local NAME=$3
	[ -n "$NAME" ] && MSG="{$NAME} $MSG"
	if [ -n "$SOAF_LOG_COLOR" ]
	then
		local COLOR
		soaf_map_get_var COLOR $SOAF_LOG_COLOR_MAP $LEVEL
		soaf_console_msg_color $LEVEL ${COLOR:-31}
		LEVEL=$SOAF_CONSOLE_RET
	fi
	local DATE_TIME=$(date +%x_%X)
	SOAF_LOG_RET="[$DATE_TIME][$LEVEL]  $MSG"
}

################################################################################
################################################################################

soaf_log_dft_() {
	### local NATURE=$1
	local LEVEL=$2
	local MSG=$3
	local NAME=$4
	if [ -z "$SOAF_LOG_ROLL_IN" ]
	then
		SOAF_LOG_ROLL_IN="OK"
		soaf_roll_nature $SOAF_LOG_ROLL_NATURE $SOAF_LOG_FILE
		SOAF_LOG_ROLL_IN=
	fi
	soaf_log_build_msg_ $LEVEL "$MSG" $NAME
	printf "$SOAF_LOG_RET\n" >> $SOAF_LOG_FILE
}

soaf_log_dft_prep_() {
	local LOG_DIR=$(dirname $SOAF_LOG_FILE)
	mkdir -p $LOG_DIR |& soaf_log_stdin "" "soaf.log"
	[ ! -d $LOG_DIR ] && soaf_engine_exit
}

################################################################################
################################################################################

soaf_log_stderr_() {
	local LEVEL=$1
	local MSG=$2
	local NAME=$3
	soaf_log_build_msg_ $LEVEL "$MSG" $NAME
	soaf_console_err "$SOAF_LOG_RET"
}

################################################################################
################################################################################

soaf_log_usermsgproc_() {
	local LEVEL=$1
	local MSG=$2
	local NAME=$3
	soaf_log_build_msg_ $LEVEL "$MSG" $NAME
	soaf_usermsgproc__ $SOAF_USERMSGPROC_LOG_ORG "$SOAF_LOG_RET"
}

################################################################################
################################################################################

soaf_log_filter_() {
	local NATURE=$1
	local LEVEL=$2
	local NAME=$3
	soaf_log_num_level_ $LEVEL
	local MSG_LEVEL_NUM=$SOAF_LOG_RET
	soaf_log_level $NAME
	soaf_log_num_level_ $SOAF_LOG_RET
	local CUR_LEVEL_NUM=$SOAF_LOG_RET
	SOAF_LOG_RET=
	[ $MSG_LEVEL_NUM -ge $CUR_LEVEL_NUM ] && SOAF_LOG_RET="OK"
}

soaf_log_route_() {
	local LEVEL=$1
	local MSG=$2
	local NAME=$3
	if [ -n "$SOAF_LOG_USERMSGPROC_USED" ]
	then
		soaf_log_usermsgproc_ $LEVEL "$MSG" $NAME
	else
		if [ "$SOAF_LOG_STATE" = "$SOAF_LOG_ALIVE_S" ]
		then
			local FN
			soaf_map_get_var FN $SOAF_LOG_USED_NATURE $SOAF_LOG_FN_ATTR
			[ -n "$FN" ] && $FN $SOAF_LOG_USED_NATURE $LEVEL "$MSG" $NAME
		else
			soaf_log_stderr_ $LEVEL "$MSG" $NAME
		fi
	fi
}

soaf_log() {
	local LEVEL=${1:-$SOAF_LOG_INFO}
	local MSG=$2
	local NAME=$3
	soaf_log_filter_ $SOAF_LOG_USED_NATURE $LEVEL $NAME
	if [ -n "$SOAF_LOG_RET" ]
	then
		if [ "$SOAF_LOG_STATE" != "$SOAF_LOG_DEAD_S" ]
		then
			soaf_log_route_ $LEVEL "$MSG" $NAME
		fi
	fi
}

################################################################################
################################################################################

soaf_log_err() {
	local MSG=$1
	local NAME=$2
	soaf_log $SOAF_LOG_ERR "$MSG" $NAME
}

soaf_log_warn() {
	local MSG=$1
	local NAME=$2
	soaf_log $SOAF_LOG_WARN "$MSG" $NAME
}

soaf_log_info() {
	local MSG=$1
	local NAME=$2
	soaf_log $SOAF_LOG_INFO "$MSG" $NAME
}

soaf_log_debug() {
	local MSG=$1
	local NAME=$2
	soaf_log $SOAF_LOG_DEBUG "$MSG" $NAME
}

################################################################################
################################################################################

soaf_log_dev_err() {
	local MSG=$1
	soaf_log_stderr_ DEV.$SOAF_LOG_ERR "$MSG" "appli.dev.2fix"
}

################################################################################
################################################################################

soaf_log_stdin() {
	local LEVEL=${1:-$SOAF_LOG_ERR}
	local NAME=$2
	local line
	while read line
	do
		soaf_log $LEVEL "$line" $NAME
	done
}

soaf_log_from_file() {
	local FILE=$1
	local LEVEL=$2
	local NAME=$3
	if [ -s "$FILE" ]
	then
		soaf_log_stdin "$LEVEL" $NAME < $FILE
	fi
	rm -f $FILE 2> /dev/null
}

################################################################################
################################################################################

soaf_log_prep_cmd_common_() {
	local CMD_LOG_FILE=$1
	local NAME=$2
	local CMD_LOG_DIR=$(dirname $CMD_LOG_FILE)
	[ ! -d $CMD_LOG_DIR ] && \
		mkdir -p $CMD_LOG_DIR |& soaf_log_stdin "" $NAME
	[ ! -d $CMD_LOG_DIR ] && soaf_engine_exit
}

soaf_log_prep_cmd_out() {
	local CMD=$1
	local NAME=$2
	soaf_log_prep_cmd_common_ $SOAF_LOG_CMD_OUT_FILE $NAME
	SOAF_LOG_RET="$CMD > $SOAF_LOG_CMD_OUT_FILE"
}

soaf_log_prep_cmd_err() {
	local CMD=$1
	local NAME=$2
	soaf_log_prep_cmd_common_ $SOAF_LOG_CMD_ERR_FILE $NAME
	SOAF_LOG_RET="$CMD 2> $SOAF_LOG_CMD_ERR_FILE"
}

soaf_log_prep_cmd_out_err() {
	local CMD=$1
	local NAME=$2
	soaf_log_prep_cmd_out "$CMD" $NAME
	soaf_log_prep_cmd_err "$SOAF_LOG_RET" $NAME
}

################################################################################
################################################################################

soaf_log_cmd_out() {
	local NAME=$1
	local LEVEL=${2:-$SOAF_LOG_DEBUG}
	soaf_log_from_file $SOAF_LOG_CMD_OUT_FILE $LEVEL $NAME
}

soaf_log_cmd_err() {
	local NAME=$1
	local LEVEL=${2:-$SOAF_LOG_ERR}
	soaf_log_from_file $SOAF_LOG_CMD_ERR_FILE $LEVEL $NAME
}

soaf_log_cmd_out_err() {
	local NAME=$1
	local OUT_LEVEL=$2
	local ERR_LEVEL=$3
	soaf_log_cmd_out "$NAME" $OUT_LEVEL
	soaf_log_cmd_err "$NAME" $ERR_LEVEL
}
