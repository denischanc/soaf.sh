################################################################################
################################################################################

readonly SOAF_WHICH_FILE=/usr/bin/which

################################################################################
################################################################################

soaf_which() {
	local APPLI_SH=$1
	if [ -x $SOAF_WHICH_FILE ]
	then
		$SOAF_WHICH_FILE $APPLI_SH
	else
		if [ -x $APPLI_SH ]
		then
			echo $APPLI_SH
		else
			local _path
			for _path in $(echo $PATH | tr -d ':')
			do
				local PATH_SH=$_path/$APPLI_SH
				[ -x $PATH_SH ] && echo $PATH_SH
			done
			echo $APPLI_SH
		fi
	fi
}
