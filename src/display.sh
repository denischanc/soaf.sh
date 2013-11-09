################################################################################
################################################################################

soaf_dis_title() {
	local SOAF_MSG="$1"
	echo "$SOAF_TITLE_PRE$SOAF_MSG"
}

soaf_dis_txt() {
	local SOAF_MSG="$1"
	echo "$SOAF_TXT_PRE$SOAF_MSG"
}
