#setup script for regression tests

#determine PATH separator character:
unset PS; PS=':' ; _doscnt=`echo $PATH | grep -c ';'` ; [ $_doscnt -ne 0 ] && PS=';' ; unset _doscnt

REGRESS_SRCROOT="$SRCROOT/regress"

#this database will be created as part of test suite:
REGRESS_TESTDB=sqltestdb

#this is the install root for sqlpj:
SQLPJ_ROOT="$SRCROOT/srcgen/cgsrc/bld"

export PATH PERL_LIBPATH
PATH="${SQLPJ_ROOT}${PS}$PATH"
PERL_LIBPATH="${SQLPJ_ROOT};$PERL_LIBPATH"

###########
#connection property files:
###########
    INFDB_PROPS="$SQLPJ_ROOT/mojaveinf.props"
INFTESTDB_PROPS="$SQLPJ_ROOT/mojaveinftest.props"
  MYSQLDB_PROPS="$SQLPJ_ROOT/mojavemysql.props"

REGRESS_TESTDB_PROPS="$TEST_ROOT/$REGRESS_TESTDB.props"

#this is where we write test output:
TEST_ROOT=../bld/tst

#this is the script to create the test db tables:
DB_CREATE_TESTDB_TABLES=$TEST_ROOT/create_testdb_tables.sql

#this is the script to show inf tables in a specified order:
SHOW_CREATE_TABLES=$REGRESS_SRCROOT/scripts/show_create_tables.sql

DB_CREATE_SUCCEEDED=$TEST_ROOT/dbcreate_success
   DB_CREATE_FAILED=$TEST_ROOT/dbcreate_failed
