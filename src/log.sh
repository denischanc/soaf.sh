################################################################################
################################################################################

SOAF_LOG_DEV_ERR=10
SOAF_LOG_ERR=4
SOAF_LOG_WARN=3
SOAF_LOG_INFO=2
SOAF_LOG_DEBUG=1

SOAF_LOG_DEV_ERR_LABEL="DEV.ERROR"
SOAF_LOG_ERR_LABEL="ERROR"
SOAF_LOG_WARN_LABEL="WARN_"
SOAF_LOG_INFO_LABEL="INFO_"
SOAF_LOG_DEBUG_LABEL="DEBUG"

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

soaf_log_static_() {
	soaf_usermsgproc_add_use_fn soaf_log_use_usermsgproc
}

soaf_log_cfg_() {
	SOAF_LOG_LEVEL=$SOAF_LOG_INFO
	SOAF_LOG_LEVEL_NOT_ALIVE=$SOAF_LOG_ERR
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
	###---------------
	soaf_map_extend $SOAF_LOG_COLOR_MAP $SOAF_LOG_DEV_ERR $SOAF_CONSOLE_FG_RED
	soaf_map_extend $SOAF_LOG_COLOR_MAP $SOAF_LOG_ERR $SOAF_CONSOLE_FG_RED
	soaf_map_extend $SOAF_LOG_COLOR_MAP $SOAF_LOG_WARN $SOAF_CONSOLE_FG_YELLOW
	soaf_map_extend $SOAF_LOG_COLOR_MAP $SOAF_LOG_INFO $SOAF_CONSOLE_FG_MAGENTA
	soaf_map_extend $SOAF_LOG_COLOR_MAP $SOAF_LOG_DEBUG $SOAF_CONSOLE_FG_CYAN
}

soaf_log_init_() {
	soaf_info_add_var "SOAF_LOG_LEVEL SOAF_LOG_LEVEL_NOT_ALIVE"
	soaf_dis_var_w_fn SOAF_LOG_LEVEL soaf_log_val_of_lvl_var_
	soaf_dis_var_w_fn SOAF_LOG_LEVEL_NOT_ALIVE soaf_log_val_of_lvl_var_
	soaf_info_add_var "SOAF_LOG_DIR SOAF_LOG_FILE SOAF_LOG_USED_NATURE"
	soaf_info_add_var SOAF_LOG_CMD_OUT_ERR_DIR
	###---------------
	[ -z "$SOAF_LOG_USED_NATURE" ] && soaf_create_log_dft_
	[ "$SOAF_LOG_ROLL_NATURE" = "$SOAF_LOG_ROLL_DFT_NATURE" ] && \
		soaf_create_roll_cond_gt_nature $SOAF_LOG_ROLL_DFT_NATURE
}

soaf_log_prepenv_() {
	if [ -z "$SOAF_LOG_USERMSGPROC_USED" ]
	then
		soaf_map_get $SOAF_LOG_USED_NATURE $SOAF_LOG_PREP_FN_ATTR
		local PREP_FN=$SOAF_RET
		[ -n "$PREP_FN" ] && $PREP_FN $SOAF_LOG_USED_NATURE
	fi
	SOAF_LOG_STATE=$SOAF_LOG_ALIVE_S
}

soaf_create_module soaf.core.log $SOAF_VERSION soaf_log_static_ \
	soaf_log_cfg_ soaf_log_init_ soaf_log_prepenv_ "" "" "" "" $SOAF_POS_PRE

################################################################################
################################################################################

soaf_log_use_usermsgproc() {
	SOAF_LOG_USERMSGPROC_USED="OK"
}

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

soaf_log_add_log_level_fn() {
	local FN_LIST=$1
	local POS=${2:-$SOAF_POS_MAIN}
	soaf_pmp_list_fill $POS SOAF_LOG_LOGLVL_FN "$FN_LIST"
}

soaf_all_log_level() {
	local LOG_LEVEL=$1 fn
	soaf_pmp_list_cat SOAF_LOG_LOGLVL_FN
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
		if [ -n "$NAME" ]
		then
			soaf_map_get $NAME $SOAF_LOG_LEVEL_ATTR $SOAF_LOG_RET
			SOAF_LOG_RET=$SOAF_RET
		fi
	else
		SOAF_LOG_RET=${SOAF_LOG_LEVEL_NOT_ALIVE:-$SOAF_LOG_ERR}
	fi
}

soaf_log_label_level_() {
	local LEVEL=$1
	case $LEVEL in
	$SOAF_LOG_INFO) SOAF_LOG_RET=$SOAF_LOG_INFO_LABEL;;
	$SOAF_LOG_WARN) SOAF_LOG_RET=$SOAF_LOG_WARN_LABEL;;
	$SOAF_LOG_ERR) SOAF_LOG_RET=$SOAF_LOG_ERR_LABEL;;
	$SOAF_LOG_DEV_ERR) SOAF_LOG_RET=$SOAF_LOG_DEV_ERR_LABEL;;
	*) SOAF_LOG_RET=$SOAF_LOG_DEBUG_LABEL;;
	esac
}

soaf_log_val_of_lvl_var_() {
	local VAR=$1
	eval soaf_log_label_level_ \$$VAR
	SOAF_RET=$SOAF_LOG_RET
}

################################################################################
################################################################################

soaf_log_build_msg_() {
	local LEVEL=$1
	local MSG=$2
	local NAME=$3
	if [ -n "$NAME" ]
	then
		if [ -n "$SOAF_LOG_COLOR" ]
		then
			soaf_console_msg_ctl $NAME $SOAF_CONSOLE_CTL_BOLD
			NAME=$SOAF_CONSOLE_RET
		fi
		MSG="{$NAME} $MSG"
	fi
	soaf_log_label_level_ $LEVEL
	local LEVEL_LABEL=$SOAF_LOG_RET
	if [ -n "$SOAF_LOG_COLOR" ]
	then
		soaf_map_get $SOAF_LOG_COLOR_MAP $LEVEL
		soaf_console_msg_ctl $LEVEL_LABEL ${SOAF_RET:-$SOAF_CONSOLE_FG_RED}
		LEVEL_LABEL=$SOAF_CONSOLE_RET
	fi
	local DATE_TIME=$(date +%x_%X)
	SOAF_LOG_RET="[$DATE_TIME][$LEVEL_LABEL]  $MSG"
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

soaf_log_console_() {
	local LEVEL=$1
	local MSG=$2
	local NAME=$3
	soaf_log_build_msg_ $LEVEL "$MSG" $NAME
	case $LEVEL in
	$SOAF_LOG_DEV_ERR|$SOAF_LOG_ERR) soaf_console_err "$SOAF_LOG_RET";;
	*) soaf_console_info "$SOAF_LOG_RET";;
	esac
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
	local LEVEL=$1
	local NAME=$2
	soaf_log_level $NAME
	local CUR_LEVEL=$SOAF_LOG_RET
	SOAF_LOG_RET=
	[ $LEVEL -ge $CUR_LEVEL ] && SOAF_LOG_RET="OK"
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
			soaf_map_get $SOAF_LOG_USED_NATURE $SOAF_LOG_FN_ATTR
			local FN=$SOAF_RET
			[ -n "$FN" ] && $FN $SOAF_LOG_USED_NATURE $LEVEL "$MSG" $NAME
		else
			soaf_log_console_ $LEVEL "$MSG" $NAME
		fi
	fi
}

soaf_log() {
	local LEVEL=${1:-$SOAF_LOG_INFO}
	local MSG=$2
	local NAME=$3
	soaf_log_filter_ $LEVEL $NAME
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
	soaf_log_console_ $SOAF_LOG_DEV_ERR "$MSG" "appli.dev.2fix"
}

################################################################################
################################################################################

soaf_log_stdin() {
	local LEVEL=${1:-$SOAF_LOG_ERR}
	local NAME=$2
	while read
	do
		soaf_log $LEVEL "$REPLY" $NAME
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
