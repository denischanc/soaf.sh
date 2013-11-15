################################################################################
################################################################################

SOAF_CFG_GLOB="/etc/soaf/soaf.sh"
SOAF_CFG_HOME="$HOME/.soaf/soaf.sh"
SOAF_CFG_LIST="$SOAF_CFG_GLOB $SOAF_CFG_HOME $SOAF_CFG_LIST_EXT"

SOAF_USAGE_VAR_LIST="ACTION"

soaf_info_add_var SOAF_CFG_LIST

################################################################################
################################################################################

soaf_cfg_set() {
	local VAR="$1"
	local VAL="$2"
	eval local PREV_VAL=\"\$$VAR\"
	[ -z "$PREV_VAL" ] && eval $VAR=\"\$VAL\"
}

################################################################################
################################################################################

soaf_parse_arg() {
	local ARG="$1"
	if [ -n "$(echo $ARG | grep =)" ]
	then
		local VAR_TMP=$(echo "$ARG" | awk -F= '{print $1}')
		local VAL_TMP=$(echo "$ARG" | awk -F= '{print $2}')
		if [ -n "$VAR_TMP" ]
		then
			eval $VAR_TMP=\"\$VAL_TMP\"
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
		eval local VAL_TMP=\"\$$var\"
		[ -n "$VAL_TMP" ] && eval ${VAR_PRE}_$var=\"\$VAL_TMP\"
	done
}

soaf_mng_glob_var() {
	soaf_mng_glob_var_loop "SOAF" "$SOAF_USAGE_VAR_LIST"
	local VAR_PRE=$(soaf_map_get $SOAF_USER_MAP "VAR_PRE")
	local USAGE_VAR_LIST=$(soaf_map_get $SOAF_USER_MAP "USAGE_VAR_LIST")
	soaf_mng_glob_var_loop "$VAR_PRE" "$USAGE_VAR_LIST"
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
