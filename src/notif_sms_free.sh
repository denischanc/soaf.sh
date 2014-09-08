################################################################################
################################################################################

SOAF_NOTIF_SMS_FREE_NATURE="soaf.notif.sms.free"

SOAF_NOTIF_SMS_FREE_LOG_NAME="soaf.notif.sms.free"

################################################################################
################################################################################

### cfg : SOAF_NOTIF_SMS_FREE_USER
###       SOAF_NOTIF_SMS_FREE_PASS
###       SOAF_NOTIF_SMS_FREE_PROXY_USER
###       SOAF_NOTIF_SMS_FREE_PROXY_PASS
###       SOAF_NOTIF_SMS_FREE_PROXY_HOST
###       SOAF_NOTIF_SMS_FREE_PROXY_PORT
###       SOAF_NOTIF_SMS_FREE_CACERT_FILE

soaf_notif_sms_free_cfg() {
	soaf_cfg_set SOAF_NOTIF_SMS_FREE_URL \
		"https://smsapi.free-mobile.fr/sendmsg"
}

soaf_notif_sms_free_init() {
	soaf_create_notif_nature $SOAF_NOTIF_SMS_FREE_NATURE soaf_notif_sms_free
}

soaf_engine_add_cfg_fn soaf_notif_sms_free_cfg
soaf_engine_add_init_fn soaf_notif_sms_free_init

################################################################################
################################################################################

soaf_notif_sms_free_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_NOTIF_SMS_FREE_LOG_NAME $LOG_LEVEL
}

soaf_add_name_log_level_fn soaf_notif_sms_free_log_level

################################################################################
################################################################################

soaf_notif_sms_free() {
	local MSG=$1
	local PROG=$2
	local HOST=$3
	local USER=$SOAF_NOTIF_SMS_FREE_USER
	local PASS=$SOAF_NOTIF_SMS_FREE_PASS
	if [ -n "$USER" -a -n "$PASS" ]
	then
		local CURL_ARGS=
		if [ -n "$SOAF_NOTIF_SMS_FREE_PROXY_HOST" ]
		then
			local PROXY_USER=$SOAF_NOTIF_SMS_FREE_PROXY_USER
			local PROXY_PASS=$SOAF_NOTIF_SMS_FREE_PROXY_PASS
			local PROXY_HOST=$SOAF_NOTIF_SMS_FREE_PROXY_HOST
			local PROXY_PORT=$SOAF_NOTIF_SMS_FREE_PROXY_PORT
			local PROXY="$PROXY_USER:$PROXY_PASS@$PROXY_HOST:$PROXY_PORT"
			CURL_ARGS="$CURL_ARGS --proxy $PROXY"
		fi
		if [ -n "$SOAF_NOTIF_SMS_FREE_CACERT_FILE" ]
		then
			CURL_ARGS="$CURL_ARGS --cacert $SOAF_NOTIF_SMS_FREE_CACERT_FILE"
		else
			CURL_ARGS="$CURL_ARGS --insecure"
		fi
		CURL_ARGS="$CURL_ARGS --fail --get --silent --show-error"
		soaf_log_prep_cmd_out_err $SOAF_NOTIF_SMS_FREE_LOG_NAME
		MSG="[$HOST:$PROG] $MSG"
		curl $CURL_ARGS --data user=$USER --data pass=$PASS \
			--data-urlencode msg="$MSG" $SOAF_NOTIF_SMS_FREE_URL \
			> /dev/null 2> $SOAF_LOG_CMD_ERR_FILE
		[ $? -eq 0 ] && SOAF_NOTIF_RET="OK"
		soaf_log_cmd_err $SOAF_NOTIF_SMS_FREE_LOG_NAME
	fi
}
