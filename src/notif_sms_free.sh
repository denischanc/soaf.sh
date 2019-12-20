################################################################################
################################################################################

SOAF_NOTIF_SMS_FREE_LOG_NAME="soaf.notif.sms.free"

SOAF_NOTIF_SMS_FREE_ACCOUNT_ATTR="soaf_notif_sms_free_account"
SOAF_NOTIF_SMS_FREE_PROXY_NATURE_ATTR="soaf_notif_sms_free_proxy_nature"
SOAF_NOTIF_SMS_FREE_CACERT_FILE_ATTR="soaf_notif_sms_free_cacert_file"

################################################################################
################################################################################

soaf_notif_sms_free_cfg() {
	SOAF_NOTIF_SMS_FREE_URL="https://smsapi.free-mobile.fr/sendmsg"
	SOAF_NOTIF_SMS_FREE_CURL_ARGS_EXT="--ipv4"
}

soaf_create_module soaf.extra.notif_sms_free $SOAF_VERSION \
	soaf_notif_sms_free_cfg

################################################################################
################################################################################

soaf_notif_sms_free_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_NOTIF_SMS_FREE_LOG_NAME $LOG_LEVEL
}

soaf_define_add_name_log_level_fn soaf_notif_sms_free_log_level

################################################################################
################################################################################

soaf_create_notif_sms_free_nature() {
	local NATURE=$1
	local ACCOUNT=$2
	local PROXY_NATURE=$3
	local CACERT_FILE=$4
	soaf_create_notif_nature $NATURE soaf_notif_sms_free
	soaf_map_extend $NATURE $SOAF_NOTIF_SMS_FREE_ACCOUNT_ATTR $ACCOUNT
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
	local ACCOUNT
	soaf_map_get_var ACCOUNT $NATURE $SOAF_NOTIF_SMS_FREE_ACCOUNT_ATTR
	soaf_net_account_login ${ACCOUNT:-unknown}
	local USER=$SOAF_NET_RET
	soaf_net_account_passwd ${ACCOUNT:-unknown}
	local PASS=$SOAF_NET_RET
	if [ -n "$USER" -a -n "$PASS" ]
	then
		local CURL_ARGS=
		local PROXY_NATURE
		soaf_map_get_var PROXY_NATURE $NATURE \
			$SOAF_NOTIF_SMS_FREE_PROXY_NATURE_ATTR
		if [ -n "$PROXY_NATURE" ]
		then
			soaf_net_cfg_proxy_login $PROXY_NATURE
			local PROXY_USER=$SOAF_NET_RET
			soaf_net_cfg_proxy_passwd $PROXY_NATURE
			local PROXY_PASS=$SOAF_NET_RET
			soaf_net_cfg_proxy_host $PROXY_NATURE
			local PROXY_HOST=$SOAF_NET_RET
			soaf_net_cfg_proxy_port $PROXY_NATURE
			local PROXY_PORT=$SOAF_NET_RET
			local PROXY="$PROXY_USER:$PROXY_PASS@$PROXY_HOST:$PROXY_PORT"
			CURL_ARGS="$CURL_ARGS --proxy $PROXY"
		fi
		local CACERT_FILE
		soaf_map_get_var CACERT_FILE $NATURE \
			$SOAF_NOTIF_SMS_FREE_CACERT_FILE_ATTR
		if [ -n "$CACERT_FILE" ]
		then
			CURL_ARGS="$CURL_ARGS --cacert $CACERT_FILE"
		else
			CURL_ARGS="$CURL_ARGS --insecure"
		fi
		soaf_log_level $SOAF_NOTIF_SMS_FREE_LOG_NAME
		if [ "$SOAF_LOG_RET" = "$SOAF_LOG_DEBUG" ]
		then
			CURL_ARGS="$CURL_ARGS --verbose"
		else
			CURL_ARGS="$CURL_ARGS --silent --show-error"
		fi
		CURL_ARGS="$CURL_ARGS --fail --get $SOAF_NOTIF_SMS_FREE_CURL_ARGS_EXT"
		MSG="[$HOST:$PROG] $MSG"
		### USER and PASS must not be logged
		soaf_log_prep_cmd_err "curl $CURL_ARGS \
			--data user=$USER --data pass=$PASS --data-urlencode msg=\"$MSG\" \
			$SOAF_NOTIF_SMS_FREE_URL > /dev/null" $SOAF_NOTIF_SMS_FREE_LOG_NAME
		eval "$SOAF_LOG_RET"
		if [ $? -eq 0 ]
		then
			SOAF_NOTIF_RET="OK"
			soaf_log_cmd_err $SOAF_NOTIF_SMS_FREE_LOG_NAME $SOAF_LOG_DEBUG
		else
			soaf_log_cmd_err $SOAF_NOTIF_SMS_FREE_LOG_NAME
		fi
	fi
}
