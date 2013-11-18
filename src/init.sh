################################################################################
################################################################################

### VAR_LIST : SOAF_CFG_GLOB_EXT SOAF_CFG_LOC_EXT

################################################################################
################################################################################

soaf_info_add_var SOAF_CFG_LIST

soaf_action_init_proc "usage" soaf_usage
soaf_action_init_proc "version" soaf_version
soaf_action_init_proc "info" soaf_info

################################################################################
################################################################################

while [ $# -ge 1 ]
do
	soaf_parse_arg "$1"
	shift
done

SOAF_CFG_LIST="$SOAF_CFG_GLOB $SOAF_CFG_LOC"
SOAF_CFG_LIST="$SOAF_CFG_LIST $SOAF_CFG_GLOB_EXT $SOAF_CFG_LOC_EXT"

for cfg in $SOAF_CFG_LIST
do
	[ -f $cfg ] && . $cfg
done
