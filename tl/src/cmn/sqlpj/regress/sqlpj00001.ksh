#!/bin/sh
#sqlpj00001 - set-up

TESTNAME=sqlpj00001
echo TESTNAME is $TESTNAME
. ./regress_defs.ksh

#clean up from previous run:
rm -rf "$TEST_ROOT" _Inline
mkdir  "$TEST_ROOT"
echo MKDIR STATUS is $?

#old - this appears to work with JDK 1.5 only!
#JDBC_CLASSPATH=$REGRESS_SRCROOT/drivers/db-derby-10.1.1.0.jar

echo Creating $REGRESS_TESTDB_PROPS
cat > "$REGRESS_TESTDB_PROPS" << EOF
JDBC_CLASSPATH=$REGRESS_SRCROOT/drivers/derby.jar
JDBC_DRIVER_CLASS=org.apache.derby.jdbc.EmbeddedDriver
JDBC_URL=jdbc:derby:testDB;create=true
JDBC_USER=test
JDBC_PASSWORD=test
EOF

cat $REGRESS_TESTDB_PROPS
