#!/bin/sh
#sqlpj00005 - create test database tables

TESTNAME=sqlpj00005
echo TESTNAME is $TESTNAME
. ./regress_defs.ksh

SQLCMDS=$TEST_ROOT/$TESTNAME.sql
cp "$DB_CREATE_TESTDB_TABLES" "$SQLCMDS"
cat << EOF >> "$SQLCMDS"
tables
EOF

#######
#before we wipe out tables, we make sure that the test database
#was successfully dropped & recreated:
#######

if [ -r $DB_CREATE_FAILED  ]; then
    echo ERROR: TEST DB create failed - ABORT test $TESTNAME
    exit 1
fi

if [ ! -r $DB_CREATE_SUCCEEDED ]; then
    echo ERROR: TEST DB create did not succeed - ABORT test $TESTNAME
    exit 2
fi

#create the tables:
sqlpj -props "$REGRESS_TESTDB_PROPS" -prompt "" "$SQLCMDS"
echo sqlpj status is $?
