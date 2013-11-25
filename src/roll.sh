################################################################################
################################################################################

SOAF_ROLL_SIZE="4"
SOAF_ROLL_FILE_SIZE="100000"

soaf_info_add_var SOAF_ROLL_FILE_SIZE

################################################################################
################################################################################

soaf_create_roll_nature() {
	local NATURE=$1
	local ROLL_FILE=$2
	local ROLL_SIZE=$3
	local ROLL_COND_FN=$4
	soaf_map_extend $NATURE "ROLL_FILE" "$ROLL_FILE"
	soaf_map_extend $NATURE "ROLL_SIZE" "$ROLL_SIZE"
	soaf_map_extend $NATURE "ROLL_COND_FN" "$ROLL_COND_FN"
}

soaf_create_roll_cond_gt_nature() {
	local NATURE=$1
	local ROLL_FILE=$2
	local ROLL_SIZE=$3
	local ROLL_FILE_SIZE=$4
	local COND_FN="soaf_roll_cond_gt_size"
	soaf_create_roll_nature $NATURE "$ROLL_FILE" "$ROLL_SIZE" $COND_FN
	soaf_map_extend $NATURE "ROLL_FILE_SIZE" "$ROLL_FILE_SIZE"
}

soaf_roll_no_compress() {
	local NATURE=$1
	soaf_map_extend $NATURE "ROLL_NO_COMPRESS" "OK"
}

################################################################################
################################################################################

soaf_roll_proc_file() {
	local FILE=$1
	local NATURE=$2
	local FILE_SIZE=$(stat -c %s "$FILE" 2> /dev/null)
	[ -z "$FILE_SIZE" ] && FILE_SIZE=1
	if [ $FILE_SIZE -eq 0 ]
	then
		soaf_cmd "rm -f $FILE"
	else
		local FILE_ROLL=$FILE-$(date '+%F-%H%M%S')
		soaf_cmd "mv -f $FILE $FILE_ROLL"
		local NO_COMPRESS=$(soaf_map_get $NATURE "ROLL_NO_COMPRESS")
		[ -z "$NO_COMPRESS" ] && soaf_cmd "gzip $FILE_ROLL"
	fi
}

################################################################################
################################################################################

soaf_roll_get_file_list() {
	local FILE=$1
	local FILE_DN=$(dirname "$FILE")
	local FILE_BN=$(basename "$FILE")
	find "$FILE_DN" -name "${FILE_BN}-*" -a -type f | sort
}

soaf_roll_clean() {
	local FILE=$1
	local SIZE=$2
	for f in $(soaf_roll_get_file_list "$FILE" | head -n-$SIZE)
	do
		soaf_cmd "rm -f $f"
	done
}

################################################################################
################################################################################

soaf_roll_nature() {
	local NATURE=$1
	local FILE=$(soaf_map_get $NATURE "ROLL_FILE")
	if [ -n "$FILE" ]
	then
		local SIZE=$(soaf_map_get $NATURE "ROLL_SIZE" $SOAF_ROLL_SIZE)
		local COND_FN=$(soaf_map_get $NATURE "ROLL_COND_FN")
		if [ -f "$FILE" ]
		then
			if [ -n "$COND_FN" ]
			then
				eval local ROLL_PROC=\$\($COND_FN \"\$FILE\" \$NATURE\)
			else
				local ROLL_PROC="OK"
			fi
			[ -n "$ROLL_PROC" ] && soaf_roll_proc_file "$FILE" $NATURE
		fi
		if [ $SIZE -ge 1 ]
		then
			soaf_roll_clean "$FILE" $SIZE
		fi
	fi
}

################################################################################
################################################################################

soaf_roll_cond_gt_size() {
	local FILE=$1
	local NATURE=$2
	local SIZE=$(soaf_map_get $NATURE "ROLL_FILE_SIZE" $SOAF_ROLL_FILE_SIZE)
	local FILE_SIZE=$(stat -c %s "$FILE" 2> /dev/null)
	if [ -n "$FILE_SIZE" ]
	then
		[ $FILE_SIZE -gt $SIZE ] && echo "OK"
	fi
}
