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

### TODO : update SOAF_RET in return io $VAR_DST
soaf_map_get_var() {
	local VAR_DST=$1
	local NAME=$2
	local FIELD=$3
	local DFT=$4
	soaf_map_var_ $NAME
	declare -Ag $SOAF_RET
	eval $VAR_DST=\${$SOAF_RET[$FIELD]:-\$DFT}
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

soaf_map_w_array_get_var() {
	local NAME=$1
	local FIELD=$2
	soaf_map_w_array_var_ $NAME $FIELD
	eval SOAF_RET=\(\"\${$SOAF_RET[@]}\"\)
}
