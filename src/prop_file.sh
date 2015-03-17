################################################################################
################################################################################

SOAF_PF_LOG_NAME="soaf.prop_file"

SOAF_PF_FILE_ATTR="soaf_pf_file"
SOAF_PF_SEP_ATTR="soaf_pf_sep"

SOAF_PF_VAL_ATTR="soaf_pf_val"
SOAF_PF_IN_CACHE_ATTR="soaf_pf_in_cache"

################################################################################
################################################################################

soaf_pf_cfg() {
	local APPLI_NATURE=$1
	local APPLI_NAME=$(soaf_map_get $APPLI_NATURE $SOAF_APPLI_NAME_ATTR)
	soaf_cfg_set SOAF_PF_FILE $SOAF_WORK_DIR/$APPLI_NAME.prop
}

soaf_pf_init() {
	soaf_info_add_var SOAF_PF_FILE
}

soaf_define_add_this_cfg_fn soaf_pf_cfg
soaf_define_add_this_init_fn soaf_pf_init

################################################################################
################################################################################

soaf_pf_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_PF_LOG_NAME $LOG_LEVEL
}

soaf_define_add_name_log_level_fn soaf_pf_log_level

################################################################################
################################################################################

soaf_create_prop_file_nature() {
	local NATURE=$1
	local PROP_FILE=$2
	local PROP_SEP=${3:- }
	soaf_map_extend $NATURE $SOAF_PF_FILE_ATTR $PROP_FILE
	soaf_map_extend $NATURE $SOAF_PF_SEP_ATTR "$PROP_SEP"
}

################################################################################
################################################################################

soaf_prop_file_upd_cache() {
	local PROP_UNIQ=$1
	local VAL=$2
	soaf_map_extend $PROP_UNIQ $SOAF_PF_VAL_ATTR "$VAL"
	soaf_map_extend $PROP_UNIQ $SOAF_PF_IN_CACHE_ATTR "OK"
}

################################################################################
################################################################################

soaf_prop_file_set_require() {
	local NATURE=$1
	local PROP=$2
	local VAL=$3
	local FILE=$(soaf_map_get $NATURE $SOAF_PF_FILE_ATTR $SOAF_PF_FILE)
	local PROP_UNIQ=$NATURE.$PROP
	if [ -f $FILE ]
	then
		{
			local FILE_TMP=$FILE.$$
			grep -v "^$PROP_UNIQ=" $FILE > $FILE_TMP
			mv -f $FILE_TMP $FILE
		} |& soaf_log_stdin "" $SOAF_PF_LOG_NAME
	else
		soaf_mkdir $(dirname $FILE) "" $SOAF_PF_LOG_NAME
	fi
	{
		cat << _EOF_ >> $FILE
$PROP_UNIQ=$VAL
_EOF_
	} |& soaf_log_stdin "" $SOAF_PF_LOG_NAME
	SOAF_PROP_FILE_NO_GET_LOG="OK"
	soaf_prop_file_get_no_cache $NATURE $PROP
	SOAF_PROP_FILE_NO_GET_LOG=
	if [ -n "$SOAF_PROP_FILE_RET" ]
	then
		if [ "$SOAF_PROP_FILE_VAL" = "$VAL" ]
		then
			soaf_prop_file_upd_cache $PROP_UNIQ "$VAL"
			local MSG="Set prop [$PROP_UNIQ] value (file : [$FILE]) : [$VAL]."
			soaf_log_debug "$MSG" $SOAF_PF_LOG_NAME
		else
			SOAF_PROP_FILE_RET=
			local MSG="Unable to set prop (file : [$FILE]) : [$PROP_UNIQ]."
			soaf_log_err "$MSG" $SOAF_PF_LOG_NAME
		fi
	fi
}

soaf_prop_file_set() {
	local NATURE=$1
	local PROP=$2
	local VAL=$3
	SOAF_PROP_FILE_NO_GET_LOG="OK"
	soaf_prop_file_get $NATURE $PROP
	SOAF_PROP_FILE_NO_GET_LOG=
	if [ -n "$SOAF_PROP_FILE_RET" ]
	then
		[ "$SOAF_PROP_FILE_VAL" != "$VAL" ] && \
			soaf_prop_file_set_require $NATURE $PROP "$VAL"
	fi
}

################################################################################
################################################################################

soaf_prop_file_get_no_cache() {
	local NATURE=$1
	local PROP=$2
	local FILE=$(soaf_map_get $NATURE $SOAF_PF_FILE_ATTR $SOAF_PF_FILE)
	local PROP_UNIQ=$NATURE.$PROP
	SOAF_PROP_FILE_RET="OK"
	SOAF_PROP_FILE_VAL=
	if [ -f $FILE ]
	then
		local NB_LINE=$(grep "^$PROP_UNIQ=" $FILE 2> /dev/null | wc -l)
		if [ $NB_LINE -le 1 ]
		then
			soaf_log_prep_cmd_out_err $SOAF_PF_LOG_NAME
			local VAR_LINE=$(grep "^$PROP_UNIQ=" $FILE \
				2> $SOAF_LOG_CMD_ERR_FILE)
			local RET=$?
			soaf_log_cmd_err $SOAF_PF_LOG_NAME
			if [ $RET -ge 2 ]
			then
				SOAF_PROP_FILE_RET=
			else
				SOAF_PROP_FILE_VAL=${VAR_LINE#$PROP_UNIQ=}
			fi
		else
			SOAF_PROP_FILE_RET=
		fi
	fi
	if [ -z "$SOAF_PROP_FILE_RET" ]
	then
		local MSG="Unable to get prop (file : [$FILE]) : [$PROP_UNIQ]."
		soaf_log_err "$MSG" $SOAF_PF_LOG_NAME
	else
		soaf_prop_file_upd_cache $PROP_UNIQ "$SOAF_PROP_FILE_VAL"
		if [ -z "$SOAF_PROP_FILE_NO_GET_LOG" ]
		then
			local MSG="Get prop [$PROP_UNIQ] value (file : [$FILE]) :"
			soaf_log_debug "$MSG [$SOAF_PROP_FILE_VAL]." $SOAF_PF_LOG_NAME
		fi
	fi
}

soaf_prop_file_get() {
	local NATURE=$1
	local PROP=$2
	local PROP_UNIQ=$NATURE.$PROP
	local IN_CACHE=$(soaf_map_get $PROP_UNIQ $SOAF_PF_IN_CACHE_ATTR)
	if [ -n "$IN_CACHE" ]
	then
		SOAF_PROP_FILE_VAL=$(soaf_map_get $PROP_UNIQ $SOAF_PF_VAL_ATTR)
		SOAF_PROP_FILE_RET="OK"
		if [ -z "$SOAF_PROP_FILE_NO_GET_LOG" ]
		then
			local MSG="Get prop [$PROP_UNIQ] value in cache :"
			soaf_log_debug "$MSG [$SOAF_PROP_FILE_VAL]." $SOAF_PF_LOG_NAME
		fi
	else
		soaf_prop_file_get_no_cache $NATURE $PROP
	fi
}

################################################################################
################################################################################

soaf_prop_file_list_add() {
	local NATURE=$1
	local PROP=$2
	local VAL=$3
	if [ -z "$SOAF_PROP_FILE_IN_SET_ADD" ]
	then
		soaf_prop_file_get $NATURE $PROP
	else
		SOAF_PROP_FILE_RET="OK"
		SOAF_PROP_FILE_VAL=$SOAF_PROP_FILE_VAL_LIST_PRIV
	fi
	if [ -n "$SOAF_PROP_FILE_RET" ]
	then
		local VAL_LIST=$SOAF_PROP_FILE_VAL
		if [ -z "$VAL_LIST" ]
		then
			soaf_prop_file_set $NATURE $PROP "$VAL"
		else
			local SEP=$(soaf_map_get $NATURE $SOAF_PF_SEP_ATTR)
			soaf_prop_file_set $NATURE $PROP "$VAL_LIST$SEP$VAL"
		fi
	fi
}

soaf_prop_file_list_rm() {
	local NATURE=$1
	local PROP=$2
	local VAL=$3
	local SEP=$(soaf_map_get $NATURE $SOAF_PF_SEP_ATTR)
	soaf_prop_file_get $NATURE $PROP
	if [ -n "$SOAF_PROP_FILE_RET" ]
	then
		local VAL_LIST=$SOAF_PROP_FILE_VAL
		if [ -n "$VAL_LIST" ]
		then
			local DIFF=$SEP$VAL_LIST$SEP
			VAL_LIST=${DIFF/$SEP$VAL$SEP/$SEP}
			if [ "$VAL_LIST" != "$DIFF" ]
			then
				VAL_LIST=${VAL_LIST#$SEP}
				VAL_LIST=${VAL_LIST%$SEP}
				soaf_prop_file_set $NATURE $PROP "$VAL_LIST"
			fi
		fi
	fi
}

################################################################################
################################################################################

soaf_prop_file_is_val() {
	local NATURE=$1
	local PROP=$2
	local VAL=$3
	soaf_prop_file_get $NATURE $PROP
	if [ -n "$SOAF_PROP_FILE_RET" ]
	then
		local VAL_LIST=$SOAF_PROP_FILE_VAL
		SOAF_PROP_FILE_VAL_LIST_PRIV=$VAL_LIST
		SOAF_PROP_FILE_VAL=
		if [ -n "$VAL_LIST" ]
		then
			local SEP=$(soaf_map_get $NATURE $SOAF_PF_SEP_ATTR)
			VAL_LIST=$SEP$VAL_LIST$SEP
			local DIFF=${VAL_LIST/$SEP$VAL$SEP}
			[ "$DIFF" != "$VAL_LIST" ] && SOAF_PROP_FILE_VAL=$VAL
		fi
	else
		SOAF_PROP_FILE_VAL=
	fi
}

################################################################################
################################################################################

soaf_prop_file_set_add() {
	local NATURE=$1
	local PROP=$2
	local VAL=$3
	soaf_prop_file_is_val $NATURE $PROP "$VAL"
	if [ -n "$SOAF_PROP_FILE_RET" ]
	then
		if [ -z "$SOAF_PROP_FILE_VAL" ]
		then
			SOAF_PROP_FILE_IN_SET_ADD="OK"
			soaf_prop_file_list_add $NATURE $PROP "$VAL"
			SOAF_PROP_FILE_IN_SET_ADD=
		fi
	fi
}
