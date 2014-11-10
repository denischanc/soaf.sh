################################################################################
################################################################################

soaf_dis_cfg() {
	soaf_cfg_set SOAF_TITLE_PRE "==[[ "
	soaf_cfg_set SOAF_TXT_PRE "  "
}

soaf_define_add_engine_cfg_fn soaf_dis_cfg

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

################################################################################
################################################################################

soaf_dis_txt_stdin() {
	local line
	while read line
	do
		soaf_dis_txt "$line"
	done
}

soaf_dis_txt_off_stdin() {
	local OFF=$1
	local line
	while read line
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
