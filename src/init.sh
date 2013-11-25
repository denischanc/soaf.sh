################################################################################
################################################################################

soaf_cfg_set SOAF_CFG_GLOB "/etc/$SOAF_NAME/soaf.sh"
soaf_cfg_set SOAF_CFG_LOC "$HOME/.$SOAF_NAME/soaf.sh"

SOAF_CFG_LIST="$SOAF_CFG_GLOB $SOAF_CFG_LOC"

soaf_info_add_var SOAF_CFG_LIST

################################################################################
################################################################################

soaf_action_init_proc "usage" soaf_usage
soaf_action_init_proc "version" soaf_version
soaf_action_init_proc "info" soaf_info

################################################################################
################################################################################

for cfg in $SOAF_CFG_LIST
do
	[ -f $cfg ] && . $cfg
done

while [ $# -ge 1 ]
do
	soaf_parse_arg "$1"
	shift
done
