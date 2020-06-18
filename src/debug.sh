################################################################################
################################################################################

soaf_debug_activate_() {
	if [ -z "$SOAF_DEBUG_ACTIVE" ]
	then
		SOAF_DEBUG_ACTIVE="OK"
		shopt -s extdebug
		trap soaf_debug_process_ DEBUG
	fi
}

################################################################################
################################################################################

soaf_debug_add_source_line_fn() {
	local SOURCE=$1
	local LINE=$2
	local FN=$3
	soaf_debug_activate_
	soaf_map_extend SOAF_DEBUG_FN_MAP $SOURCE-$LINE $FN
}

################################################################################
################################################################################

soaf_debug_main_fn() {
	local FN=$1
	soaf_debug_activate_
	SOAF_DEBUG_MAIN_FN=$FN
}

################################################################################
################################################################################

soaf_debug_ret_fn() {
	local FN=$1
	soaf_debug_activate_
	SOAF_DEBUG_RET_FN=$FN
}

################################################################################
################################################################################

soaf_debug_process_() {
	local SOURCE=${BASH_SOURCE[1]}
	local SOAF_RET
	soaf_map_get SOAF_DEBUG_SOURCE_BN $SOURCE
	if [ -z "$SOAF_RET" ]
	then
		local SOURCE_BN=$(basename $SOURCE)
		soaf_map_extend SOAF_DEBUG_SOURCE_BN $SOURCE $SOURCE_BN
		SOAF_RET=$SOURCE_BN
	fi
	soaf_map_get SOAF_DEBUG_FN_MAP $SOAF_RET-${BASH_LINENO[0]}
	$SOAF_RET
	$SOAF_DEBUG_MAIN_FN
	SOAF_DEBUG_RET=0
	$SOAF_DEBUG_RET_FN
	return $SOAF_DEBUG_RET
}

################################################################################
################################################################################

soaf_debug_stacktrace() {
	declare -i I=${1:-3}
	while [ $I -lt ${#FUNCNAME[@]} ]
	do
		local LINE
		[ $I -le 0 ] && LINE=$LINENO || LINE=${BASH_LINENO[$I - 1]}
		soaf_console_err "[${BASH_SOURCE[$I]}:$LINE:${FUNCNAME[$I]}]"
		I+=1
	done
}
