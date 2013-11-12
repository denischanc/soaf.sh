################################################################################
################################################################################

soaf_cfg_set() {
	local VAR="$1"
	local VAL="$2"
	eval local PREV_VAL=\"\$$VAR\"
	[ -z "$PREV_VAL" ] && eval $VAR=\"$VAL\"
}

################################################################################
################################################################################

soaf_cfg_set SOAF_ROLL_SIZE "4"
soaf_cfg_set SOAF_ROLL_FILE_SIZE "100000"

soaf_cfg_set SOAF_LOG_LEVEL "$SOAF_LOG_INFO"

soaf_cfg_set SOAF_ACTION "usage"


GENTOP_ACTION_EXT_LIST=""

GENTOP_TASK=""


GENTOP_LOG_DIR="/var/log/gentop"

GENTOP_SYNC_INTERVAL=7

GENTOP_LOG_LEVEL="INFO "

GENTOP_PORTAGE_DIR="/usr/portage"

GENTOP_ROLL_FILE_SIZE="100000"

GENTOP_DAEMON_INACTIVE=""

################################################################################
################################################################################

SOAF_CFG_GLOB="/etc/soaf/soaf.sh"
SOAF_CFG_HOME="$HOME/.soaf/soaf.sh"
SOAF_CFG_LIST="$SOAF_CFG_GLOB $SOAF_CFG_HOME $SOAF_CFG_LIST_EXT"

SOAF_USAGE_VAR_LIST="ACTION $SOAF_USAGE_VAR_LIST_EXT"

################################################################################
################################################################################

soaf_parse_arg() {
	local ARG="$1"
	if [ -n "$(echo $ARG | grep =)" ]
	then
		local VAR=$(echo =$ARG= | awk -F= '{print $2}')
		local VAL=$(echo =$ARG= | awk -F= '{print $3}')
		if [ -n "$VAR" ]
		then
			eval $VAR=\"$VAL\"
		fi
	fi
}

################################################################################
################################################################################

for cfg in $SOAF_CFG_LIST
do
	[ -f $cfg ] && . $cfg
done

while [ $# -ge 1 ]
do
	soaf_parse_arg "$1"
	shift
done

for var in $SOAF_USAGE_VAR_LIST
do
	eval VAL=\"\$$var\"
	if [ -n "$VAL" ]
	then
		eval SOAF_$var=\"$VAL\"
	fi
done
