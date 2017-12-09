################################################################################
################################################################################

soaf_pmp_list_var() {
	local POS=$1
	local VAR_PRE=$2
	case $POS in
		$SOAF_POS_PRE) echo "__${VAR_PRE}__soaf_pmp_pre_list";;
		$SOAF_POS_POST) echo "__${VAR_PRE}__soaf_pmp_post_list";;
		*) echo "__${VAR_PRE}__soaf_pmp_main_list";;
	esac
}

soaf_pmp_list_fill() {
	local POS=$1
	local VAR_PRE=$2
	local ELMT_LIST=$3
	local VAR=$(soaf_pmp_list_var "$POS" $VAR_PRE)
	eval $VAR=\"\$$VAR \$ELMT_LIST\"
}

soaf_pmp_list_cat() {
	local VAR_PRE=$1
	SOAF_RET_LIST=""
	local pos VAR
	for pos in $SOAF_POS_PRE $SOAF_POS_MAIN $SOAF_POS_POST
	do
		VAR=$(soaf_pmp_list_var $pos $VAR_PRE)
		eval SOAF_RET_LIST=\"\$SOAF_RET_LIST\$$VAR\"
	done
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
