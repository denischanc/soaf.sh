################################################################################
################################################################################

readonly SOAF_PF_LOG_NAME="soaf.prop_file"

readonly SOAF_PF_FILE_ATTR="soaf_pf_file"
readonly SOAF_PF_SEP_ATTR="soaf_pf_sep"

readonly SOAF_PF_VAL_ATTR="soaf_pf_val"
readonly SOAF_PF_IN_CACHE_ATTR="soaf_pf_in_cache"

################################################################################
################################################################################

soaf_pf_static_() {
	soaf_log_add_log_level_fn soaf_pf_log_level
}

soaf_pf_cfg_() {
	SOAF_PF_FILE=@[SOAF_WORK_DIR]/$SOAF_APPLI_NAME.prop
	soaf_var_add_unsubst SOAF_PF_FILE
}

soaf_pf_init_() {
	soaf_info_add_var SOAF_PF_FILE
}

soaf_create_module soaf.extra.pf $SOAF_VERSION soaf_pf_static_ \
	soaf_pf_cfg_ soaf_pf_init_

################################################################################
################################################################################

soaf_pf_log_level() {
	local LOG_LEVEL=$1
	soaf_log_name_log_level $SOAF_PF_LOG_NAME $LOG_LEVEL
}

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

soaf_prop_file_upd_cache_() {
	local PROP_UNIQ=$1
	local VAL=$2
	soaf_map_extend $PROP_UNIQ $SOAF_PF_VAL_ATTR "$VAL"
	soaf_map_extend $PROP_UNIQ $SOAF_PF_IN_CACHE_ATTR "OK"
}

################################################################################
################################################################################

soaf_prop_file_uniq_name_() {
	local NATURE=$1
	local PROP=$2
	SOAF_PROP_FILE_RET=$SOAF_APPLI_NAME.$NATURE.$PROP
}

################################################################################
################################################################################

soaf_prop_file_persist_() {
	local PROP_UNIQ=$1
	local VAL=$2
	local FILE=$3
	local FILE_TMP=$FILE.$$
	local FILE_BUP=$FILE.bup.$$
	soaf_mkdir $(dirname $FILE) "" $SOAF_PF_LOG_NAME
	[ ! -e $FILE ] && touch $FILE
	cp -f $FILE $FILE_BUP
	local RET=$?
	if [ $RET -eq 0 ]
	then
		grep -v "^$PROP_UNIQ=" $FILE > $FILE_TMP
		[ $? -le 1 ] && RET=0 || RET=1
		if [ $RET -eq 0 ]
		then
			cat << _EOF_ >> $FILE_TMP
$PROP_UNIQ=$VAL
_EOF_
			RET=$?
		fi
		if [ $RET -eq 0 ]
		then
			mv -f $FILE_TMP $FILE
			RET=$?
			if [ $RET -ne 0 ]
			then
				rm -f $FILE_TMP
				local MSG="Unable to update file : [$FILE],"
				MSG+=" backup : [$FILE_BUP], tmp : [$FILE_TMP]."
				soaf_engine_exit "" "$MSG" $SOAF_PF_LOG_NAME
			fi
		fi
	fi
	[ -f $FILE_BUP ] && rm -f $FILE_BUP
	[ -f $FILE_TMP ] && rm -f $FILE_TMP
	SOAF_PROP_FILE_RET=$RET
}

soaf_prop_file_set_require_() {
	local NATURE=$1
	local PROP=$2
	local VAL=$3
	soaf_map_get $NATURE $SOAF_PF_FILE_ATTR $SOAF_PF_FILE
	local FILE=$SOAF_RET
	soaf_prop_file_uniq_name_ $NATURE $PROP
	local PROP_UNIQ=$SOAF_PROP_FILE_RET
	local CMD="soaf_prop_file_persist_ $PROP_UNIQ \"$VAL\" $FILE"
	soaf_log_prep_cmd_err "$CMD" $SOAF_PF_LOG_NAME
	eval "$SOAF_LOG_RET"
	local RET=$SOAF_PROP_FILE_RET
	soaf_log_cmd_err $SOAF_PF_LOG_NAME
	if [ $RET -eq 0 ]
	then
		soaf_prop_file_upd_cache_ $PROP_UNIQ "$VAL"
		local MSG="Set prop [$PROP_UNIQ] value (file : [$FILE]) : [$VAL]."
		soaf_log_debug "$MSG" $SOAF_PF_LOG_NAME
		SOAF_PROP_FILE_RET="OK"
	else
		local MSG="Unable to set prop (file : [$FILE]) : [$PROP_UNIQ]."
		soaf_log_err "$MSG" $SOAF_PF_LOG_NAME
		SOAF_PROP_FILE_RET=
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
			soaf_prop_file_set_require_ $NATURE $PROP "$VAL"
	fi
}

################################################################################
################################################################################

soaf_prop_file_get_in_file_() {
	local PROP_UNIQ=$1
	local FILE=$2
	local VAR_LINE
	soaf_log_prep_cmd_err "grep \"^$PROP_UNIQ=\" $FILE" $SOAF_PF_LOG_NAME
	VAR_LINE=$(eval "$SOAF_LOG_RET")
	local RET=$?
	soaf_log_cmd_err $SOAF_PF_LOG_NAME
	if [ $RET -ge 2 ]
	then
		SOAF_PROP_FILE_RET=
	else
		SOAF_PROP_FILE_VAL=${VAR_LINE#$PROP_UNIQ=}
		SOAF_PROP_FILE_RET="OK"
	fi
}

soaf_prop_file_get_no_cache_() {
	local NATURE=$1
	local PROP_UNIQ=$2
	soaf_map_get $NATURE $SOAF_PF_FILE_ATTR $SOAF_PF_FILE
	local FILE=$SOAF_RET
	if [ -e $FILE ]
	then
		soaf_prop_file_get_in_file_ $PROP_UNIQ $FILE
	else
		SOAF_PROP_FILE_VAL=
		SOAF_PROP_FILE_RET="OK"
	fi
	if [ -z "$SOAF_PROP_FILE_RET" ]
	then
		local MSG="Unable to get prop (file : [$FILE]) : [$PROP_UNIQ]."
		soaf_log_err "$MSG" $SOAF_PF_LOG_NAME
		SOAF_PROP_FILE_RET=
	else
		local VAL=$SOAF_PROP_FILE_VAL
		soaf_prop_file_upd_cache_ $PROP_UNIQ "$VAL"
		if [ -z "$SOAF_PROP_FILE_NO_GET_LOG" ]
		then
			local MSG="Get prop [$PROP_UNIQ] value (file : [$FILE]) :"
			soaf_log_debug "$MSG [$VAL]." $SOAF_PF_LOG_NAME
		fi
		SOAF_PROP_FILE_VAL=$VAL
		SOAF_PROP_FILE_RET="OK"
	fi
}

soaf_prop_file_get() {
	local NATURE=$1
	local PROP=$2
	soaf_prop_file_uniq_name_ $NATURE $PROP
	local PROP_UNIQ=$SOAF_PROP_FILE_RET
	soaf_map_get $PROP_UNIQ $SOAF_PF_IN_CACHE_ATTR
	if [ -n "$SOAF_RET" ]
	then
		soaf_map_get $PROP_UNIQ $SOAF_PF_VAL_ATTR
		local VAL=$SOAF_RET
		if [ -z "$SOAF_PROP_FILE_NO_GET_LOG" ]
		then
			local MSG="Get prop [$PROP_UNIQ] value in cache :"
			soaf_log_debug "$MSG [$VAL]." $SOAF_PF_LOG_NAME
		fi
		SOAF_PROP_FILE_VAL=$VAL
		SOAF_PROP_FILE_RET="OK"
	else
		soaf_prop_file_get_no_cache_ $NATURE $PROP_UNIQ
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
			soaf_map_get $NATURE $SOAF_PF_SEP_ATTR
			soaf_prop_file_set $NATURE $PROP "$VAL_LIST$SOAF_RET$VAL"
		fi
	fi
}

soaf_prop_file_list_rm() {
	local NATURE=$1
	local PROP=$2
	local VAL=$3
	soaf_map_get $NATURE $SOAF_PF_SEP_ATTR
	local SEP=$SOAF_RET
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
		SOAF_PROP_FILE_VAL_LIST_PRIV=$SOAF_PROP_FILE_VAL
		if [ -n "$SOAF_PROP_FILE_VAL" ]
		then
			local VAL_LIST=$SOAF_PROP_FILE_VAL
			soaf_map_get $NATURE $SOAF_PF_SEP_ATTR
			local SEP=$SOAF_RET
			VAL_LIST=$SEP$VAL_LIST$SEP
			local DIFF=${VAL_LIST/$SEP$VAL$SEP}
			[ "$DIFF" != "$VAL_LIST" ] && SOAF_PROP_FILE_VAL=$VAL || \
				SOAF_PROP_FILE_VAL=
		fi
		SOAF_PROP_FILE_RET="OK"
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
