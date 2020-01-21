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

soaf_pmp_list_fill() {
	local POS=$1
	local LIST_VAR=$2
	local ELMT_LIST=$3
	soaf_pmp_list_attr_ $POS
	soaf_map_cat $LIST_VAR $SOAF_RET_LIST "$ELMT_LIST"
}

soaf_pmp_list_cat() {
	local LIST_VAR=$1
	local RET_LIST pos VAL_PART
	for pos in $SOAF_POS_PRE $SOAF_POS_MAIN $SOAF_POS_POST
	do
		soaf_pmp_list_attr_ $pos
		soaf_map_get_var VAL_PART $LIST_VAR $SOAF_RET_LIST
		RET_LIST="$RET_LIST$VAL_PART"
	done
	SOAF_RET_LIST=$RET_LIST
}

################################################################################
################################################################################

soaf_list_found() {
	local VAL_LIST=$1
	local VAL2FND=$2
	local SEP=${3:- }
	if [ -z "$VAL2FND" -o -z "$VAL_LIST" ]
	then
		SOAF_RET_LIST=
	else
		SOAF_RET_LIST=$(echo "$SEP$VAL_LIST$SEP" | grep "$SEP$VAL2FND$SEP")
	fi
}

################################################################################
################################################################################

soaf_list_join() {
	local LIST=$1
	local SEP=${2:-|}
	local CTL_LIST=$3
	local RET_LIST=
	local e
	for e in $LIST
	do
		if [ -n "$CTL_LIST" ]
		then
			soaf_console_msg_ctl "$e" "$CTL_LIST"
			e=$SOAF_CONSOLE_RET
		fi
		[ -z "$RET_LIST" ] && RET_LIST=$e || RET_LIST="$RET_LIST$SEP$e"
	done
	SOAF_RET_LIST=$RET_LIST
}
