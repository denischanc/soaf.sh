################################################################################
################################################################################

SOAF_NET_CFG_ACCOUNT_LOGIN_ATTR="soaf_net_cfg_account_login"
SOAF_NET_CFG_ACCOUNT_PASSWD_ATTR="soaf_net_cfg_account_passwd"

SOAF_NET_CFG_ENDPOINT_HOST_ATTR="soaf_net_cfg_endpoint_host"
SOAF_NET_CFG_ENDPOINT_PORT_ATTR="soaf_net_cfg_endpoint_port"

SOAF_NET_CFG_PROXY_ENDPOINT_NATURE_ATTR="soaf_net_cfg_proxy_endpoint_nature"
SOAF_NET_CFG_PROXY_ACCOUNT_NATURE_ATTR="soaf_net_cfg_proxy_account_nature"

################################################################################
################################################################################

soaf_create_net_account() {
	local NATURE=$1
	local LOGIN=$2
	local PASSWD=$3
	soaf_map_extend $NATURE $SOAF_NET_CFG_ACCOUNT_LOGIN_ATTR $LOGIN
	soaf_map_extend $NATURE $SOAF_NET_CFG_ACCOUNT_PASSWD_ATTR $PASSWD
}

soaf_net_account_login() {
	local NATURE=$1
	soaf_map_get $NATURE $SOAF_NET_CFG_ACCOUNT_LOGIN_ATTR
}

soaf_net_account_passwd() {
	local NATURE=$1
	soaf_map_get $NATURE $SOAF_NET_CFG_ACCOUNT_PASSWD_ATTR
}

################################################################################
################################################################################

soaf_create_net_endpoint() {
	local NATURE=$1
	local HOST=$2
	local PORT=$3
	soaf_map_extend $NATURE $SOAF_NET_CFG_ENDPOINT_HOST_ATTR $HOST
	soaf_map_extend $NATURE $SOAF_NET_CFG_ENDPOINT_PORT_ATTR $PORT
}

soaf_net_endpoint_host() {
	local NATURE=$1
	soaf_map_get $NATURE $SOAF_NET_CFG_ENDPOINT_HOST_ATTR
}

soaf_net_endpoint_port() {
	local NATURE=$1
	soaf_map_get $NATURE $SOAF_NET_CFG_ENDPOINT_PORT_ATTR
}

################################################################################
################################################################################

soaf_create_net_cfg_proxy_nature() {
	local NATURE=$1
	local ENDPOINT_NATURE=$2
	local ACCOUNT_NATURE=$3
	soaf_map_extend $NATURE $SOAF_NET_CFG_PROXY_ENDPOINT_NATURE_ATTR \
		$ENDPOINT_NATURE
	soaf_map_extend $NATURE $SOAF_NET_CFG_PROXY_ACCOUNT_NATURE_ATTR \
		$ACCOUNT_NATURE
}

soaf_net_cfg_proxy_host() {
	local NATURE=$1
	local ENDPOINT_NATURE=$(soaf_map_get $NATURE \
		$SOAF_NET_CFG_PROXY_ENDPOINT_NATURE_ATTR)
	soaf_net_endpoint_host $ENDPOINT_NATURE
}

soaf_net_cfg_proxy_port() {
	local NATURE=$1
	local ENDPOINT_NATURE=$(soaf_map_get $NATURE \
		$SOAF_NET_CFG_PROXY_ENDPOINT_NATURE_ATTR)
	soaf_net_endpoint_port $ENDPOINT_NATURE
}

soaf_net_cfg_proxy_login() {
	local NATURE=$1
	local ACCOUNT_NATURE=$(soaf_map_get $NATURE \
		$SOAF_NET_CFG_PROXY_ACCOUNT_NATURE_ATTR)
	soaf_net_account_login $ACCOUNT_NATURE
}

soaf_net_cfg_proxy_passwd() {
	local NATURE=$1
	local ACCOUNT_NATURE=$(soaf_map_get $NATURE \
		$SOAF_NET_CFG_PROXY_ACCOUNT_NATURE_ATTR)
	soaf_net_account_passwd $ACCOUNT_NATURE
}
