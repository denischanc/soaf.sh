#!/bin/sh

################################################################################
################################################################################

TEST_HOME="$(dirname $0)"
TEST_LOG_NAME="test"

make -C $TEST_HOME/.. > /dev/null 2>&1
. $TEST_HOME/../src/soaf.sh

test_cfg() {
	soaf_cfg_set SOAF_WORK_DIR $TEST_HOME
	soaf_cfg_set SOAF_LOG_DIR $TEST_HOME
}

test_init() {
	test_init_1
	test_init_2
	test_init_3
	test_init_4
	test_init_5
}

################################################################################
################################################################################

test_prepenv() {
	soaf_log_info "Test prepenv called."
}

TEST_NATURE="test"

soaf_create_user_nature $TEST_NATURE "test" "1.0.0" \
	"TEST" "NAME VAL" \
	test_cfg test_init test_prepenv

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
	soaf_create_job "ps" "ps -ef" $TEST_HOME 0
}

################################################################################
################################################################################

TEST_PROP_NATURE="test.prop"
TEST_TEST_PROP="test"

test_prop_file() {
	rm -f $(soaf_map_get $TEST_PROP_NATURE "PROP_FILE")
	###-------------------------------------------------------------------------
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.0"
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.1"
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.10"
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.11"
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.0"
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.1"
	soaf_prop_file_get $TEST_PROP_NATURE $TEST_TEST_PROP
	soaf_dis_txt "Ret : [$SOAF_PROP_FILE_RET]"
	soaf_dis_txt "Val : [$SOAF_PROP_FILE_VAL]"
	###-------------------------------------------------------------------------
	soaf_prop_file_list_rm $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.11"
	soaf_prop_file_list_rm $TEST_PROP_NATURE $TEST_TEST_PROP "3.15"
	soaf_prop_file_list_rm $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.1"
	soaf_prop_file_get $TEST_PROP_NATURE $TEST_TEST_PROP
	soaf_dis_txt "Ret : [$SOAF_PROP_FILE_RET]"
	soaf_dis_txt "Val : [$SOAF_PROP_FILE_VAL]"
	###-------------------------------------------------------------------------
	soaf_prop_file_list_rm $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.0"
	soaf_prop_file_list_rm $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.10"
	soaf_prop_file_list_rm $TEST_PROP_NATURE $TEST_TEST_PROP "3.15"
	soaf_prop_file_get $TEST_PROP_NATURE $TEST_TEST_PROP
	soaf_dis_txt "Ret : [$SOAF_PROP_FILE_RET]"
	soaf_dis_txt "Val : [$SOAF_PROP_FILE_VAL]"
	###-------------------------------------------------------------------------
}

test_init_4() {
	soaf_create_prop_file_nature $TEST_PROP_NATURE $TEST_HOME/test.prop
	### soaf_create_prop_file_nature $TEST_PROP_NATURE $TEST_HOME/test.prop ":"
	soaf_create_action "prop_file" test_prop_file
}

################################################################################
################################################################################

test_others() {
	soaf_mkdir "$SOAF_USER_SH_DIR/../TODO $SOAF_USER_SH_DIR/../ChangeLog" \
		$SOAF_LOG_INFO $TEST_LOG_NAME
}

test_init_5() {
	soaf_create_action "others" test_others
}

################################################################################
################################################################################

soaf_engine $TEST_NATURE
