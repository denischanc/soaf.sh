################################################################################
################################################################################

SOAF_VERSION_ACTION="version"

################################################################################
################################################################################

soaf_version_init_() {
	soaf_info_add_var SOAF_VERSION
	soaf_create_action $SOAF_VERSION_ACTION soaf_version_ "" $SOAF_POS_PRE
	soaf_no_prepenv_action $SOAF_VERSION_ACTION
}

soaf_create_module soaf.core.version $SOAF_VERSION "" "" soaf_version_init_

################################################################################
################################################################################

soaf_version_() {
	soaf_dis_title "$SOAF_APPLI_NAME"
	soaf_module_apply_all_reverse_fn soaf_module_version
}
