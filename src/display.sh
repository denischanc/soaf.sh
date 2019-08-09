################################################################################
################################################################################

SOAF_DISPLAY_TXT_PRE_1="@[SOAF_TXT_PRE]"
SOAF_DISPLAY_TXT_PRE_2="@[SOAF_TXT_PRE]@[SOAF_TXT_PRE]"
SOAF_DISPLAY_TXT_PRE_3="@[SOAF_TXT_PRE]@[SOAF_TXT_PRE]@[SOAF_TXT_PRE]"

################################################################################
################################################################################

soaf_dis_cfg() {
	SOAF_TITLE_PRE="==[[ "
	SOAF_TXT_PRE="  "
	soaf_var_add_unsubst "SOAF_DISPLAY_TXT_PRE_1 SOAF_DISPLAY_TXT_PRE_2 \
		SOAF_DISPLAY_TXT_PRE_3"
}

soaf_define_add_this_cfg_fn soaf_dis_cfg

################################################################################
################################################################################

soaf_dis_use_usermsgproc() {
	SOAF_DIS_USERMSGPROC_USED="OK"
}

soaf_define_add_use_usermsgproc_fn soaf_dis_use_usermsgproc

################################################################################
################################################################################

soaf_dis_route_() {
	local MSG=$1
	if [ -n "$SOAF_DIS_USERMSGPROC_USED" ]
	then
		soaf_usermsgproc__ $SOAF_USERMSGPROC_TXT_ORG "$MSG"
	else
		soaf_console_info "$MSG"
	fi
}

################################################################################
################################################################################

soaf_dis_title() {
	local MSG=$1
	soaf_console_msg_color "$MSG" 35
	soaf_dis_route_ "$SOAF_TITLE_PRE$SOAF_CONSOLE_RET"
}

soaf_dis_txt() {
	local MSG=$1
	soaf_dis_route_ "$SOAF_TXT_PRE$MSG"
}

soaf_dis_txt_off() {
	local MSG=$1
	local OFF=$2
	[ -z "$OFF" ] && OFF=1
	local VAR=SOAF_DISPLAY_TXT_PRE_$OFF
	eval local TXT_PRE=\$$VAR
	if [ -z "$TXT_PRE" ]
	then
		local I=0
		while [ $I -lt $OFF ]
		do
			TXT_PRE=$TXT_PRE$SOAF_TXT_PRE
			I=$(($I + 1))
		done
		eval $VAR=\$TXT_PRE
	fi
	soaf_dis_route_ "$TXT_PRE$MSG"
}

################################################################################
################################################################################

soaf_dis_txt_stdin() {
	local line
	soaf_console_filter_stdin | while read line
	do
		soaf_dis_txt "$line"
	done
}

soaf_dis_txt_off_stdin() {
	local OFF=$1
	local line
	soaf_console_filter_stdin | while read line
	do
		soaf_dis_txt_off "$line" $OFF
	done
}

################################################################################
################################################################################

soaf_dis_var_list() {
	local VAR_LIST=$1
	local var
	for var in $VAR_LIST
	do
		eval local VAL=\$$var
		soaf_dis_txt "$var = [$VAL]"
	done
}

################################################################################
################################################################################

### TODO : move away
soaf_dis_echo_list() {
	local LIST=$1
	echo $LIST | tr ' ' '|'
}
