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
	soaf_prop_file_get $NATURE $PROP
	if [ -n "$SOAF_PROP_FILE_RET" ]
	then
		if [ "$SOAF_PROP_FILE_VAL" = "$VAL" ]
		then
			SOAF_PROP_FILE_RET="OK"
		else
			soaf_log_err "Unable to set prop (file : [$FILE]) : [$PROP]."
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
			soaf_log_err "Unable to get prop (file : [$FILE]) : [$PROP]."
			SOAF_PROP_FILE_RET=
		fi
		SOAF_PROP_FILE_VAL=${VAR_LINE#$PROP=}
	else
		SOAF_PROP_FILE_VAL=
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
