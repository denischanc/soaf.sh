################################################################################
################################################################################

SOAF_NAME="soaf.sh"
SOAF_VERSION="0.2.0"

SOAF_VERSION_ACTION="version"

################################################################################
################################################################################

soaf_version_init() {
	soaf_info_add_var SOAF_VERSION
}

soaf_engine_add_init_fn soaf_version_init

################################################################################
################################################################################

soaf_version() {
	local USER_NATURE=$1
	local NAMEVER=$SOAF_NAME-$SOAF_VERSION
	local USER_VER=$(soaf_map_get $USER_NATURE $SOAF_USER_VERSION_ATTR)
	local USER_NAMEVER=$SOAF_USER_NAME-$USER_VER
	if [ -n "$USER_NAMEVER" ]
	then
		NAMEVER="$USER_NAMEVER ($NAMEVER)"
	fi
	soaf_dis_txt "$NAMEVER"
}
