#!/bin/sh
#sqlpj00003 - test help command

TESTNAME=sqlpj00003
echo TESTNAME is $TESTNAME
. ./regress_defs.ksh

#note - help is directed at STDERR
cd "$TEST_ROOT"
2>&1 sqlpj -help
