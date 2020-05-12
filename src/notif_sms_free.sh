################################################################################
################################################################################

readonly SOAF_NOTIF_SMS_FREE_LOG_NAME="soaf.notif.sms.free"

readonly SOAF_NOTIF_SMS_FREE_ACCOUNT_ATTR="soaf_notif_sms_free_account"
readonly SOAF_NOTIF_SMS_FREE_PROXY_NATURE_ATTR="soaf_notif_sms_free_proxy"
readonly SOAF_NOTIF_SMS_FREE_CACERT_FILE_ATTR="soaf_notif_sms_free_cacert_file"

################################################################################
################################################################################

soaf_notif_sms_free_static_() {
	soaf_log_add_log_level_fn soaf_notif_sms_free_log_level
}

soaf_notif_sms_free_cfg_() {
	SOAF_NOTIF_SMS_FREE_URL="https://smsapi.free-mobile.fr/sendmsg"
	SOAF_NOTIF_SMS_FREE_CURL_ARGS_EXT="--ipv4"
}

soaf_create_module soaf.extra.notif.sms_free $SOAF_VERSION \
	soaf_notif_sms_free_static_ soaf_notif_sms_free_cfg_

################################################################################
################################################################################

soaf_notif_sms_free_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_NOTIF_SMS_FREE_LOG_NAME $LOG_LEVEL
}

################################################################################
################################################################################

soaf_create_notif_sms_free_nature() {
	local NATURE=$1
	local ACCOUNT=$2
	local PROXY_NATURE=$3
	local CACERT_FILE=$4
	local NB_TRY=$5
	soaf_create_notif_nature $NATURE soaf_notif_sms_free_ $NB_TRY
	soaf_map_extend $NATURE $SOAF_NOTIF_SMS_FREE_ACCOUNT_ATTR $ACCOUNT
	soaf_map_extend $NATURE $SOAF_NOTIF_SMS_FREE_PROXY_NATURE_ATTR \
		$PROXY_NATURE
	soaf_map_extend $NATURE $SOAF_NOTIF_SMS_FREE_CACERT_FILE_ATTR \
		$CACERT_FILE
}

################################################################################
################################################################################

soaf_notif_sms_free_() {
	local NATURE=$1
	local MSG=$2
	local PROG=$3
	local HOST=$4
	soaf_map_get $NATURE $SOAF_NOTIF_SMS_FREE_ACCOUNT_ATTR
	local ACCOUNT=$SOAF_RET
	soaf_net_account_login ${ACCOUNT:-unknown}
	local USER=$SOAF_NET_RET
	soaf_net_account_passwd ${ACCOUNT:-unknown}
	local PASS=$SOAF_NET_RET
	if [ -n "$USER" -a -n "$PASS" ]
	then
		local CURL_ARGS=
		soaf_map_get $NATURE $SOAF_NOTIF_SMS_FREE_PROXY_NATURE_ATTR
		local PROXY_NATURE=$SOAF_RET
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
			CURL_ARGS+=" --proxy $PROXY"
		fi
		soaf_map_get $NATURE $SOAF_NOTIF_SMS_FREE_CACERT_FILE_ATTR
		local CACERT_FILE=$SOAF_RET
		if [ -n "$CACERT_FILE" ]
		then
			CURL_ARGS+=" --cacert $CACERT_FILE"
		else
			CURL_ARGS+=" --insecure"
		fi
		soaf_log_level $SOAF_NOTIF_SMS_FREE_LOG_NAME
		if [ "$SOAF_LOG_RET" = "$SOAF_LOG_DEBUG" ]
		then
			CURL_ARGS+=" --verbose"
		else
			CURL_ARGS+=" --silent --show-error"
		fi
		CURL_ARGS+=" --fail --get $SOAF_NOTIF_SMS_FREE_CURL_ARGS_EXT"
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
