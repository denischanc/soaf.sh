################################################################################
################################################################################

soaf_main_tpl_version() {
	local PRJ_NAME=$1
	local UPPER_VAR_NAME=$(soaf_to_upper_var $PRJ_NAME)
	cat << _EOF_
################################################################################
################################################################################

${UPPER_VAR_NAME}_NAME="$PRJ_NAME"
${UPPER_VAR_NAME}_VERSION="1.0.0-dev"
_EOF_
}

################################################################################
################################################################################

soaf_main_tpl_main() {
	local PRJ_NAME=$1
	local UPPER_VAR_NAME=$(soaf_to_upper_var $PRJ_NAME)
	local LOWER_VAR_NAME=$(soaf_lower $(soaf_to_var $PRJ_NAME))
	local EOF_NAME="_EOF_"
	cat << _EOF_
################################################################################
################################################################################

${UPPER_VAR_NAME}_LOG_NAME="$PRJ_NAME"

${UPPER_VAR_NAME}_APPLI_NATURE="$PRJ_NAME.appli"

${UPPER_VAR_NAME}_HW_ACTION="hello_world"

################################################################################
################################################################################

${LOWER_VAR_NAME}_hw_usage() {
	cat << $EOF_NAME | soaf_dis_txt_stdin
Display "Hello NAME !!!" if NAME is defined,
"Hello world !!!" instead.
$EOF_NAME
}

${LOWER_VAR_NAME}_hw() {
	local NAME=\${${UPPER_VAR_NAME}_NAME:-world}
	local MSG="Hello \$NAME !!!"
	soaf_log_info "\$MSG" \$${UPPER_VAR_NAME}_LOG_NAME
	soaf_dis_txt "\$MSG"
}

################################################################################
################################################################################

${LOWER_VAR_NAME}_init() {
	soaf_create_action \$${UPPER_VAR_NAME}_HW_ACTION \\
		${LOWER_VAR_NAME}_hw ${LOWER_VAR_NAME}_hw_usage
	soaf_usage_add_var NAME ${UPPER_VAR_NAME}
	soaf_usage_def_var NAME "" "" "" "OK" \$${UPPER_VAR_NAME}_HW_ACTION "OK"
}

################################################################################
################################################################################

soaf_create_appli_nature \$${UPPER_VAR_NAME}_APPLI_NATURE "" "" \\
	"" ${LOWER_VAR_NAME}_init
soaf_engine \$${UPPER_VAR_NAME}_APPLI_NATURE
_EOF_
}

################################################################################
################################################################################

soaf_main_tpl_makefile_cfg() {
	cat << _EOF_

SRC_DIR = src
VER_FILE = \$(SRC_DIR)/version.sh

DIST_NAME = \\
  \$(shell grep "_NAME=" \$(VER_FILE) | awk -F\" '{print \$\$2}')
DIST_VERSION = \\
  \$(shell grep "_VERSION=" \$(VER_FILE) | awk -F\" '{print \$\$2}')

EXE_TGT = \$(SRC_DIR)/\$(DIST_NAME)

SRC_LIST = \\
  \$(SRC_DIR)/$SOAF_NAME \\
  \$(SRC_DIR)/version.sh \\
  \$(SRC_DIR)/main.sh

EXTRA_DIST = ChangeLog
_EOF_
}
