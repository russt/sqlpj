#!/bin/sh
#sqlpj00001 - set-up

TESTNAME=sqlpj00001
echo TESTNAME is $TESTNAME
. ./regress_defs.ksh

#clean up from previous run:
rm -rf "$TEST_ROOT"
mkdir  "$TEST_ROOT"
echo MKDIR STATUS is $?

#make sure we have access to the jdbc connection prop files:
[ ! -r "$INFDB_PROPS"     ] && echo ERROR: missing $INFDB_PROPS
[ ! -r "$INFTESTDB_PROPS" ] && echo ERROR: missing $INFTESTDB_PROPS
[ ! -r "$MYSQLDB_PROPS"   ] && echo ERROR: missing $MYSQLDB_PROPS

#create property file for testdb:
if [ -r "$INFTESTDB_PROPS" ]; then
    sed -e "s/inftest/$REGRESS_TESTDB/g" "$INFTESTDB_PROPS" > "$REGRESS_TESTDB_PROPS"
fi
