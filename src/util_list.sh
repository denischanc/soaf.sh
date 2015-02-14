################################################################################
################################################################################

soaf_pmp_list_fill() {
	local POS=$1
	local VAR_PRE=$2
	local ELMT=$3
	case $POS in
	$SOAF_POS_PRE)
		eval ${VAR_PRE}_PRE_LIST=\"\$${VAR_PRE}_PRE_LIST \$ELMT\"
		;;
	$SOAF_POS_POST)
		eval ${VAR_PRE}_POST_LIST=\"\$${VAR_PRE}_POST_LIST \$ELMT\"
		;;
	*)
		eval ${VAR_PRE}_MAIN_LIST=\"\$${VAR_PRE}_MAIN_LIST \$ELMT\"
		;;
	esac
}

soaf_pmp_list_cat() {
	local VAR_PRE=$1
	eval SOAF_RET_LIST=\"\$${VAR_PRE}_PRE_LIST\$${VAR_PRE}_MAIN_LIST\"
	eval SOAF_RET_LIST=\"\$SOAF_RET_LIST\$${VAR_PRE}_POST_LIST\"
}
