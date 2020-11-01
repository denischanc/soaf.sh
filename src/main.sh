################################################################################
################################################################################

readonly SOAF_MAIN_LOG_NAME="soaf.main"

readonly SOAF_MAIN_APPLI_NATURE="soaf.main.appli"

readonly SOAF_MAIN_CREATE_PRJ_ACTION="create_prj"

################################################################################
################################################################################

soaf_main_create_prj_usage_() {
	soaf_dis_txt_stdin << _EOF_
Create a "Hello World !!!" project.
Project is created in PRJ_DIR directory. If PRJ_NAME is empty then PRJ_NAME
value is "basename PRJ_DIR".
_EOF_
}

soaf_main_create_prj_() {
	[ -z "$SOAF_PRJ_NAME" ] && SOAF_PRJ_NAME=$(basename $SOAF_PRJ_DIR)
	local SRC_DIR=$SOAF_PRJ_DIR/src
	soaf_mkdir $SRC_DIR $SOAF_LOG_INFO $SOAF_MAIN_LOG_NAME
	### src
	soaf_main_tpl_main $SOAF_PRJ_NAME > $SRC_DIR/main.sh
	cat $SOAF_APPLI_SH_FILE > $SRC_DIR/$SOAF_DIST_NAME
	### Makefile
	soaf_main_tpl_makefile_cfg $SOAF_PRJ_NAME > $SOAF_PRJ_DIR/Makefile.cfg
	soaf_main_tpl_makefile > $SOAF_PRJ_DIR/Makefile
	### ChangeLog
	touch $SOAF_PRJ_DIR/$SOAF_CHANGELOG_ADOC_FILE
}

################################################################################
################################################################################

soaf_main_init_() {
	soaf_create_action $SOAF_MAIN_CREATE_PRJ_ACTION \
		soaf_main_create_prj_ soaf_main_create_prj_usage_
	soaf_usage_add_var PRJ_NAME $SOAF_DEFINE_VAR_PREFIX
	soaf_create_var_usage_exp PRJ_DIR "" "" "" "" \
		$SOAF_MAIN_CREATE_PRJ_ACTION "OK" $SOAF_DEFINE_VAR_PREFIX
}

################################################################################
################################################################################

soaf_main_() {
	soaf_create_appli_nature $SOAF_MAIN_APPLI_NATURE "" "" \
		"" soaf_main_init_
	soaf_engine $SOAF_MAIN_APPLI_NATURE
}

################################################################################
################################################################################

if [ "$(basename $0)" = "$SOAF_DIST_NAME" ]
then
	soaf_main_
fi
