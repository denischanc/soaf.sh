################################################################################
################################################################################

SOAF_ROLL_SIZE_ATTR="soaf_roll_size"
SOAF_ROLL_COND_FN_ATTR="soaf_roll_cond_fn"
SOAF_ROLL_FILE_EXT_FN_ATTR="soaf_roll_file_ext_fn"
SOAF_ROLL_FILE_SIZE_ATTR="soaf_roll_file_size"
SOAF_ROLL_NO_COMPRESS_ATTR="soaf_roll_no_compress"

SOAF_ROLL_FILE_DATE_MAP="soaf.roll.file.date"

SOAF_ROLL_LOG_NAME="soaf.roll"

SOAF_ROLL_BY_DAY_DATE_PATTERN="%F"

SOAF_ROLL_FILE_EXT_DFT_FN=soaf_roll_file_ext

################################################################################
################################################################################

soaf_roll_cfg() {
	soaf_cfg_set SOAF_ROLL_SIZE 4
	soaf_cfg_set SOAF_ROLL_FILE_SIZE 100000
	soaf_cfg_set SOAF_ROLL_FILE_EXT_DATE_PATTERN "%F-%H%M%S"
	###---------------
	soaf_cfg_set SOAF_ROLL_COMPRESS_CMD xz
}

soaf_roll_init() {
	soaf_info_add_var "SOAF_ROLL_SIZE SOAF_ROLL_FILE_SIZE"
	soaf_info_add_var "SOAF_ROLL_COMPRESS_CMD"
}

soaf_define_add_this_cfg_fn soaf_roll_cfg
soaf_define_add_this_init_fn soaf_roll_init

################################################################################
################################################################################

soaf_roll_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_ROLL_LOG_NAME $LOG_LEVEL
}

soaf_define_add_name_log_level_fn soaf_roll_log_level

################################################################################
################################################################################

soaf_create_roll_nature() {
	local NATURE=$1
	local ROLL_SIZE=$2
	local ROLL_COND_FN=$3
	local ROLL_FILE_EXT_FN=$4
	soaf_map_extend $NATURE $SOAF_ROLL_SIZE_ATTR $ROLL_SIZE
	soaf_map_extend $NATURE $SOAF_ROLL_COND_FN_ATTR $ROLL_COND_FN
	soaf_map_extend $NATURE $SOAF_ROLL_FILE_EXT_FN_ATTR $ROLL_FILE_EXT_FN
}

soaf_create_roll_cond_gt_nature() {
	local NATURE=$1
	local ROLL_SIZE=$2
	local ROLL_FILE_SIZE=$3
	local ROLL_FILE_EXT_FN=$4
	soaf_create_roll_nature $NATURE "$ROLL_SIZE" \
		soaf_roll_cond_gt_size $ROLL_FILE_EXT_FN
	soaf_map_extend $NATURE $SOAF_ROLL_FILE_SIZE_ATTR $ROLL_FILE_SIZE
}

soaf_create_roll_by_day_nature() {
	local NATURE=$1
	local ROLL_SIZE=$2
	soaf_create_roll_nature $NATURE "$ROLL_SIZE" \
		soaf_roll_cond_by_day soaf_roll_file_ext_by_day
}

soaf_roll_no_compress() {
	local NATURE=$1
	soaf_map_extend $NATURE $SOAF_ROLL_NO_COMPRESS_ATTR "OK"
}

################################################################################
################################################################################

soaf_roll_proc_file() {
	local NATURE=$1
	local FILE=$2
	local FILE_SIZE=$(stat -c %s $FILE 2> $SOAF_LOG_CMD_ERR_FILE)
	soaf_log_cmd_err $SOAF_ROLL_LOG_NAME
	[ -z "$FILE_SIZE" ] && FILE_SIZE=1
	if [ $FILE_SIZE -eq 0 ]
	then
		soaf_rm $FILE "" $SOAF_ROLL_LOG_NAME
	else
		local FILE_EXT_FN=$(soaf_map_get $NATURE $SOAF_ROLL_FILE_EXT_FN_ATTR \
			$SOAF_ROLL_FILE_EXT_DFT_FN)
		$FILE_EXT_FN $NATURE $FILE
		local FILE_EXT=$SOAF_ROLL_FILE_EXT_RET
		local FILE_ROLL=$FILE-$FILE_EXT
		soaf_cmd "mv -f $FILE $FILE_ROLL" "" $SOAF_ROLL_LOG_NAME
		local NO_COMPRESS=$(soaf_map_get $NATURE $SOAF_ROLL_NO_COMPRESS_ATTR)
		if [ -z "$NO_COMPRESS" ]
		then
			soaf_cmd "$SOAF_ROLL_COMPRESS_CMD $FILE_ROLL" "" \
				$SOAF_ROLL_LOG_NAME
		fi
	fi
}

################################################################################
################################################################################

soaf_roll_clean() {
	local FILE=$1
	local SIZE=$2
	local FILE_DN=$(dirname $FILE)
	local FILE_BN=$(basename $FILE)
	local FILE_LIST=$(find $FILE_DN -name "$FILE_BN-*" -a -type f \
		2> $SOAF_LOG_CMD_ERR_FILE | sort | head -n-$SIZE | tr '\n' ' ')
	soaf_log_cmd_err $SOAF_ROLL_LOG_NAME
	soaf_rm "$FILE_LIST" "" $SOAF_ROLL_LOG_NAME
}

################################################################################
################################################################################

soaf_roll_nature() {
	local NATURE=$1
	local FILE=$2
	if [ -n "$FILE" ]
	then
		soaf_log_prep_cmd_out_err $SOAF_ROLL_LOG_NAME
		local SIZE=$(soaf_map_get $NATURE $SOAF_ROLL_SIZE_ATTR $SOAF_ROLL_SIZE)
		if [ -f "$FILE" ]
		then
			local COND_FN=$(soaf_map_get $NATURE $SOAF_ROLL_COND_FN_ATTR)
			if [ -n "$COND_FN" ]
			then
				SOAF_ROLL_COND_FN_RET=
				$COND_FN $NATURE $FILE
				local ROLL_PROC=$SOAF_ROLL_COND_FN_RET
			else
				local ROLL_PROC="OK"
			fi
			if [ -n "$ROLL_PROC" ]
			then
				if [ $SIZE -ne 0 ]
				then
					soaf_roll_proc_file $NATURE $FILE
				else
					soaf_rm $FILE "" $SOAF_ROLL_LOG_NAME
				fi
			fi
		fi
		[ $SIZE -ge 0 ] && soaf_roll_clean $FILE $SIZE
	fi
}

################################################################################
################################################################################

soaf_roll_cond_gt_size() {
	local NATURE=$1
	local FILE=$2
	local SIZE=$(soaf_map_get $NATURE $SOAF_ROLL_FILE_SIZE_ATTR \
		$SOAF_ROLL_FILE_SIZE)
	local FILE_SIZE=$(stat -c %s $FILE 2> /dev/null)
	if [ -n "$FILE_SIZE" ]
	then
		[ $FILE_SIZE -gt $SIZE ] && SOAF_ROLL_COND_FN_RET="OK"
	fi
}

################################################################################
################################################################################

soaf_roll_file_ext() {
	SOAF_ROLL_FILE_EXT_RET=$(date +$SOAF_ROLL_FILE_EXT_DATE_PATTERN)
}

################################################################################
################################################################################

soaf_roll_cond_by_day() {
	local NATURE=$1
	local FILE=$2
	local FILE_ATTR=$(echo $FILE | md5sum | awk '{print $1}')
	local FILE_DATE=$(soaf_map_get $SOAF_ROLL_FILE_DATE_MAP $FILE_ATTR)
	local DATE_PATTERN=$SOAF_ROLL_BY_DAY_DATE_PATTERN
	if [ -z "$FILE_DATE" ]
	then
		FILE_DATE=$(stat --format=%Y $FILE 2> /dev/null)
		FILE_DATE=$(date --date=@$FILE_DATE +$DATE_PATTERN 2> /dev/null)
		soaf_map_extend  $SOAF_ROLL_FILE_DATE_MAP $FILE_ATTR $FILE_DATE
	fi
	[ -n "$FILE_DATE" -a "$FILE_DATE" != "$(date +$DATE_PATTERN)" ] && \
		SOAF_ROLL_COND_FN_RET="OK"
}

soaf_roll_file_ext_by_day() {
	local NATURE=$1
	local FILE=$2
	local FILE_ATTR=$(echo $FILE | md5sum | awk '{print $1}')
	local FILE_DATE=$(soaf_map_get $SOAF_ROLL_FILE_DATE_MAP $FILE_ATTR)
	soaf_map_extend  $SOAF_ROLL_FILE_DATE_MAP $FILE_ATTR ""
	SOAF_ROLL_FILE_EXT_RET=$FILE_DATE
}
