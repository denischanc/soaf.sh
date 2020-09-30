################################################################################
################################################################################

readonly SOAF_WHICH_FILE=/usr/bin/which

################################################################################
################################################################################

soaf_which() {
	local PROG=$1
	if [ -x $SOAF_WHICH_FILE ]
	then
		$SOAF_WHICH_FILE $PROG
	else
		if [ -x $PROG ]
		then
			echo $PROG
		else
			local _path
			for _path in ${PATH//:/ }
			do
				local PROG_PATH=$_path/$PROG
				if [ -x $PROG_PATH ]
				then
					echo $PROG_PATH
					return
				fi
			done
		fi
	fi
}
