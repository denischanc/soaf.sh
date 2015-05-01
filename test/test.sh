#!/bin/sh

################################################################################
################################################################################

TEST_HOME="$(dirname $0)"

TEST_LOG_NAME="test"
TEST_NATURE="test"
TEST_PROP_NATURE_1="test.prop.1"
TEST_PROP_NATURE_2="test.prop.2"

TEST_TEST_PROP="test"

SOAF_EXT_OTHER_DIR=$TEST_HOME

make -C $TEST_HOME/.. > /dev/null 2>&1
. $TEST_HOME/../src/soaf.sh

test_cfg() {
	soaf_cfg_set SOAF_WORK_DIR $TEST_HOME
	soaf_cfg_set SOAF_LOG_DIR $TEST_HOME
}

test_init() {
	soaf_usage_add_var "NAME VAL MSG" "TEST"
	soaf_usage_def_var VAL "" "" '  __££ $$  {}  =__  '
	test_init_1
	test_init_2
	test_init_3
	test_init_4
	test_init_5
	test_init_6
	test_init_7
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

soaf_create_appli_nature $TEST_NATURE "test" "1.0.1" \
	test_cfg test_init test_prepenv "" "" test_exit

################################################################################
################################################################################

test_display() {
	soaf_dis_txt "[$NAME] = [$VAL] (NAME = VAL)"
	soaf_dis_txt "[$TEST_NAME] = [$TEST_VAL] (TEST_NAME = TEST_VAL)"
}

test_display_usage() {
	soaf_dis_txt "Display NAME = VAL."
}

test_init_1() {
	soaf_create_action "display" test_display test_display_usage
}

################################################################################
################################################################################

test_init_2() {
	soaf_cfg_set TEST_SPACE "    "
	soaf_info_add_var TEST_SPACE
}

################################################################################
################################################################################

test_init_3() {
	### soaf_create_job "ps" "ps -ef" $TEST_HOME 3
	### soaf_create_job "ps" "ps -ef" $TEST_HOME 1
	### soaf_create_job "ps" "ps -ef"
	soaf_create_job "ps" "ps -ef" $TEST_HOME 0
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

test_init_4() {
	soaf_create_prop_file_nature $TEST_PROP_NATURE_1
	soaf_create_prop_file_nature $TEST_PROP_NATURE_2 "" ":"
	soaf_create_action "prop_file" test_prop_file
}

################################################################################
################################################################################

test_log_stderr() {
	soaf_mkdir "$SOAF_USER_SH_DIR/../TODO $SOAF_USER_SH_DIR/../ChangeLog" \
		$SOAF_LOG_INFO $TEST_LOG_NAME
}

test_init_5() {
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

test_init_6() {
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

test_init_7() {
	soaf_create_action "dis_txt_off" test_dis_txt_off
}

################################################################################
################################################################################

soaf_engine $TEST_NATURE
