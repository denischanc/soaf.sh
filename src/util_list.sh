################################################################################
################################################################################

SOAF_POS_PRE="pre"
SOAF_POS_MAIN="main"
SOAF_POS_POST="post"

################################################################################
################################################################################

soaf_pmp_list_attr_() {
	local POS=$1
	case $POS in
		$SOAF_POS_PRE) SOAF_RET_LIST=soaf_pmp_pre_list;;
		$SOAF_POS_POST) SOAF_RET_LIST=soaf_pmp_post_list;;
		*) SOAF_RET_LIST=soaf_pmp_main_list;;
	esac
}

soaf_pmp_list_fill_w_array() {
	local POS=$1
	local LIST_VAR=$2
	local ARRAY_VAR=$3
	soaf_pmp_list_attr_ $POS
	soaf_map_w_array_cat $LIST_VAR $SOAF_RET_LIST $ARRAY_VAR
}

soaf_pmp_list_fill() {
	local POS=$1
	local LIST_VAR=$2
	local ELMT_LIST=$3
	local ELMT_ARRAY=($ELMT_LIST)
	soaf_pmp_list_fill_w_array "$POS" $LIST_VAR ELMT_ARRAY
}

soaf_pmp_list_cat_w_array() {
	local LIST_VAR=$1
	local RET_LIST pos
	for pos in $SOAF_POS_PRE $SOAF_POS_MAIN $SOAF_POS_POST
	do
		soaf_pmp_list_attr_ $pos
		soaf_map_w_array_get $LIST_VAR $SOAF_RET_LIST
		RET_LIST+=("${SOAF_RET[@]}")
	done
	SOAF_RET_LIST=("${RET_LIST[@]}")
}

soaf_pmp_list_cat() {
	local LIST_VAR=$1
	soaf_pmp_list_cat_w_array $LIST_VAR
	SOAF_RET_LIST=${SOAF_RET_LIST[*]}
}

################################################################################
################################################################################

soaf_list_found_w_array() {
	local ARRAY_VAR=$1
	local VAL2FND=$2
	eval local FND_VAL_A=\(\"\${$ARRAY_VAR[@]}\"\)
	local e
	for e in "${FND_VAL_A[@]}"
	do
		if [ "$e" = "$VAL2FND" ]
		then
			SOAF_RET_LIST="OK"
			return
		fi
	done
	SOAF_RET_LIST=
}

soaf_list_found() {
	local VAL_LIST=$1
	local VAL2FND=$2
	local VAL_ARRAY=($VAL_LIST)
	soaf_list_found_w_array VAL_ARRAY $VAL2FND
}

################################################################################
################################################################################

soaf_list_join_w_array() {
	local ARRAY_VAR=$1
	local SEP=${2:-|}
	local CTL_LIST=$3
	local RET_LIST=
	eval local JOIN_VAL_A=\(\"\${$ARRAY_VAR[@]}\"\)
	local e
	for e in "${JOIN_VAL_A[@]}"
	do
		if [ -n "$CTL_LIST" ]
		then
			soaf_console_msg_ctl "$e" "$CTL_LIST"
			e=$SOAF_CONSOLE_RET
		fi
		[ -z "$RET_LIST" ] && RET_LIST=$e || RET_LIST+="$SEP$e"
	done
	SOAF_RET_LIST=$RET_LIST
}

soaf_list_join() {
	local LIST=$1
	local SEP=$2
	local CTL_LIST=$3
	local _ARRAY=($LIST)
	soaf_list_join_w_array _ARRAY "$SEP" $CTL_LIST
}
