#!/bin/sh

################################################################################
################################################################################

TEST_VERSION="1.2.0"

TEST_HOME="$(dirname $0)"

TEST_LOG_NAME="test"
TEST_NATURE="test"
TEST_PROP_NATURE_1="test.prop.1"
TEST_PROP_NATURE_2="test.prop.2"

TEST_TEST_PROP="test"

SOAF_ENGINE_EXT_ALL_DIR=$TEST_HOME

make -C $TEST_HOME/.. > /dev/null 2>&1
. $TEST_HOME/../src/soaf.sh

test_cfg() {
	SOAF_WORK_DIR=$TEST_HOME
	[ "$ACTION" = "err_on_log_prep" ] && \
		SOAF_LOG_DIR=$SOAF_APPLI_SH_DIR/../TODO
}

test_init() {
	soaf_usage_add_var "NAME VAL MSG" "TEST"
	soaf_create_var_usage VAL "" "" '  __££ $$  {}  =__  '
	test_init_display
	test_init_space
	test_init_job
	test_init_prop_file
	test_init_log_stderr
	test_init_notif
	test_init_dis_txt_off
	test_init_module
	test_init_env
	test_init_varargs
	soaf_create_action "err_on_log_prep" not_a_function
}

################################################################################
################################################################################

test_prepenv() {
	soaf_log_info "Test prepenv called." $TEST_LOG_NAME
}

test_exit() {
	local MODULE_NAME=$1
	local ERR=$2
	soaf_log_info "RET_CODE=[$ERR]" $TEST_LOG_NAME
}

soaf_create_appli_nature $TEST_NATURE "" "" \
	test_cfg test_init test_prepenv "" "" test_exit

################################################################################
################################################################################

test_display() {
	soaf_dis_txt "[$NAME] = [$VAL] (NAME = VAL)"
	soaf_dis_txt "[$TEST_NAME] = [$TEST_VAL] (TEST_NAME = TEST_VAL)"
	soaf_dis_var_list "ERR_TYPE TEST_ERR_TYPE"
	soaf_create_usermsgproc_debug
	soaf_usermsgproc__ $SOAF_USERMSGPROC_LOG_ORG "log color test;"
	soaf_usermsgproc__ $SOAF_USERMSGPROC_TXT_ORG "text color test;"
	soaf_usermsgproc__ OTHER "other color test;"
}

test_display_usage() {
	soaf_dis_txt "Display NAME = VAL."
}

test_init_display() {
	soaf_create_action "display" test_display test_display_usage
}

################################################################################
################################################################################

test_init_space() {
	soaf_cfg_set TEST_SPACE "    "
	soaf_info_add_var TEST_SPACE
}

################################################################################
################################################################################

test_init_job() {
	### soaf_create_job "ps" "ps -ef" $TEST_HOME 3
	### soaf_create_job "ps" "ps -ef" $TEST_HOME 1
	### soaf_create_job "ps" "ps -ef"
	soaf_create_job "ps" "ps -ef" $SOAF_LOG_DIR 0
}

################################################################################
################################################################################

test_prop_file_nature() {
	local TEST_PROP_NATURE=$1
	###-------------------------------------------------------------------------
	rm -f $SOAF_PF_FILE
	###-------------------------------------------------------------------------
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.0"
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.1"
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.10"
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.11"
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.0"
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.1"
	soaf_prop_file_get $TEST_PROP_NATURE $TEST_TEST_PROP
	soaf_dis_txt "Ret : [$SOAF_PROP_FILE_RET] = [OK]"
	soaf_dis_txt "Val : [$SOAF_PROP_FILE_VAL] = [3.14.0#3.14.1#3.14.10#3.14.11]"
	###-------------------------------------------------------------------------
	soaf_prop_file_list_rm $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.11"
	soaf_prop_file_list_rm $TEST_PROP_NATURE $TEST_TEST_PROP "3.15"
	soaf_prop_file_list_rm $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.1"
	soaf_prop_file_get $TEST_PROP_NATURE $TEST_TEST_PROP
	soaf_dis_txt "Ret : [$SOAF_PROP_FILE_RET] = [OK]"
	soaf_dis_txt "Val : [$SOAF_PROP_FILE_VAL] = [3.14.0#3.14.10]"
	###-------------------------------------------------------------------------
	soaf_prop_file_list_rm $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.0"
	soaf_prop_file_list_rm $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.10"
	soaf_prop_file_list_rm $TEST_PROP_NATURE $TEST_TEST_PROP "3.15"
	soaf_prop_file_get $TEST_PROP_NATURE $TEST_TEST_PROP
	soaf_dis_txt "Ret : [$SOAF_PROP_FILE_RET] = [OK]"
	soaf_dis_txt "Val : [$SOAF_PROP_FILE_VAL] = []"
	###-------------------------------------------------------------------------
}

test_prop_file() {
	test_prop_file_nature $TEST_PROP_NATURE_1
	test_prop_file_nature $TEST_PROP_NATURE_2
}

test_init_prop_file() {
	soaf_create_prop_file_nature $TEST_PROP_NATURE_1
	soaf_create_prop_file_nature $TEST_PROP_NATURE_2 "" ":"
	soaf_create_action "prop_file" test_prop_file
}

################################################################################
################################################################################

test_log_stderr() {
	soaf_mkdir "$SOAF_APPLI_SH_DIR/../TODO $SOAF_APPLI_SH_DIR/../ChangeLog" \
		$SOAF_LOG_INFO $TEST_LOG_NAME
}

test_init_log_stderr() {
	soaf_create_action "log_stderr" test_log_stderr
}

################################################################################
################################################################################

test_notif_usage() {
	soaf_dis_txt "Notif MSG."
}

test_notif() {
	soaf_notif "$TEST_MSG"
}

test_init_notif() {
	soaf_create_action "notif" test_notif test_notif_usage
}

################################################################################
################################################################################

test_dis_txt_off() {
	soaf_dis_txt_off "Niveau 1" 1
	soaf_dis_txt_off "Niveau 2" 2
	soaf_dis_txt_off "Niveau 3" 3
	soaf_dis_txt_off "Niveau 4" 4
	soaf_dis_txt_off "Niveau 5" 5
	soaf_dis_txt_off "Niveau 4" 4
	soaf_dis_txt_off "Niveau 3" 3
	soaf_dis_txt_off "Niveau 2" 2
	soaf_dis_txt_off "Niveau 1" 1
}

test_init_dis_txt_off() {
	soaf_create_action "dis_txt_off" test_dis_txt_off
}

################################################################################
################################################################################

test_module() {
	soaf_dis_txt "Test module ..."
	soaf_dis_var_list "ERR_TYPE TEST_ERR_TYPE"
}

test_init_module() {
	soaf_create_action "module" test_module
	soaf_usage_add_var ERR_TYPE "TEST"
	soaf_create_var_usage ERR_TYPE "" "deadlock notfnd ok" "ok" "" "module" "OK"
}

################################################################################
################################################################################

test_env() {
	set -o posix
	set | grep -i soaf
}

test_init_env() {
	soaf_create_action "env" test_env
}

################################################################################
################################################################################

test_varargs_fn() {
	while [ -n "$1" ]
	do
		soaf_dis_txt "[[$1]]"
		shift
	done
}

test_varargs() {
	local NATURE="test.varargs"
	soaf_create_varargs_nature $NATURE "cc cc" "dd dd"
	soaf_varargs_fn_apply $NATURE test_varargs_fn "aa aa" "bb bb" -- "ee ee"
}

test_init_varargs() {
	soaf_create_action "varargs" test_varargs
}

################################################################################
################################################################################

soaf_engine $TEST_NATURE
