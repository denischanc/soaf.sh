################################################################################
################################################################################

SOAF_DISPLAY_TXT_PRE_1="@[SOAF_TXT_PRE]"
SOAF_DISPLAY_TXT_PRE_2="@[SOAF_TXT_PRE]@[SOAF_TXT_PRE]"
SOAF_DISPLAY_TXT_PRE_3="@[SOAF_TXT_PRE]@[SOAF_TXT_PRE]@[SOAF_TXT_PRE]"

SOAF_DISPLAY_VAR2FN_MAP="soaf.dis.var2fn"

################################################################################
################################################################################

soaf_dis_static_() {
	soaf_usermsgproc_add_use_fn soaf_dis_use_usermsgproc
}

soaf_dis_cfg_() {
	SOAF_TITLE_PRE="==[[ "
	SOAF_TXT_PRE="  "
	soaf_var_add_unsubst "SOAF_DISPLAY_TXT_PRE_1 SOAF_DISPLAY_TXT_PRE_2 \
		SOAF_DISPLAY_TXT_PRE_3"
}

soaf_create_module soaf.core.display $SOAF_VERSION soaf_dis_static_ \
	soaf_dis_cfg_

################################################################################
################################################################################

soaf_dis_use_usermsgproc() {
	SOAF_DIS_USERMSGPROC_USED="OK"
}

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
	soaf_console_msg_ctl "$MSG" \
		"$SOAF_CONSOLE_FG_B_BLUE $SOAF_CONSOLE_CTL_UNDERLINE"
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
	soaf_console_filter_stdin | while read
	do
		soaf_dis_txt "$REPLY"
	done
}

soaf_dis_txt_off_stdin() {
	local OFF=$1
	local line
	soaf_console_filter_stdin | while read
	do
		soaf_dis_txt_off "$REPLY" $OFF
	done
}

################################################################################
################################################################################

soaf_dis_var_w_fn() {
	local VAR=$1
	local FN=$2
	soaf_map_extend $SOAF_DISPLAY_VAR2FN_MAP $VAR $FN
}

soaf_dis_var_list() {
	local VAR_LIST=$1
	local var
	for var in $VAR_LIST
	do
		soaf_map_get $SOAF_DISPLAY_VAR2FN_MAP $var
		local FN=$SOAF_RET
		if [ -n "$FN" ]
		then
			$FN $var
			local VAL=$SOAF_RET
		else
			eval local VAL=\$$var
		fi
		soaf_dis_txt "$var = [$VAL]"
	done
}
