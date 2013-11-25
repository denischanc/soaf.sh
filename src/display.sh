################################################################################
################################################################################

SOAF_TITLE_PRE="==[[ "
SOAF_TXT_PRE="  "

################################################################################
################################################################################

soaf_dis_title() {
	local MSG=$1
	echo "$SOAF_TITLE_PRE$MSG"
}

soaf_dis_txt() {
	local MSG=$1
	echo "$SOAF_TXT_PRE$MSG"
}

soaf_dis_txt_off() {
	local MSG=$1
	local OFF=$2
	[ -z "$OFF" ] && OFF=1
	local I=0 TXT_PRE=""
	while [ $I -lt $OFF ]
	do
		TXT_PRE=$TXT_PRE$SOAF_TXT_PRE
		I=$(expr $I + 1)
	done
	echo "$TXT_PRE$MSG"
}
