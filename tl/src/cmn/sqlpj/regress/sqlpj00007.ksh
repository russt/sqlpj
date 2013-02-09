#!/bin/sh
#sqlpj00007 - show create commands for all tables

TESTNAME=sqlpj00007
echo TESTNAME is $TESTNAME
. ./regress_defs.ksh

cd "$TEST_ROOT"
sqlpj -props "$REGRESS_TESTDB_PROPS" -prompt '' << EOF
tables
EOF
echo sqlpj status is $?

#diff the output against the reference create script:
#diff $SQLREF $SQLOUT
