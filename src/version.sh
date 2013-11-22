################################################################################
################################################################################

soaf_info_add_var() {
	while [ $# -ge 1 ]
	do
		SOAF_INFO_VAR_LIST="$SOAF_INFO_VAR_LIST $1"
		shift
	done
}

################################################################################
################################################################################

SOAF_NAME="soaf"
SOAF_VERSION="0.1.0"

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
	for var in $SOAF_INFO_VAR_LIST
	do
		eval local VAL=\$$var
		soaf_dis_txt "$var = [$VAL]"
	done
}
