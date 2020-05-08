################################################################################
################################################################################

SOAF_NET_CFG_ACCOUNT_LOGIN_ATTR="soaf_net_cfg_account_login"
SOAF_NET_CFG_ACCOUNT_PASSWD_ATTR="soaf_net_cfg_account_passwd"

SOAF_NET_CFG_ENDPOINT_HOST_ATTR="soaf_net_cfg_endpoint_host"
SOAF_NET_CFG_ENDPOINT_PORT_ATTR="soaf_net_cfg_endpoint_port"

SOAF_NET_CFG_PROXY_ENDPOINT_ATTR="soaf_net_cfg_proxy_endpoint"
SOAF_NET_CFG_PROXY_ACCOUNT_ATTR="soaf_net_cfg_proxy_account"

################################################################################
################################################################################

soaf_create_net_account() {
	local ACCOUNT=$1
	local LOGIN=$2
	local PASSWD=$3
	soaf_map_extend $ACCOUNT $SOAF_NET_CFG_ACCOUNT_LOGIN_ATTR $LOGIN
	soaf_map_extend $ACCOUNT $SOAF_NET_CFG_ACCOUNT_PASSWD_ATTR $PASSWD
}

soaf_net_account_login() {
	local ACCOUNT=$1
	soaf_map_get_var $ACCOUNT $SOAF_NET_CFG_ACCOUNT_LOGIN_ATTR
	SOAF_NET_RET=$SOAF_RET
}

soaf_net_account_passwd() {
	local ACCOUNT=$1
	soaf_map_get_var $ACCOUNT $SOAF_NET_CFG_ACCOUNT_PASSWD_ATTR
	SOAF_NET_RET=$SOAF_RET
}

################################################################################
################################################################################

soaf_create_net_endpoint() {
	local ENDPOINT=$1
	local HOST=$2
	local PORT=$3
	soaf_map_extend $ENDPOINT $SOAF_NET_CFG_ENDPOINT_HOST_ATTR $HOST
	soaf_map_extend $ENDPOINT $SOAF_NET_CFG_ENDPOINT_PORT_ATTR $PORT
}

soaf_net_endpoint_host() {
	local ENDPOINT=$1
	soaf_map_get_var $ENDPOINT $SOAF_NET_CFG_ENDPOINT_HOST_ATTR
	SOAF_NET_RET=$SOAF_RET
}

soaf_net_endpoint_port() {
	local ENDPOINT=$1
	soaf_map_get_var $ENDPOINT $SOAF_NET_CFG_ENDPOINT_PORT_ATTR
	SOAF_NET_RET=$SOAF_RET
}

################################################################################
################################################################################

soaf_create_net_cfg_proxy_nature() {
	local NATURE=$1
	local ENDPOINT=$2
	local ACCOUNT=$3
	soaf_map_extend $NATURE $SOAF_NET_CFG_PROXY_ENDPOINT_ATTR $ENDPOINT
	soaf_map_extend $NATURE $SOAF_NET_CFG_PROXY_ACCOUNT_ATTR $ACCOUNT
}

soaf_net_cfg_proxy_host() {
	local NATURE=$1
	soaf_map_get_var $NATURE $SOAF_NET_CFG_PROXY_ENDPOINT_ATTR
	soaf_net_endpoint_host $SOAF_RET
}

soaf_net_cfg_proxy_port() {
	local NATURE=$1
	soaf_map_get_var $NATURE $SOAF_NET_CFG_PROXY_ENDPOINT_ATTR
	soaf_net_endpoint_port $SOAF_RET
}

soaf_net_cfg_proxy_login() {
	local NATURE=$1
	soaf_map_get_var $NATURE $SOAF_NET_CFG_PROXY_ACCOUNT_ATTR
	soaf_net_account_login $SOAF_RET
}

soaf_net_cfg_proxy_passwd() {
	local NATURE=$1
	soaf_map_get_var $NATURE $SOAF_NET_CFG_PROXY_ACCOUNT_ATTR
	soaf_net_account_passwd $SOAF_RET
}
