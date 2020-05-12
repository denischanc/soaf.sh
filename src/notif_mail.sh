################################################################################
################################################################################

readonly SOAF_NOTIF_MAIL_LOG_NAME="soaf.notif.mail"

readonly SOAF_NOTIF_MAIL_TO_ADDR_ATTR="soaf_notif_mail_to_addr"

################################################################################
################################################################################

soaf_notif_mail_static_() {
	soaf_log_add_log_level_fn soaf_notif_mail_log_level
}

soaf_create_module soaf.extra.notif.mail $SOAF_VERSION soaf_notif_mail_static_

################################################################################
################################################################################

soaf_notif_mail_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_NOTIF_MAIL_LOG_NAME $LOG_LEVEL
}

################################################################################
################################################################################

soaf_create_notif_mail_nature() {
	local NATURE=$1
	local TO_ADDR=$2
	local NB_TRY=$3
	soaf_create_notif_nature $NATURE soaf_notif_mail_ $NB_TRY
	soaf_map_extend $NATURE $SOAF_NOTIF_MAIL_TO_ADDR_ATTR "$TO_ADDR"
}

################################################################################
################################################################################

soaf_notif_mail_() {
	local NATURE=$1
	local MSG=$2
	local PROG=$3
	local HOST=$4
	local SUBJ="[$HOST:$PROG] Notification"
	soaf_map_get $NATURE $SOAF_NOTIF_MAIL_TO_ADDR_ATTR
	local CMD="echo \"$MSG\" | mail -s \"$SUBJ\" \"$SOAF_RET\""
	soaf_log_prep_cmd_err "$CMD" $SOAF_NOTIF_MAIL_LOG_NAME
	eval "$SOAF_LOG_RET"
	local RET=$?
	soaf_log_cmd_err $SOAF_NOTIF_MAIL_LOG_NAME
	[ $RET -eq 0 ] && SOAF_NOTIF_RET="OK"
}
