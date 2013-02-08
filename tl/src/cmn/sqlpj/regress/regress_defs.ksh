#setup script for regression tests

#determine PATH separator character:
unset PS; PS=':' ; _doscnt=`echo $PATH | grep -c ';'` ; [ $_doscnt -ne 0 ] && PS=';' ; unset _doscnt

#this is the install root for sqlpj:
SQLPJ_SRCROOT="$SRCROOT/tl/src/cmn/sqlpj"
REGRESS_SRCROOT="$SQLPJ_SRCROOT/regress"
#this is where we write test output:
TEST_ROOT=$SQLPJ_SRCROOT/bld/tst

SQLPJ_CGROOT="$SQLPJ_SRCROOT/srcgen/bld"
if [ ! -d $SQLPJ_SRCROOT ]; then
    2>&1 echo WARNING:  you must generate sqlpj in $SQLPJ_CGROOT to test latest source
    #fall back to latest installed version:
    SQLPJ_CGROOT="$SQLPJ_SRCROOT"
fi

#this database will be created as part of test suite:
REGRESS_TESTDB=sqltestdb

export PATH PERL_LIBPATH
PATH="${SQLPJ_CGROOT}${PS}$PATH"
PERL_LIBPATH="${SQLPJ_CGROOT};$PERL_LIBPATH"

###########
#connection property files:
###########
    INFDB_PROPS="$SQLPJ_CGROOT/mojaveinf.props"
INFTESTDB_PROPS="$SQLPJ_CGROOT/mojaveinftest.props"
  MYSQLDB_PROPS="$SQLPJ_CGROOT/mojavemysql.props"

REGRESS_TESTDB_PROPS="$TEST_ROOT/$REGRESS_TESTDB.props"

#this is the script to create the test db tables:
DB_CREATE_TESTDB_TABLES=$TEST_ROOT/create_testdb_tables.sql

#this is the script to show inf tables in a specified order:
SHOW_CREATE_TABLES=$REGRESS_SRCROOT/scripts/show_create_tables.sql

DB_CREATE_SUCCEEDED=$TEST_ROOT/dbcreate_success
   DB_CREATE_FAILED=$TEST_ROOT/dbcreate_failed
