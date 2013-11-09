#!/bin/sh

THIS_HOME="$(dirname $0)"

. $THIS_HOME/../src/file_list.sh

SOAF_FILE="$THIS_HOME/../src/soaf.sh"

rm -f $SOAF_FILE
for f in $SOAF_SRC_FILE_LIST
do
	SRC_FILE="$THIS_HOME/../src/$f"
	echo "$SRC_FILE -->> $SOAF_FILE"
	cat $SRC_FILE >> $SOAF_FILE
done
