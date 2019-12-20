################################################################################
################################################################################

SOAF_NOTIF_LOG_NAME="soaf.notif"

SOAF_NOTIF_FN_ATTR="soaf_notif_fn"
SOAF_NOTIF_NB_TRY_ATTR="soaf_notif_nb_try"

SOAF_NOTIF_NB_TRY_DFT=3

################################################################################
################################################################################

soaf_notif_cfg() {
	SOAF_NOTIF_DIR=@[SOAF_WORK_DIR]/notif
	soaf_var_add_unsubst SOAF_NOTIF_DIR
}

soaf_notif_init() {
	soaf_info_add_var "SOAF_NOTIF_DIR SOAF_NOTIF_NATURE_LIST"
}

soaf_create_module soaf.core.notif $SOAF_VERSION soaf_notif_cfg soaf_notif_init

################################################################################
################################################################################

soaf_notif_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_NOTIF_LOG_NAME $LOG_LEVEL
}

soaf_define_add_name_log_level_fn soaf_notif_log_level

################################################################################
################################################################################

soaf_create_notif_nature() {
	local NATURE=$1
	local FN=$2
	local NB_TRY=$3
	SOAF_NOTIF_NATURE_LIST="$SOAF_NOTIF_NATURE_LIST $NATURE"
	soaf_map_extend $NATURE $SOAF_NOTIF_FN_ATTR $FN
	soaf_map_extend $NATURE $SOAF_NOTIF_NB_TRY_ATTR $NB_TRY
}

################################################################################
################################################################################

soaf_notif_in_file() {
	local MSG=$1
	local PROG=$2
	local HOST=$3
	local NOTIF_FILE=$SOAF_NOTIF_DIR/msg-$$-$(date '+%F-%H%M%S')
	local LOG_MSG="Notification message posted in [$NOTIF_FILE]."
	soaf_log_err "$LOG_MSG" $SOAF_NOTIF_LOG_NAME
	soaf_mkdir $SOAF_NOTIF_DIR "" $SOAF_NOTIF_LOG_NAME
	echo "[$HOST:$PROG] $MSG" > $NOTIF_FILE
}

soaf_notif() {
	local MSG=$1
	local PROG=$(basename $0)
	local HOST=$(hostname -f)
	local nature
	for nature in $SOAF_NOTIF_NATURE_LIST
	do
		local FN NB_TRY
		soaf_map_get_var FN $nature $SOAF_NOTIF_FN_ATTR
		soaf_map_get_var NB_TRY $nature $SOAF_NOTIF_NB_TRY_ATTR \
			$SOAF_NOTIF_NB_TRY_DFT
		local ID_TRY=1
		while [ -n "$ID_TRY" -a ${ID_TRY:-1} -le $NB_TRY ]
		do
			SOAF_NOTIF_RET=
			$FN $nature "$MSG" $PROG $HOST
			if [ -n "$SOAF_NOTIF_RET" ]
			then
				local LOG_MSG="Notif of nature [$nature] OK."
				soaf_log_debug "$LOG_MSG" $SOAF_NOTIF_LOG_NAME
				ID_TRY=
			else
				local LOG_MSG="Notif of nature [$nature] KO."
				soaf_log_err "$LOG_MSG" $SOAF_NOTIF_LOG_NAME
				ID_TRY=$(($ID_TRY + 1))
				[ $ID_TRY -gt $NB_TRY ] && \
					soaf_notif_in_file "$MSG" $PROG $HOST
			fi
		done
	done
}
