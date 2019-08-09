################################################################################
################################################################################

SOAF_USERMSGPROC_FN_ATTR="soaf_usermsgproc_fn"

SOAF_USERMSGPROC_TXT_ORG="TXT"
SOAF_USERMSGPROC_LOG_ORG="LOG"

################################################################################
################################################################################

soaf_usermsgproc_init() {
	if [ -n "$SOAF_USERMSG_DEBUG" ]
	then
		soaf_all_use_usermsgproc
		soaf_create_usermsgproc_debug
	fi
}

soaf_define_add_this_init_fn soaf_usermsgproc_init

################################################################################
################################################################################

soaf_create_usermsgproc_nature() {
	local NATURE=$1
	local FN=$2
	SOAF_USERMSGPROC_USED_NATURE=$NATURE
	soaf_map_extend $NATURE $SOAF_USERMSGPROC_FN_ATTR $FN
}

################################################################################
################################################################################

soaf_usermsgproc_debug() {
	local ORG=$1
	local MSG=$2
	case $ORG in
	$SOAF_USERMSGPROC_TXT_ORG) local COLOR_ORG=32; local COLOR_MSG=42;;
	$SOAF_USERMSGPROC_LOG_ORG) local COLOR_ORG=34; local COLOR_MSG=44;;
	*) local COLOR_ORG=36; local COLOR_MSG=46;;
	esac
	soaf_console_msg_color $ORG $COLOR_ORG
	local END_MSG="[$SOAF_CONSOLE_RET]"
	soaf_console_msg_color "$MSG" $COLOR_MSG
	END_MSG="$END_MSG$SOAF_CONSOLE_RET"
	soaf_console_info "$END_MSG"
}

soaf_create_usermsgproc_debug() {
	soaf_create_usermsgproc_nature "soaf.usermsgproc.debug" \
		soaf_usermsgproc_debug
}

################################################################################
################################################################################

soaf_all_use_usermsgproc() {
	soaf_pmp_list_cat SOAF_USE_USERMSGPROC_FN
	local fn
	for fn in $SOAF_RET_LIST
	do
		$fn
	done
}

################################################################################
################################################################################

soaf_usermsgproc__() {
	local ORG=$1
	local MSG=$2
	local USED_NATURE=$SOAF_USERMSGPROC_USED_NATURE
	if [ -n "$USED_NATURE" ]
	then
		local FN
		soaf_map_get_var FN $USED_NATURE $SOAF_USERMSGPROC_FN_ATTR
		[ -n "$FN" ] && $FN $ORG "$MSG"
	fi
}
