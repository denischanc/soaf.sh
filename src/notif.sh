################################################################################
################################################################################

readonly SOAF_NOTIF_LOG_NAME="soaf.notif"

readonly SOAF_NOTIF_FN_ATTR="soaf_notif_fn"
readonly SOAF_NOTIF_NB_TRY_ATTR="soaf_notif_nb_try"

readonly SOAF_NOTIF_NB_TRY_DFT=3

################################################################################
################################################################################

soaf_notif_static_() {
	soaf_log_add_log_level_fn soaf_notif_log_level
}

soaf_notif_cfg_() {
	SOAF_NOTIF_DIR=@[SOAF_WORK_DIR]/notif
	soaf_var_add_unsubst SOAF_NOTIF_DIR
}

soaf_notif_init_() {
	soaf_info_add_var "SOAF_NOTIF_DIR SOAF_NOTIF_NATURE_LIST"
}

soaf_create_module soaf.core.notif $SOAF_VERSION soaf_notif_static_ \
	soaf_notif_cfg_ soaf_notif_init_

################################################################################
################################################################################

soaf_notif_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_NOTIF_LOG_NAME $LOG_LEVEL
}

################################################################################
################################################################################

soaf_create_notif_nature() {
	local NATURE=$1
	local FN=$2
	local NB_TRY=$3
	SOAF_NOTIF_NATURE_LIST+=" $NATURE"
	soaf_map_extend $NATURE $SOAF_NOTIF_FN_ATTR $FN
	soaf_map_extend $NATURE $SOAF_NOTIF_NB_TRY_ATTR $NB_TRY
}

################################################################################
################################################################################

soaf_notif_in_file_() {
	local MSG=$1
	local PROG=$2
	local HOST=$3
	local NOTIF_FILE=$SOAF_NOTIF_DIR/msg-$$-$(date '+%F-%H%M%S')
	local LOG_MSG="Notification message posted in [$NOTIF_FILE]."
	soaf_log_err "$LOG_MSG" $SOAF_NOTIF_LOG_NAME
	soaf_mkdir $SOAF_NOTIF_DIR "" $SOAF_NOTIF_LOG_NAME
	printf "[$HOST:$PROG] $MSG\n" >> $NOTIF_FILE
}

soaf_notif() {
	local MSG=$1
	local PROG=$(basename $0)
	local HOST=$(hostname -f)
	local nature
	for nature in $SOAF_NOTIF_NATURE_LIST
	do
		soaf_map_get $nature $SOAF_NOTIF_NB_TRY_ATTR $SOAF_NOTIF_NB_TRY_DFT
		local NB_TRY=$SOAF_RET
		local ID_TRY=1
		while [ -n "$ID_TRY" -a ${ID_TRY:-1} -le $NB_TRY ]
		do
			soaf_map_get $nature $SOAF_NOTIF_FN_ATTR
			local FN=$SOAF_RET
			SOAF_NOTIF_RET=
			[ -n "$FN" ] && $FN $nature "$MSG" $PROG $HOST
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
					soaf_notif_in_file_ "$MSG" $PROG $HOST
			fi
		done
	done
}
