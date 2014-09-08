################################################################################
################################################################################

SOAF_PF_LOG_NAME="soaf.prop_file"

SOAF_PF_FILE_ATTR="soaf_pf_file"
SOAF_PF_SEP_ATTR="soaf_pf_sep"

################################################################################
################################################################################

soaf_pf_cfg() {
	soaf_cfg_set SOAF_PF_FILE $SOAF_WORK_DIR/$SOAF_USER_NAME.prop
}

soaf_pf_init() {
	soaf_info_add_var SOAF_PF_FILE
}

soaf_engine_add_cfg_fn soaf_pf_cfg
soaf_engine_add_init_fn soaf_pf_init

################################################################################
################################################################################

soaf_pf_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_PF_LOG_NAME $LOG_LEVEL
}

soaf_add_name_log_level_fn soaf_pf_log_level

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

soaf_prop_file_set() {
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
	fi
	soaf_mkdir $(dirname $FILE) "" $SOAF_PF_LOG_NAME
	{
		cat << _EOF_ >> $FILE
$PROP_UNIQ=$VAL
_EOF_
	} |& soaf_log_stdin "" $SOAF_PF_LOG_NAME
	SOAF_PROP_FILE_NO_GET_LOG="OK"
	soaf_prop_file_get $NATURE $PROP
	SOAF_PROP_FILE_NO_GET_LOG=
	if [ -n "$SOAF_PROP_FILE_RET" ]
	then
		if [ "$SOAF_PROP_FILE_VAL" = "$VAL" ]
		then
			SOAF_PROP_FILE_RET="OK"
			local MSG="Set prop [$PROP_UNIQ] value (file : [$FILE]) : [$VAL]."
			soaf_log_debug "$MSG" $SOAF_PF_LOG_NAME
		else
			local MSG="Unable to set prop (file : [$FILE]) : [$PROP_UNIQ]."
			soaf_log_err "$MSG" $SOAF_PF_LOG_NAME
			SOAF_PROP_FILE_RET=
		fi
	fi
}

soaf_prop_file_get() {
	local NATURE=$1
	local PROP=$2
	local FILE=$(soaf_map_get $NATURE $SOAF_PF_FILE_ATTR $SOAF_PF_FILE)
	local PROP_UNIQ=$NATURE.$PROP
	SOAF_PROP_FILE_RET="OK"
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
				local MSG="Unable to get prop (file : [$FILE]) : [$PROP_UNIQ]."
				soaf_log_err "$MSG" $SOAF_PF_LOG_NAME
				SOAF_PROP_FILE_RET=
			else
				SOAF_PROP_FILE_VAL=${VAR_LINE#$PROP_UNIQ=}
			fi
		else
			SOAF_PROP_FILE_RET=
		fi
	else
		SOAF_PROP_FILE_VAL=
	fi
	if [ -n "$SOAF_PROP_FILE_RET" -a -z "$SOAF_PROP_FILE_NO_GET_LOG" ]
	then
		local MSG="Get prop [$PROP_UNIQ] value (file : [$FILE]) :"
		soaf_log_debug "$MSG [$SOAF_PROP_FILE_VAL]." $SOAF_PF_LOG_NAME
	fi
}

################################################################################
################################################################################

soaf_prop_file_list_add() {
	local NATURE=$1
	local PROP=$2
	local VAL=$3
	local FILE=$(soaf_map_get $NATURE $SOAF_PF_FILE_ATTR $SOAF_PF_FILE)
	local SEP=$(soaf_map_get $NATURE $SOAF_PF_SEP_ATTR)
	soaf_prop_file_get $NATURE $PROP
	if [ -n "$SOAF_PROP_FILE_RET" ]
	then
		local VAL_LIST=$SOAF_PROP_FILE_VAL
		if [ -z "$VAL_LIST" ]
		then
			soaf_prop_file_set $NATURE $PROP "$VAL"
		else
			soaf_prop_file_set $NATURE $PROP "$VAL_LIST$SEP$VAL"
		fi
	fi
}

soaf_prop_file_list_rm() {
	local NATURE=$1
	local PROP=$2
	local VAL=$3
	local FILE=$(soaf_map_get $NATURE $SOAF_PF_FILE_ATTR $SOAF_PF_FILE)
	local SEP=$(soaf_map_get $NATURE $SOAF_PF_SEP_ATTR)
	soaf_prop_file_get $NATURE $PROP
	if [ -n "$SOAF_PROP_FILE_RET" ]
	then
		local VAL_LIST=$SOAF_PROP_FILE_VAL
		if [ -n "$VAL_LIST" ]
		then
			VAL_LIST=$(echo "$VAL_LIST" | tr "$SEP" "\n" | \
				grep -v "^$VAL\$" | tr "\n" "$SEP" | sed -e "s£$SEP\$££")
			soaf_prop_file_set $NATURE $PROP "$VAL_LIST"
		fi
	fi
}

################################################################################
################################################################################

soaf_prop_file_is_val() {
	local NATURE=$1
	local PROP=$2
	local VAL=$3
	local FILE=$(soaf_map_get $NATURE $SOAF_PF_FILE_ATTR $SOAF_PF_FILE)
	local SEP=$(soaf_map_get $NATURE $SOAF_PF_SEP_ATTR)
	soaf_prop_file_get $NATURE $PROP
	if [ -n "$SOAF_PROP_FILE_RET" ]
	then
		local VAL_LIST=$SOAF_PROP_FILE_VAL
		SOAF_PROP_FILE_VAL=
		if [ -n "$VAL_LIST" ]
		then
			local FND=$(echo "$SEP$VAL_LIST$SEP" | grep "$SEP$VAL$SEP")
			if [ -n "$FND" ]
			then
				SOAF_PROP_FILE_VAL=$VAL
			fi
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
			soaf_prop_file_list_add $NATURE $PROP "$VAL"
		fi
	fi
}
