################################################################################
################################################################################

### https://en.wikipedia.org/wiki/ANSI_escape_code

################################################################################
################################################################################

SOAF_CONSOLE_ESC="\x1B"

SOAF_CONSOLE_CTL_BOLD=1
SOAF_CONSOLE_CTL_ITALIC=3
SOAF_CONSOLE_CTL_UNDERLINE=4
SOAF_CONSOLE_CTL_BLINK=5

SOAF_CONSOLE_FG_BLACK=30
SOAF_CONSOLE_FG_RED=31
SOAF_CONSOLE_FG_GREEN=32
SOAF_CONSOLE_FG_YELLOW=33
SOAF_CONSOLE_FG_BLUE=34
SOAF_CONSOLE_FG_MAGENTA=35
SOAF_CONSOLE_FG_CYAN=36
SOAF_CONSOLE_FG_WHITE=37
SOAF_CONSOLE_FG_B_BLACK=90
SOAF_CONSOLE_FG_B_RED=91
SOAF_CONSOLE_FG_B_GREEN=92
SOAF_CONSOLE_FG_B_YELLOW=93
SOAF_CONSOLE_FG_B_BLUE=94
SOAF_CONSOLE_FG_B_MAGENTA=95
SOAF_CONSOLE_FG_B_CYAN=96
SOAF_CONSOLE_FG_B_WHITE=97

SOAF_CONSOLE_BG_BLACK=40
SOAF_CONSOLE_BG_RED=41
SOAF_CONSOLE_BG_GREEN=42
SOAF_CONSOLE_BG_YELLOW=43
SOAF_CONSOLE_BG_BLUE=44
SOAF_CONSOLE_BG_MAGENTA=45
SOAF_CONSOLE_BG_CYAN=46
SOAF_CONSOLE_FG_WHITE=47
SOAF_CONSOLE_BG_B_BLACK=100
SOAF_CONSOLE_BG_B_RED=101
SOAF_CONSOLE_BG_B_GREEN=102
SOAF_CONSOLE_BG_B_YELLOW=103
SOAF_CONSOLE_BG_B_BLUE=104
SOAF_CONSOLE_BG_B_MAGENTA=105
SOAF_CONSOLE_BG_B_CYAN=106
SOAF_CONSOLE_BG_B_WHITE=107

################################################################################
################################################################################

soaf_console_msg_ctl() {
	local MSG=$1
	local CTL_LIST=$2
	if [ -n "$SOAF_CONSOLE_NO_CTL" ]
	then
		SOAF_CONSOLE_RET=$MSG
	else
		local ESC=$SOAF_CONSOLE_ESC
		soaf_list_join "$CTL_LIST" ";"
		SOAF_CONSOLE_RET="$ESC[${SOAF_RET_LIST}m$MSG$ESC[0m"
	fi
}

soaf_console_filter_stdin() {
	if [ -z "$SOAF_CONSOLE_NO_CTL" ]
	then
		local ESC=$SOAF_CONSOLE_ESC
		sed -e "s/x1B\[/$ESC\[/g"
	else
		cat -
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
