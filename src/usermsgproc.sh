################################################################################
################################################################################

SOAF_USERMSGPROC_FN_ATTR="soaf_usermsgproc_fn"

SOAF_USERMSGPROC_TXT_ORG="TXT"
SOAF_USERMSGPROC_LOG_ORG="LOG"

################################################################################
################################################################################

soaf_usermsgproc_init_() {
	if [ -n "$SOAF_USERMSG_DEBUG" ]
	then
		soaf_all_use_usermsgproc
		soaf_create_usermsgproc_debug
	fi
}

soaf_create_module soaf.core.usermsgproc $SOAF_VERSION "" \
	"" soaf_usermsgproc_init_

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

soaf_usermsgproc_debug_() {
	local ORG=$1
	local MSG=$2
	case $ORG in
		$SOAF_USERMSGPROC_TXT_ORG) local COLOR_ORG=$SOAF_CONSOLE_FG_GREEN;;
		$SOAF_USERMSGPROC_LOG_ORG) local COLOR_ORG=$SOAF_CONSOLE_FG_CYAN;;
		*) local COLOR_ORG=$SOAF_CONSOLE_FG_MAGENTA;;
	esac
	soaf_console_msg_ctl $ORG "$COLOR_ORG $SOAF_CONSOLE_CTL_BOLD"
	soaf_console_info "[[$SOAF_CONSOLE_RET]] $MSG"
}

soaf_create_usermsgproc_debug() {
	soaf_create_usermsgproc_nature "soaf.usermsgproc.debug" \
		soaf_usermsgproc_debug_
}

################################################################################
################################################################################

soaf_usermsgproc_add_use_fn() {
	local FN_LIST=$1
	local POS=${2:-$SOAF_POS_MAIN}
	soaf_pmp_list_fill $POS SOAF_USERMSGPROC_USE_FN "$FN_LIST"
}

soaf_all_use_usermsgproc() {
	soaf_pmp_list_cat SOAF_USERMSGPROC_USE_FN
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
		soaf_map_get_var $USED_NATURE $SOAF_USERMSGPROC_FN_ATTR
		[ -n "$SOAF_RET" ] && $SOAF_RET $ORG "$MSG"
	fi
}
