################################################################################
################################################################################

### https://en.wikipedia.org/wiki/ANSI_escape_code

################################################################################
################################################################################

readonly SOAF_CONSOLE_ESC="\x1B"

readonly SOAF_CONSOLE_CTL_BOLD=1
readonly SOAF_CONSOLE_CTL_ITALIC=3
readonly SOAF_CONSOLE_CTL_UNDERLINE=4
readonly SOAF_CONSOLE_CTL_BLINK=5

readonly SOAF_CONSOLE_FG_BLACK=30
readonly SOAF_CONSOLE_FG_RED=31
readonly SOAF_CONSOLE_FG_GREEN=32
readonly SOAF_CONSOLE_FG_YELLOW=33
readonly SOAF_CONSOLE_FG_BLUE=34
readonly SOAF_CONSOLE_FG_MAGENTA=35
readonly SOAF_CONSOLE_FG_CYAN=36
readonly SOAF_CONSOLE_FG_WHITE=37
readonly SOAF_CONSOLE_FG_B_BLACK=90
readonly SOAF_CONSOLE_FG_B_RED=91
readonly SOAF_CONSOLE_FG_B_GREEN=92
readonly SOAF_CONSOLE_FG_B_YELLOW=93
readonly SOAF_CONSOLE_FG_B_BLUE=94
readonly SOAF_CONSOLE_FG_B_MAGENTA=95
readonly SOAF_CONSOLE_FG_B_CYAN=96
readonly SOAF_CONSOLE_FG_B_WHITE=97

readonly SOAF_CONSOLE_BG_BLACK=40
readonly SOAF_CONSOLE_BG_RED=41
readonly SOAF_CONSOLE_BG_GREEN=42
readonly SOAF_CONSOLE_BG_YELLOW=43
readonly SOAF_CONSOLE_BG_BLUE=44
readonly SOAF_CONSOLE_BG_MAGENTA=45
readonly SOAF_CONSOLE_BG_CYAN=46
readonly SOAF_CONSOLE_BG_WHITE=47
readonly SOAF_CONSOLE_BG_B_BLACK=100
readonly SOAF_CONSOLE_BG_B_RED=101
readonly SOAF_CONSOLE_BG_B_GREEN=102
readonly SOAF_CONSOLE_BG_B_YELLOW=103
readonly SOAF_CONSOLE_BG_B_BLUE=104
readonly SOAF_CONSOLE_BG_B_MAGENTA=105
readonly SOAF_CONSOLE_BG_B_CYAN=106
readonly SOAF_CONSOLE_BG_B_WHITE=107

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

################################################################################
################################################################################

soaf_console_info() {
	local MSG=$1
	echo -e "$MSG"
}

soaf_console_err() {
	local MSG=$1
	echo -e "$MSG" >&2
}
