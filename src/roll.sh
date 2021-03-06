################################################################################
################################################################################

readonly SOAF_ROLL_SIZE_ATTR="soaf_roll_size"
readonly SOAF_ROLL_COND_FN_ATTR="soaf_roll_cond_fn"
readonly SOAF_ROLL_FILE_EXT_FN_ATTR="soaf_roll_file_ext_fn"
readonly SOAF_ROLL_FILE_SIZE_ATTR="soaf_roll_file_size"
readonly SOAF_ROLL_NO_COMPRESS_ATTR="soaf_roll_no_compress"

readonly SOAF_ROLL_FILE_DATE_MAP="soaf.roll.file.date"

readonly SOAF_ROLL_LOG_NAME="soaf.roll"

readonly SOAF_ROLL_BY_DAY_DATE_PATTERN="%F"

readonly SOAF_ROLL_FILE_EXT_DFT_FN=soaf_roll_file_ext_

################################################################################
################################################################################

soaf_roll_static_() {
	soaf_log_add_log_level_fn soaf_roll_log_level
}

soaf_roll_cfg_() {
	SOAF_ROLL_SIZE=4
	SOAF_ROLL_FILE_SIZE=100000
	SOAF_ROLL_FILE_EXT_DATE_PATTERN="%F-%H%M%S"
	###---------------
	SOAF_ROLL_COMPRESS_CMD=xz
}

soaf_roll_init_() {
	soaf_info_add_var "SOAF_ROLL_SIZE SOAF_ROLL_FILE_SIZE"
	soaf_info_add_var "SOAF_ROLL_COMPRESS_CMD"
}

soaf_create_module soaf.core.roll $SOAF_DIST_VERSION soaf_roll_static_ \
	soaf_roll_cfg_ soaf_roll_init_

################################################################################
################################################################################

soaf_roll_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_ROLL_LOG_NAME $LOG_LEVEL
}

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

soaf_roll_proc_file_() {
	local NATURE=$1
	local FILE=$2
	soaf_log_prep_cmd_err "stat -c %s $FILE" $SOAF_ROLL_LOG_NAME
	local FILE_SIZE=$(eval "$SOAF_LOG_RET")
	soaf_log_cmd_err $SOAF_ROLL_LOG_NAME
	[ -z "$FILE_SIZE" ] && FILE_SIZE=1
	if [ $FILE_SIZE -eq 0 ]
	then
		soaf_rm $FILE "" $SOAF_ROLL_LOG_NAME
	else
		soaf_map_get $NATURE $SOAF_ROLL_FILE_EXT_FN_ATTR \
			$SOAF_ROLL_FILE_EXT_DFT_FN
		$SOAF_RET $NATURE $FILE
		local FILE_EXT=$SOAF_ROLL_FILE_EXT_RET
		local FILE_ROLL=$FILE-$FILE_EXT
		soaf_cmd "mv -f $FILE $FILE_ROLL" "" $SOAF_ROLL_LOG_NAME
		soaf_map_get $NATURE $SOAF_ROLL_NO_COMPRESS_ATTR
		if [ -z "$SOAF_RET" ]
		then
			soaf_cmd "$SOAF_ROLL_COMPRESS_CMD $FILE_ROLL" "" \
				$SOAF_ROLL_LOG_NAME
		fi
	fi
}

################################################################################
################################################################################

soaf_roll_clean_() {
	local FILE=$1
	local SIZE=$2
	local FILE_DN=$(dirname $FILE)
	local FILE_BN=$(basename $FILE)
	soaf_log_prep_cmd_err "find $FILE_DN -name \"$FILE_BN-*\" -a -type f" \
		$SOAF_ROLL_LOG_NAME
	local FILE_LIST=$(eval "$SOAF_LOG_RET" | sort | head -n-$SIZE | tr '\n' ' ')
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
		soaf_map_get $NATURE $SOAF_ROLL_SIZE_ATTR $SOAF_ROLL_SIZE
		local SIZE=$SOAF_RET
		if [ -f "$FILE" ]
		then
			soaf_map_get $NATURE $SOAF_ROLL_COND_FN_ATTR
			local COND_FN=$SOAF_RET
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
					soaf_roll_proc_file_ $NATURE $FILE
				else
					soaf_rm $FILE "" $SOAF_ROLL_LOG_NAME
				fi
			fi
		fi
		[ $SIZE -ge 0 ] && soaf_roll_clean_ $FILE $SIZE
	fi
}

################################################################################
################################################################################

soaf_roll_cond_gt_size() {
	local NATURE=$1
	local FILE=$2
	local FILE_SIZE=$(stat -c %s $FILE 2> /dev/null)
	if [ -n "$FILE_SIZE" ]
	then
		soaf_map_get $NATURE $SOAF_ROLL_FILE_SIZE_ATTR $SOAF_ROLL_FILE_SIZE
		[ $FILE_SIZE -gt $SOAF_RET ] && SOAF_ROLL_COND_FN_RET="OK"
	fi
}

################################################################################
################################################################################

soaf_roll_file_ext_() {
	SOAF_ROLL_FILE_EXT_RET=$(date +$SOAF_ROLL_FILE_EXT_DATE_PATTERN)
}

################################################################################
################################################################################

soaf_roll_cond_by_day() {
	local NATURE=$1
	local FILE=$2
	local FILE_ATTR=$(echo $FILE | md5sum | awk '{print $1}')
	soaf_map_get $SOAF_ROLL_FILE_DATE_MAP $FILE_ATTR
	local FILE_DATE=$SOAF_RET
	local DATE_PATTERN=$SOAF_ROLL_BY_DAY_DATE_PATTERN
	if [ -z "$FILE_DATE" ]
	then
		FILE_DATE=$(stat --format=%Y $FILE 2> /dev/null)
		FILE_DATE=$(date --date=@$FILE_DATE +$DATE_PATTERN 2> /dev/null)
		soaf_map_extend $SOAF_ROLL_FILE_DATE_MAP $FILE_ATTR $FILE_DATE
	fi
	[ -n "$FILE_DATE" -a "$FILE_DATE" != "$(date +$DATE_PATTERN)" ] && \
		SOAF_ROLL_COND_FN_RET="OK"
}

soaf_roll_file_ext_by_day() {
	local NATURE=$1
	local FILE=$2
	local FILE_ATTR=$(echo $FILE | md5sum | awk '{print $1}')
	soaf_map_get $SOAF_ROLL_FILE_DATE_MAP $FILE_ATTR
	local FILE_DATE=$SOAF_RET
	soaf_map_extend $SOAF_ROLL_FILE_DATE_MAP $FILE_ATTR ""
	SOAF_ROLL_FILE_EXT_RET=$FILE_DATE
}
