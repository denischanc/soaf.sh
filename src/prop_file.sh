################################################################################
################################################################################

soaf_prop_file_set() {
	local FILE=$1
	local VAR=$2
	local VAL=$3
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
	local FILE=$1
	local VAR=$2
	if [ -f $FILE ]
	then
		local VAL=$(grep "^$VAR=" $FILE | sed -e "s/^$VAR=//")
		echo "$VAL"
	fi
}

################################################################################
################################################################################

soaf_prop_file_list_add() {
	local FILE=$1
	local VAR=$2
	local VAL=$3
	local VAL_LIST=$(soaf_prop_file_get $FILE $VAR)
	soaf_prop_file_set $FILE $VAR "$VAL_LIST $VAL"
}
