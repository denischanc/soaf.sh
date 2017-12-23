################################################################################
################################################################################

SOAF_MAIN_LOG_NAME="soaf.main"

SOAF_MAIN_APPLI_NATURE="soaf.main.appli"

SOAF_MAIN_CREATE_PRJ_ACTION="create_prj"

################################################################################
################################################################################

soaf_main_create_prj_usage() {
	cat << _EOF_ | soaf_dis_txt_stdin
Create a "Hello World !!!" project.
Project is created in PRJ_DIR directory. If PRJ_NAME is empty then PRJ_NAME
value is "basename PRJ_DIR".
_EOF_
}

soaf_main_create_prj() {
	[ -z "$SOAF_PRJ_NAME" ] && SOAF_PRJ_NAME=$(basename $SOAF_PRJ_DIR)
	local SRC_DIR=$SOAF_PRJ_DIR/src
	soaf_mkdir $SRC_DIR $SOAF_LOG_INFO $SOAF_MAIN_LOG_NAME
	[ $SOAF_RET -ne 0 ] && soaf_engine_exit
	### src
	soaf_main_tpl_version $SOAF_PRJ_NAME > $SRC_DIR/version.sh
	soaf_main_tpl_main $SOAF_PRJ_NAME > $SRC_DIR/main.sh
	cat $0 > $SRC_DIR/$SOAF_NAME
	### Makefile
	soaf_main_tpl_makefile_cfg $SOAF_PRJ_NAME > $SOAF_PRJ_DIR/Makefile.cfg
	soaf_main_tpl_makefile > $SOAF_PRJ_DIR/Makefile
}

################################################################################
################################################################################

soaf_main_init() {
	soaf_create_action $SOAF_MAIN_CREATE_PRJ_ACTION \
		soaf_main_create_prj soaf_main_create_prj_usage
	soaf_usage_add_var "PRJ_DIR PRJ_NAME" $SOAF_DEFINE_VAR_PREFIX
	soaf_usage_def_var PRJ_DIR "" "" "" "" $SOAF_MAIN_CREATE_PRJ_ACTION "OK"
}

################################################################################
################################################################################

soaf_main__() {
	soaf_create_appli_nature $SOAF_MAIN_APPLI_NATURE "" "" \
		"" soaf_main_init
	soaf_engine $SOAF_MAIN_APPLI_NATURE
}

################################################################################
################################################################################

if [ "$(basename $0)" = "$SOAF_NAME" ]
then
	soaf_main__
fi
