################################################################################
################################################################################

soaf_to_var() {
	SOAF_RET=${1//[!a-zA-Z0-9_]/_}
}

################################################################################
################################################################################

soaf_map_var_() {
	local NAME=$1
	soaf_to_var __${NAME}_map
}

soaf_map_extend() {
	local NAME=$1
	local FIELD=$2
	local VAL=$3
	soaf_map_var_ $NAME
	declare -Ag $SOAF_RET
	eval $SOAF_RET[$FIELD]=\$VAL
}

soaf_map_cat() {
	local NAME=$1
	local FIELD=$2
	local VAL=$3
	soaf_map_var_ $NAME
	declare -Ag $SOAF_RET
	eval $SOAF_RET[$FIELD]+=\" \$VAL\"
}

soaf_map_get() {
	local NAME=$1
	local FIELD=$2
	local DFT=$3
	soaf_map_var_ $NAME
	declare -Ag $SOAF_RET
	eval SOAF_RET=\${$SOAF_RET[$FIELD]:-\$DFT}
}

################################################################################
################################################################################

soaf_map_w_array_var_() {
	local NAME=$1
	local FIELD=$2
	soaf_to_var __${NAME}__$FIELD
}

soaf_map_w_array_cat() {
	local NAME=$1
	local FIELD=$2
	local ARRAY_VAR=$3
	soaf_map_w_array_var_ $NAME $FIELD
	eval $SOAF_RET+=\(\"\${$ARRAY_VAR[@]}\"\)
}

soaf_map_w_array_get() {
	local NAME=$1
	local FIELD=$2
	soaf_map_w_array_var_ $NAME $FIELD
	eval SOAF_RET=\(\"\${$SOAF_RET[@]}\"\)
}
