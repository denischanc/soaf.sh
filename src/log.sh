################################################################################
################################################################################

SOAF_LOG_ERR="ERR__"
SOAF_LOG_WARN="WARN_"
SOAF_LOG_INFO="INFO_"
SOAF_LOG_DEBUG="DEBUG"

SOAF_LOG_NATURE_INT="soaf.log"
SOAF_LOG_ROLL_NATURE_INT="soaf.log.roll"

SOAF_LOG_LEVEL_ATTR="soaf_log_level"

SOAF_LOG_FN_ATTR="soaf_log_fn"

################################################################################
################################################################################

soaf_log_cfg() {
	local USER_NATURE=$1
	###---------------
	soaf_cfg_set SOAF_LOG_LEVEL $SOAF_LOG_INFO
	###---------------
	soaf_cfg_set SOAF_LOG_NATURE_LIST $SOAF_LOG_NATURE_INT
	soaf_cfg_set SOAF_LOG_ROLL_NATURE $SOAF_LOG_ROLL_NATURE_INT
	###---------------
	local USER_NAME=$(soaf_map_get $USER_NATURE $SOAF_USER_NAME_ATTR)
	soaf_cfg_set SOAF_LOG_FILE $SOAF_LOG_DIR/$USER_NAME.log
}

soaf_log_init() {
	soaf_info_add_var "SOAF_LOG_LEVEL SOAF_LOG_FILE"
	###---------------
	soaf_create_log_nature $SOAF_LOG_NATURE_INT soaf_log_int
	soaf_create_roll_cond_gt_nature $SOAF_LOG_ROLL_NATURE_INT $SOAF_LOG_FILE
}

soaf_log_prepenv() {
	local nature
	for nature in $SOAF_LOG_NATURE_LIST
	do
		if [ "$nature" = "$SOAF_LOG_NATURE_INT" ]
		then
			mkdir -p $(dirname $SOAF_LOG_FILE)
		fi
	done
}

soaf_engine_add_cfg_fn soaf_log_cfg
soaf_engine_add_init_fn soaf_log_init
soaf_engine_add_prepenv_fn soaf_log_prepenv

################################################################################
################################################################################

soaf_create_log_nature() {
	local NATURE=$1
	local FN=$2
	soaf_map_extend $NATURE $SOAF_LOG_FN_ATTR $FN
}

################################################################################
################################################################################

soaf_all_log_level() {
	local LOG_LEVEL=$1 fn
	for fn in $SOAF_NAME_LOGLVL_FN_LIST
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

soaf_log_num_level() {
	local LEVEL=$1
	case $LEVEL in
		$SOAF_LOG_INFO) echo "2";;
		$SOAF_LOG_WARN) echo "3";;
		$SOAF_LOG_ERR) echo "4";;
		*) echo "1";;
	esac
}

################################################################################
################################################################################

soaf_log_int() {
	local LEVEL=$1
	local MSG=$2
	local NAME=$3
	local LEVEL_LOC_NUM=$(soaf_log_num_level $LEVEL)
	local LEVEL_GLOB=$SOAF_LOG_LEVEL
	[ -n "$NAME" ] && \
		LEVEL_GLOB=$(soaf_map_get $NAME $SOAF_LOG_LEVEL_ATTR $LEVEL_GLOB)
	local LEVEL_GLOB_NUM=$(soaf_log_num_level $LEVEL_GLOB)
	if [ $LEVEL_LOC_NUM -ge $LEVEL_GLOB_NUM ]
	then
		if [ -z "$SOAF_LOG_ROLL_IN" ]
		then
			SOAF_LOG_ROLL_IN="OK"
			soaf_roll_nature $SOAF_LOG_ROLL_NATURE
			SOAF_LOG_ROLL_IN=
		fi
		[ -n "$NAME" ] && MSG="{$NAME} $MSG"
		cat << _EOF_ >> $SOAF_LOG_FILE
[$(date '+%x_%X')][$LEVEL]  $MSG
_EOF_
	fi
}

################################################################################
################################################################################

soaf_log() {
	local LEVEL=$1
	local MSG=$2
	local NAME=$3
	local nature
	for nature in $SOAF_LOG_NATURE_LIST
	do
		local FN=$(soaf_map_get $nature $SOAF_LOG_FN_ATTR)
		[ -n "$FN" ] && $FN $LEVEL "$MSG" $NAME
	done
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
