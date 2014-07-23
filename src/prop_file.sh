################################################################################
################################################################################

SOAF_PF_LOG_NAME="prop_file"

################################################################################
################################################################################

soaf_pf_log_level() {
	local LOG_LEVEL=$1
	soaf_map_extend $SOAF_PF_LOG_NAME "LOG_LEVEL" $LOG_LEVEL
}

################################################################################
################################################################################

soaf_create_prop_file_nature() {
	local NATURE=$1
	local PROP_FILE=$2
	local PROP_SEP=${3:- }
	soaf_map_extend $NATURE "PROP_FILE" $PROP_FILE
	soaf_map_extend $NATURE "PROP_SEP" "$PROP_SEP"
}

################################################################################
################################################################################

soaf_prop_file_set() {
	local NATURE=$1
	local PROP=$2
	local VAL=$3
	local FILE=$(soaf_map_get $NATURE "PROP_FILE")
	if [ -f $FILE ]
	then
		{
			local FILE_TMP=$FILE.$$
			grep -v "^$PROP=" $FILE > $FILE_TMP
			mv -f $FILE_TMP $FILE
		} 2>> $SOAF_LOG_FILE
	fi
	{
		cat << _EOF_ >> $FILE
$PROP=$VAL
_EOF_
	} 2>> $SOAF_LOG_FILE
	SOAF_PROP_FILE_NO_GET_LOG="OK"
	soaf_prop_file_get $NATURE $PROP
	SOAF_PROP_FILE_NO_GET_LOG=
	if [ -n "$SOAF_PROP_FILE_RET" ]
	then
		if [ "$SOAF_PROP_FILE_VAL" = "$VAL" ]
		then
			SOAF_PROP_FILE_RET="OK"
			local MSG="Set prop [$PROP] value (file : [$FILE]) : [$VAL]."
			soaf_log_debug "$MSG" $SOAF_PF_LOG_NAME
		else
			local MSG="Unable to set prop (file : [$FILE]) : [$PROP]."
			soaf_log_err "$MSG" $SOAF_PF_LOG_NAME
			SOAF_PROP_FILE_RET=
		fi
	fi
}

soaf_prop_file_get() {
	local NATURE=$1
	local PROP=$2
	local FILE=$(soaf_map_get $NATURE "PROP_FILE")
	SOAF_PROP_FILE_RET="OK"
	if [ -f $FILE ]
	then
		local VAR_LINE=$(grep "^$PROP=" $FILE 2>> $SOAF_LOG_FILE)
		if [ $? -ge 2 ]
		then
			local MSG="Unable to get prop (file : [$FILE]) : [$PROP]."
			soaf_log_err "$MSG" $SOAF_PF_LOG_NAME
			SOAF_PROP_FILE_RET=
		fi
		SOAF_PROP_FILE_VAL=${VAR_LINE#$PROP=}
	else
		SOAF_PROP_FILE_VAL=
	fi
	if [ -n "$SOAF_PROP_FILE_RET" -a -z "$SOAF_PROP_FILE_NO_GET_LOG" ]
	then
		local MSG="Get prop [$PROP] value (file : [$FILE]) :"
		soaf_log_debug "$MSG [$SOAF_PROP_FILE_VAL]." $SOAF_PF_LOG_NAME
	fi
}

################################################################################
################################################################################

soaf_prop_file_list_add() {
	local NATURE=$1
	local PROP=$2
	local VAL=$3
	local FILE=$(soaf_map_get $NATURE "PROP_FILE")
	local SEP=$(soaf_map_get $NATURE "PROP_SEP")
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
	local FILE=$(soaf_map_get $NATURE "PROP_FILE")
	local SEP=$(soaf_map_get $NATURE "PROP_SEP")
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
	local FILE=$(soaf_map_get $NATURE "PROP_FILE")
	local SEP=$(soaf_map_get $NATURE "PROP_SEP")
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
