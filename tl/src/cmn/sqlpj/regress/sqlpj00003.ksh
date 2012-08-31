#!/bin/sh
#sqlpj00003 - show create command

TESTNAME=sqlpj00003
echo TESTNAME is $TESTNAME

. ./regress_defs.ksh

SQLCMDS=$SHOW_CREATE_TABLES
 SQLOUT=$DB_CREATE_TESTDB_TABLES
 SQLREF=$REGRESS_SRCROOT/scripts/createinf_ref.sql

echo "sqlpj -props $REGRESS_TESTDB_PROPS -prompt  $SQLCMDS > $SQLOUT"
sqlpj -props "$REGRESS_TESTDB_PROPS" -prompt "" "$SQLCMDS" > "$SQLOUT"
echo sqlpj status is $?

#diff the output against the reference create script:
#diff $SQLREF $SQLOUT
