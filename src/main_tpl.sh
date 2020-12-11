################################################################################
################################################################################

soaf_main_tpl_main() {
	local PRJ_NAME=$1
	local APPLI_NAME=${PRJ_NAME%.sh}
	soaf_to_var $APPLI_NAME
	declare -u UPPER_VAR_NAME=$SOAF_RET
	declare -l LOWER_VAR_NAME=$SOAF_RET
	local EOF_NAME="_EOF_"
	cat << _EOF_
################################################################################
################################################################################

${UPPER_VAR_NAME}_LOG_NAME="$APPLI_NAME"

${UPPER_VAR_NAME}_APPLI_NATURE="$APPLI_NAME.appli"

${UPPER_VAR_NAME}_HW_ACTION="hello_world"

################################################################################
################################################################################

${LOWER_VAR_NAME}_hw_usage() {
	soaf_dis_txt_stdin << $EOF_NAME
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
	soaf_create_var_usage_exp NAME "" "" "" "OK" \\
		\$${UPPER_VAR_NAME}_HW_ACTION "OK" ${UPPER_VAR_NAME}
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
	local PRJ_NAME=$1
	cat << _EOF_

DIST_NAME = $PRJ_NAME
DIST_VERSION = 1.0.0-dev

EXE_TGT = src/\$(DIST_NAME)

SRC_LIST = \\
  src/$SOAF_DIST_NAME \\
  src/main.sh

SRC_GENERATED_LIST = src/define_.sh

EXTRA_DIST = \$(CHANGELOG_ADOC_FILE)
_EOF_
}
