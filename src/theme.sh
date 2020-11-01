################################################################################
################################################################################

readonly SOAF_THEME_LOG_CTL="soaf.theme.log.ctl"

################################################################################
################################################################################

soaf_theme_cfg_() {
	soaf_theme_cfg_log_ctl_
	soaf_theme_dft_
}

soaf_create_module soaf.core.theme $SOAF_DIST_VERSION "" soaf_theme_cfg_

################################################################################
################################################################################

soaf_theme_cfg_log_ctl_() {
	soaf_map_extend $SOAF_THEME_LOG_CTL $SOAF_LOG_DEV_ERR $SOAF_CONSOLE_FG_RED
	soaf_map_extend $SOAF_THEME_LOG_CTL $SOAF_LOG_ERR $SOAF_CONSOLE_FG_RED
	soaf_map_extend $SOAF_THEME_LOG_CTL $SOAF_LOG_WARN $SOAF_CONSOLE_FG_YELLOW
	soaf_map_extend $SOAF_THEME_LOG_CTL $SOAF_LOG_INFO $SOAF_CONSOLE_FG_MAGENTA
	soaf_map_extend $SOAF_THEME_LOG_CTL $SOAF_LOG_DEBUG $SOAF_CONSOLE_FG_CYAN
}

################################################################################
################################################################################

soaf_theme_dft_() {
	SOAF_THEME_VAR_CTL_LIST=$SOAF_CONSOLE_FG_MAGENTA
	SOAF_THEME_VVAL_CTL_LIST=$SOAF_CONSOLE_CTL_BOLD
	SOAF_THEME_ENUM_CTL_LIST="$SOAF_CONSOLE_FG_CYAN $SOAF_CONSOLE_CTL_ITALIC"
	SOAF_THEME_TITLE_CTL_LIST=$SOAF_CONSOLE_FG_B_BLUE
	SOAF_THEME_TITLE_CTL_LIST+=" $SOAF_CONSOLE_CTL_UNDERLINE"
	SOAF_THEME_VAL_CTL_LIST=$SOAF_CONSOLE_FG_GREEN
	SOAF_THEME_VER_CTL_LIST="$SOAF_CONSOLE_FG_GREEN $SOAF_CONSOLE_CTL_BOLD"
}

################################################################################
################################################################################

soaf_theme_color_() {
	local COLOR=$1
	eval SOAF_THEME_VAR_CTL_LIST=\$SOAF_CONSOLE_FG_$COLOR
	eval SOAF_THEME_ENUM_CTL_LIST=\$SOAF_CONSOLE_FG_$COLOR
	SOAF_THEME_ENUM_CTL_LIST+=" $SOAF_CONSOLE_CTL_ITALIC"
	eval SOAF_THEME_TITLE_CTL_LIST=\$SOAF_CONSOLE_FG_B_$COLOR
	SOAF_THEME_TITLE_CTL_LIST+=" $SOAF_CONSOLE_CTL_UNDERLINE"
	eval SOAF_THEME_VAL_CTL_LIST=\$SOAF_CONSOLE_FG_$COLOR
	eval SOAF_THEME_VER_CTL_LIST=\$SOAF_CONSOLE_FG_$COLOR
	SOAF_THEME_VER_CTL_LIST+=" $SOAF_CONSOLE_CTL_BOLD"
}

soaf_theme_green() {
	soaf_theme_color_ GREEN
}

soaf_theme_magenta() {
	soaf_theme_color_ MAGENTA
}
