################################################################################
################################################################################

SOAF_NAME="soaf.sh"
SOAF_VERSION="0.10.0"

SOAF_VERSION_ACTION="version"

################################################################################
################################################################################

soaf_version_init() {
	soaf_info_add_var SOAF_VERSION
	soaf_create_action $SOAF_VERSION_ACTION soaf_version "" $SOAF_POS_PRE
	soaf_no_prepenv_action $SOAF_VERSION_ACTION
}

soaf_define_add_this_init_fn soaf_version_init

################################################################################
################################################################################

soaf_version() {
	local APPLI_NAME=$(soaf_module_this_appli_name)
	soaf_dis_title "$APPLI_NAME"
	soaf_module_apply_all_reverse_fn soaf_module_version
}
