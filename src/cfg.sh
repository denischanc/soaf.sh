################################################################################
################################################################################

SOAF_CFG_GLOB="/etc/soaf/soaf.sh"
SOAF_CFG_HOME="$HOME/.soaf/soaf.sh"
SOAF_CFG_LIST="$SOAF_CFG_GLOB $SOAF_CFG_HOME $SOAF_CFG_LIST_EXT"

SOAF_USAGE_VAR_LIST="ACTION"

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

soaf_cfg_user() {
	local VAR_PRE="$1"
	local USAGE_VAR_LIST="$2"
	SOAF_USER_VAR_PRE="$VAR_PRE"
	SOAF_USER_USAGE_VAR_LIST="$USAGE_VAR_LIST"
}

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

soaf_mng_glob_var_loop() {
	local VAR_PRE="$1"
	local LIST="$2"
	for var in $LIST
	do
		eval VAL=\"\$$var\"
		[ -n "$VAL" ] && eval ${VAR_PRE}_$var=\"$VAL\"
	done
}

soaf_mng_glob_var() {
	soaf_mng_glob_var_loop "SOAF" "$SOAF_USAGE_VAR_LIST"
	soaf_mng_glob_var_loop "$SOAF_USER_VAR_PRE" "$SOAF_USER_USAGE_VAR_LIST"
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
