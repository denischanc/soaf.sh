#!/bin/sh

################################################################################
################################################################################

TEST_HOME="$(dirname $0)"

make -C $TEST_HOME/.. > /dev/null 2>&1
. $TEST_HOME/../src/soaf.sh

soaf_cfg_set TEST_LOG_FILE $TEST_HOME/test.log
SOAF_LOG_FILE=$TEST_LOG_FILE

################################################################################
################################################################################

test_version() {
	echo "test-1.0.0"
}

test_init() {
	soaf_log_info "Test init called."
}

soaf_def_user test_version TEST "NAME VAL" test_init

################################################################################
################################################################################

test_display() {
	soaf_dis_txt "[$NAME] = [$VAL] (NAME = VAL)"
	soaf_dis_txt "[$TEST_NAME] = [$TEST_VAL] (TEST_NAME = TEST_VAL)"
}

test_display_usage() {
	soaf_dis_txt "Display NAME = VAL."
}

soaf_create_action "display" test_display test_display_usage

################################################################################
################################################################################

soaf_cfg_set TEST_SPACE "    "
soaf_info_add_var TEST_SPACE

################################################################################
################################################################################

soaf_create_job "ps" "ps -ef" $TEST_HOME 1

################################################################################
################################################################################

TEST_PROP_NATURE="test_prop"
TEST_TEST_PROP="test"

soaf_create_prop_file_nature $TEST_PROP_NATURE $TEST_HOME/test.prop
### soaf_create_prop_file_nature $TEST_PROP_NATURE $TEST_HOME/test.prop ":"

test_prop_file() {
	rm -f $(soaf_map_get $TEST_PROP_NATURE "PROP_FILE")
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.0"
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.1"
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.10"
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.11"
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.0"
	soaf_prop_file_set_add $TEST_PROP_NATURE $TEST_TEST_PROP "3.14.1"
	soaf_prop_file_get $TEST_PROP_NATURE $TEST_TEST_PROP
	soaf_dis_txt "Ret : [$SOAF_PROP_FILE_RET]"
	soaf_dis_txt "Val : [$SOAF_PROP_FILE_VAL]"
}

soaf_create_action "prop_file" test_prop_file

################################################################################
################################################################################

soaf_engine
