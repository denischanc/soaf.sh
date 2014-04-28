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
	local VAR=$2
	local VAL=$3
	local FILE=$(soaf_map_get $NATURE "PROP_FILE")
	if [ -f $FILE ]
	then
		local FILE_TMP=$1.$$
		grep -v "^$VAR=" $FILE > $FILE_TMP
		mv -f $FILE_TMP $FILE
	fi
	cat << _EOF_ >> $FILE
$VAR=$VAL
_EOF_
}

soaf_prop_file_get() {
	local NATURE=$1
	local VAR=$2
	local FILE=$(soaf_map_get $NATURE "PROP_FILE")
	if [ -f $FILE ]
	then
		local VAR_LINE=$(grep "^$VAR=" $FILE 2> /dev/null)
		echo "${VAR_LINE#$VAR=}"
	fi
}

################################################################################
################################################################################

soaf_prop_file_list_add() {
	local NATURE=$1
	local VAR=$2
	local VAL=$3
	local FILE=$(soaf_map_get $NATURE "PROP_FILE")
	local SEP=$(soaf_map_get $NATURE "PROP_SEP")
	local VAL_LIST=$(soaf_prop_file_get $NATURE $VAR)
	if [ -z "$VAL_LIST" ]
	then
		soaf_prop_file_set $NATURE $VAR "$VAL"
	else
		soaf_prop_file_set $NATURE $VAR "$VAL_LIST$SEP$VAL"
	fi
}

################################################################################
################################################################################

soaf_prop_file_set_add() {
	local NATURE=$1
	local VAR=$2
	local VAL=$3
	local FILE=$(soaf_map_get $NATURE "PROP_FILE")
	local SEP=$(soaf_map_get $NATURE "PROP_SEP")
	local VAL_LIST=$(soaf_prop_file_get $NATURE $VAR)
	if [ -z "$VAL_LIST" ]
	then
		soaf_prop_file_set $NATURE $VAR "$VAL"
	else
		local FND=$(echo "$SEP$VAL_LIST$SEP" | grep "$SEP$VAL$SEP")
		if [ -z "$FND" ]
		then
			soaf_prop_file_set $NATURE $VAR "$VAL_LIST$SEP$VAL"
		fi
	fi
}
