#!/bin/sh

THIS_HOME="$(dirname $0)"

SOAF_FILE="$THIS_HOME/../src/soaf.sh"
[ ! -f $SOAF_FILE ] && $THIS_HOME/make.sh
. $SOAF_FILE

. $THIS_HOME/../src/file_list.sh

src_FILE_LIST="$SOAF_SRC_FILE_LIST file_list.sh"
bin_FILE_LIST="dist.sh make.sh clean.sh install.sh"

soaf_dist_engine $THIS_HOME/.. soaf $SOAF_VERSION "bin src"
