################################################################################
################################################################################

SOAF_NOTIF_LOG_NAME="soaf.notif"

SOAF_NOTIF_FN_ATTR="soaf_notif_fn"

################################################################################
################################################################################

soaf_notif_init() {
	soaf_info_add_var SOAF_NOTIF_NATURE_LIST
}

soaf_define_add_engine_init_fn soaf_notif_init

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
	SOAF_NOTIF_NATURE_LIST="$SOAF_NOTIF_NATURE_LIST $NATURE"
	soaf_map_extend $NATURE $SOAF_NOTIF_FN_ATTR $FN
}

################################################################################
################################################################################

soaf_notif() {
	local MSG=$1
	local PROG=$(basename $0)
	local HOST=$(hostname -f)
	local nature
	for nature in $SOAF_NOTIF_NATURE_LIST
	do
		local FN=$(soaf_map_get $nature $SOAF_NOTIF_FN_ATTR)
		SOAF_NOTIF_RET=
		$FN $nature "$MSG" $PROG $HOST
		if [ -n "$SOAF_NOTIF_RET" ]
		then
			local LOG_MSG="Notif of nature [$nature] OK."
			soaf_log_debug "$LOG_MSG" $SOAF_NOTIF_LOG_NAME
		else
			local LOG_MSG="Notif of nature [$nature] KO."
			soaf_log_err "$LOG_MSG" $SOAF_NOTIF_LOG_NAME
		fi
	done
}
