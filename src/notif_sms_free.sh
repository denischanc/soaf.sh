################################################################################
################################################################################

SOAF_NOTIF_SMS_FREE_LOG_NAME="soaf.notif.sms.free"

SOAF_NOTIF_SMS_FREE_ACCOUNT_NATURE_ATTR="soaf_notif_sms_free_account_nature"
SOAF_NOTIF_SMS_FREE_PROXY_NATURE_ATTR="soaf_notif_sms_free_proxy_nature"
SOAF_NOTIF_SMS_FREE_CACERT_FILE_ATTR="soaf_notif_sms_free_cacert_file"

################################################################################
################################################################################

soaf_notif_sms_free_cfg() {
	soaf_cfg_set SOAF_NOTIF_SMS_FREE_URL \
		"https://smsapi.free-mobile.fr/sendmsg"
}

soaf_engine_add_cfg_fn soaf_notif_sms_free_cfg

################################################################################
################################################################################

soaf_notif_sms_free_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_NOTIF_SMS_FREE_LOG_NAME $LOG_LEVEL
}

soaf_add_name_log_level_fn soaf_notif_sms_free_log_level

################################################################################
################################################################################

soaf_create_notif_sms_free_nature() {
	local NATURE=$1
	local ACCOUNT_NATURE=$2
	local PROXY_NATURE=$3
	local CACERT_FILE=$4
	soaf_create_notif_nature $NATURE soaf_notif_sms_free
	soaf_map_extend $NATURE $SOAF_NOTIF_SMS_FREE_ACCOUNT_NATURE_ATTR \
		$ACCOUNT_NATURE
	soaf_map_extend $NATURE $SOAF_NOTIF_SMS_FREE_PROXY_NATURE_ATTR \
		$PROXY_NATURE
	soaf_map_extend $NATURE $SOAF_NOTIF_SMS_FREE_CACERT_FILE_ATTR \
		$CACERT_FILE
}

################################################################################
################################################################################

soaf_notif_sms_free() {
	local NATURE=$1
	local MSG=$2
	local PROG=$3
	local HOST=$4
	local ACCOUNT_NATURE=$(soaf_map_get $NATURE \
		$SOAF_NOTIF_SMS_FREE_ACCOUNT_NATURE_ATTR)
	local USER=$(soaf_net_account_login ${ACCOUNT_NATURE:-unknown})
	local PASS=$(soaf_net_account_passwd ${ACCOUNT_NATURE:-unknown})
	if [ -n "$USER" -a -n "$PASS" ]
	then
		local CURL_ARGS=
		local PROXY_NATURE=$(soaf_map_get $NATURE \
			$SOAF_NOTIF_SMS_FREE_PROXY_NATURE_ATTR)
		if [ -n "$PROXY_NATURE" ]
		then
			local PROXY_USER=$(soaf_net_cfg_proxy_login $PROXY_NATURE)
			local PROXY_PASS=$(soaf_net_cfg_proxy_passwd $PROXY_NATURE)
			local PROXY_HOST=$(soaf_net_cfg_proxy_host $PROXY_NATURE)
			local PROXY_PORT=$(soaf_net_cfg_proxy_port $PROXY_NATURE)
			local PROXY="$PROXY_USER:$PROXY_PASS@$PROXY_HOST:$PROXY_PORT"
			CURL_ARGS="$CURL_ARGS --proxy $PROXY"
		fi
		local CACERT_FILE=$(soaf_map_get $NATURE \
			$SOAF_NOTIF_SMS_FREE_CACERT_FILE_ATTR)
		if [ -n "$CACERT_FILE" ]
		then
			CURL_ARGS="$CURL_ARGS --cacert $CACERT_FILE"
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
