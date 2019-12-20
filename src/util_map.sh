################################################################################
################################################################################

soaf_to_var() {
	local NAME=${1//./_}
	NAME=${NAME//-/_}
	SOAF_RET=${NAME//\//_}
}

################################################################################
################################################################################

soaf_map_var() {
	local NAME=$1
	local FIELD=$2
	soaf_to_var __${NAME}__$FIELD
}

soaf_map_extend() {
	local NAME=$1
	local FIELD=$2
	local VAL=$3
	soaf_map_var $NAME $FIELD
	eval $SOAF_RET=\$VAL
}

soaf_map_cat() {
	local NAME=$1
	local FIELD=$2
	local VAL=$3
	soaf_map_var $NAME $FIELD
	eval $SOAF_RET=\"\$$SOAF_RET \$VAL\"
}

soaf_map_get_var() {
	local VAR_DST=$1
	local NAME=$2
	local FIELD=$3
	local DFT=$4
	soaf_map_var $NAME $FIELD
	eval $VAR_DST=\${$SOAF_RET:-\$DFT}
}
