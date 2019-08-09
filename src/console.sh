################################################################################
################################################################################

### https://en.wikipedia.org/wiki/ANSI_escape_code

################################################################################
################################################################################

SOAF_CONSOLE_ESC="\x1B"

################################################################################
################################################################################

soaf_console_msg_color() {
	local MSG=$1
	local COLOR=$2
	if [ -n "$SOAF_CONSOLE_NO_COLOR" ]
	then
		SOAF_CONSOLE_RET=$MSG
	else
		local ESC=$SOAF_CONSOLE_ESC
		SOAF_CONSOLE_RET="$ESC[${COLOR}m$MSG$ESC[0m"
	fi
}

soaf_console_filter_stdin() {
	if [ -z "$SOAF_CONSOLE_NO_COLOR" ]
	then
		local ESC=$SOAF_CONSOLE_ESC
		sed -e "s/x1B\[/$ESC\[/g"
	fi
}

################################################################################
################################################################################

soaf_console_info() {
	local MSG=$1
	printf "$MSG\n"
}

soaf_console_err() {
	local MSG=$1
	printf "$MSG\n" >&2
}
