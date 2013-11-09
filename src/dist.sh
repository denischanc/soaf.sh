################################################################################
################################################################################

soaf_dist_engine() {
	local SOAF_TGT_HOME="$1"
	local SOAF_TGT_NAME="$2"
	local SOAF_TGT_VER="$3"
	local SOAF_DIR_LIST="$4"
	local SOAF_FORMAT="$5"
	local SOAF_EXT=".tar.xz" SOAF_TAR_Z_OPT="-J"
	case $SOAF_FORMAT in
	gz) SOAF_EXT=".tar.gz"; SOAF_TAR_Z_OPT="-z";;
	bz) SOAF_EXT=".tar.bz2"; SOAF_TAR_Z_OPT="-j";;
	esac
	local SOAF_PKG_BDIR="$SOAF_TGT_NAME-$SOAF_TGT_VER"
	local SOAF_PKG_HOME="$SOAF_TGT_HOME/$SOAF_PKG_BDIR"
	local SOAF_PKG_FILE="$SOAF_PKG_HOME$SOAF_EXT"
	soaf_dis_title "Create dist : [$(basename $SOAF_PKG_FILE)] ..."
	soaf_dis_txt "Remove [$SOAF_PKG_FILE]."
	rm -f $SOAF_PKG_FILE
	soaf_dis_txt "Remove [$SOAF_PKG_HOME]."
	rm -rf $SOAF_PKG_HOME
	for d in $SOAF_DIR_LIST
	do
		local SOAF_DIR=$(echo $d | tr '/' '_')
		eval SOAF_FILE_LIST=\"\$${SOAF_DIR}_FILE_LIST\"
		for f in $SOAF_FILE_LIST
		do
			local SOAF_SRC_FILE="$SOAF_TGT_HOME/$d/$f"
			local SOAF_DST_FILE="$SOAF_PKG_HOME/$d/$f"
			mkdir -p $(dirname $SOAF_DST_FILE)
			cp $SOAF_SRC_FILE $SOAF_DST_FILE
		done
	done
	tar $SOAF_TAR_Z_OPT -cvf $SOAF_PKG_FILE -C $SOAF_TGT_HOME $SOAF_PKG_BDIR
	rm -rf $SOAF_PKG_HOME
	soaf_dis_title "OK"
}
