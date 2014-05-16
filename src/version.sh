################################################################################
################################################################################

soaf_info_add_var() {
	local VAR_LIST=$1
	SOAF_INFO_VAR_LIST="$SOAF_INFO_VAR_LIST $VAR_LIST"
}

################################################################################
################################################################################

SOAF_NAME="soaf.sh"
SOAF_VERSION="0.2.0_b_7"

soaf_info_add_var SOAF_VERSION

################################################################################
################################################################################

soaf_version() {
	local VER=$SOAF_NAME-$SOAF_VERSION
	local USER_VER_FN=$(soaf_map_get $SOAF_USER_MAP "VERSION_FN")
	if [ -n "$USER_VER_FN" ]
	then
		VER="$($USER_VER_FN) ($VER)"
	fi
	soaf_dis_txt "$VER"
}

################################################################################
################################################################################

soaf_info() {
	soaf_dis_var_list "$SOAF_INFO_VAR_LIST"
}
