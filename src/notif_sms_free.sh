################################################################################
################################################################################

SOAF_NOTIF_SMS_FREE_NATURE="soaf.notif.sms.free"

################################################################################
################################################################################

### cfg : SOAF_NOTIF_SMS_FREE_USER
###       SOAF_NOTIF_SMS_FREE_PASS

soaf_notif_sms_free_init() {
	soaf_create_notif_nature $SOAF_NOTIF_SMS_FREE_NATURE soaf_notif_sms_free
}

soaf_engine_add_init_fn soaf_notif_sms_free_init

################################################################################
################################################################################

soaf_notif_sms_free() {
	local MSG=$1
	local PROG=$2
	local USER=$SOAF_NOTIF_SMS_FREE_USER
	local PASS=$SOAF_NOTIF_SMS_FREE_PASS
	if [ -n "$USER" -a -n "$PASS" ]
	then
	fi
}
