#
# BEGIN_HEADER - DO NOT EDIT
#
# The contents of this file are subject to the terms
# of the Common Development and Distribution License
# (the "License").  You may not use this file except
# in compliance with the License.
#
# You can obtain a copy of the license at
# https://open-esb.dev.java.net/public/CDDLv1.0.html.
# See the License for the specific language governing
# permissions and limitations under the License.
#
# When distributing Covered Code, include this CDDL
# HEADER in each file and include the License file at
# https://open-esb.dev.java.net/public/CDDLv1.0.html.
# If applicable add the following below this CDDL HEADER,
# with the fields enclosed by brackets "[]" replaced with
# your own identifying information: Portions Copyright
# [year] [name of copyright owner]
#

#
# @(#)sqlpj.pl
# Copyright 2007-2013 Russ Tremain. All Rights Reserved.
#
# END_HEADER - DO NOT EDIT
#

{
#
#sqlindex - A single SQL index associated with a table
#

use strict;

package sqlpj::sqlindex;
my $pkgname = __PACKAGE__;

#imports:

#package variables:

sub new
{
    my ($invocant) = @_;
    shift @_;

    #allows this constructor to be invoked with reference or with explicit package name:
    my $class = ref($invocant) || $invocant;

    my ($tblname, $iname, $isPrimary, $isUnique) = @_;

    #set up class attribute  hash and bless it into class:
    my $self = bless {
        'mName'       => $iname,         #the name of this index
        'mTableName'  => $tblname,       #the name of this index's table
        'mIsPrimary'  => $isPrimary,     #true (1) if this is a primary index
        'mIsUnique'   => $isUnique,      #true (1) if this is a unique index
        'mIndexKeys'  => [],             #array - list of key objects for this index
        'mKeyNames'   => [],             #array - list of the key names for this index
        }, $class;

    #post-attribute init after we bless our $self (allows use of accessor methods):

    return $self;
}

################################### PACKAGE ####################################
sub addKey
#add an sql key to the list of keys associated with this index
{
    my ($self, $key) = @_;

    push @{$self->{'mIndexKeys'}}, $key;
    push @{$self->{'mKeyNames'}}, $key->name();
}

sub showIndex
#display the index and attributes
{
    my ($self) = @_;

    #for now..
    printf "%s\n", $self->indexCreateStr();
}

sub qname
#quoted index name
{
    my ($self) = @_;

    #TODO: lookup quote char in metadata.
    return sprintf("`%s`", $self->name());
}

sub indexCreateStr
#display sql command to create an index within the context
#of a create table statement.
#TODO:  look up attribute quoting char in metadata
{
    my ($self) = @_;

    #is this a unique index?
    my $unique = $self->isUnique()? "UNIQUE " : "";

    #loop thru keys and get the key create attributes:
    my @keylist = ();
    for my $kk ($self->indexKeys()) {
        push @keylist, $kk->keyCreateStr();
    }

    if ($self->isPrimary()) {
        return sprintf("PRIMARY KEY (%s)", join(", ", @keylist) );
    } else {
        return sprintf("%sINDEX %s (%s)", $unique, $self->qname(), join(", ", @keylist) );
    }
}

sub name
#return value of mName
{
    my ($self) = @_;
    return $self->{'mName'};
}

sub tableName
#return value of mTableName
{
    my ($self) = @_;
    return $self->{'mTableName'};
}

sub isPrimary
#return value of mIsPrimary
{
    my ($self) = @_;
    return $self->{'mIsPrimary'};
}

sub isUnique
#return value of mIsUnique
{
    my ($self) = @_;
    return $self->{'mIsUnique'};
}

sub indexKeys
#return mIndexKeys list
{
    my ($self) = @_;
    return @{$self->{'mIndexKeys'}};
}

sub keyNames
#return mKeyNames list
{
    my ($self) = @_;
    return @{$self->{'mKeyNames'}};
}

1;
} #end of sqlpj::sqlindex
{
#
#sqlindexkey - A single key attribute associated with an SQL index
#

use strict;

package sqlpj::sqlindexkey;
my $pkgname = __PACKAGE__;

#imports:

#package variables:

sub new
{
    my ($invocant) = @_;
    shift @_;

    #allows this constructor to be invoked with reference or with explicit package name:
    my $class = ref($invocant) || $invocant;

    my ($idxname, $keyname, $colobj) = @_;

    #set up class attribute  hash and bless it into class:
    my $self = bless {
        'mName'       => $keyname,         #the name of this key
        'mIndexName'  => $idxname,         #the name of the index this key belongs to
        'mColumnObj'  => $colobj,          #the column object associated with this key
        }, $class;

    #post-attribute init after we bless our $self (allows use of accessor methods):

    return $self;
}

################################### PACKAGE ####################################

sub qname
#quoted index name
{
    my ($self) = @_;

    #TODO: lookup quote char in metadata.
    return sprintf("`%s`", $self->name());
}

sub keyCreateStr
#return the key name for the create table index create
{
    my ($self) = @_;

    return $self->qname();
}

sub keyCreateStrWithLength
#return the key name for the create table index create,
#including the length of VARCHAR keys.
{
    my ($self) = @_;

    my $lenstr = "";

    my $ctype = $self->columnObj()->columnType();

    if ($ctype =~ /CHAR/i) {
        #TODO:  figure out the true index prefix length for each VARCHAR key:
        $lenstr = sprintf("(%d)", $self->columnObj()->columnSize());
    }

    return sprintf("%s%s", $self->qname(), $lenstr);
}

sub name
#return value of mName
{
    my ($self) = @_;
    return $self->{'mName'};
}

sub indexName
#return value of mIndexName
{
    my ($self) = @_;
    return $self->{'mIndexName'};
}

sub columnObj
#return value of mColumnObj
{
    my ($self) = @_;
    return $self->{'mColumnObj'};
}

1;
} #end of sqlpj::sqlindexkey
{
#
#sqlcolumn - manage metadata for a single column of an sql table
#

use strict;

package sqlpj::sqlcolumn;
my $pkgname = __PACKAGE__;

#imports:

#package variables:

sub new
{
    my ($invocant) = @_;
    shift @_;

    #allows this constructor to be invoked with reference or with explicit package name:
    my $class = ref($invocant) || $invocant;

    my ($tblname, $cname, $ctype, $csize, $cnullable, $cdefault, $decimalDigits, $isAutoIncrement) = @_;

    #set up class attribute  hash and bless it into class:
    my $self = bless {
        'mTableName'        => $tblname,
        'mColumnName'       => $cname,
        'mColumnType'       => $ctype,
        'mColumnSize'       => $csize,
        'mColumnIsNullable' => $cnullable,
        'mColumnDefault'    => $cdefault,
        'mDecimalDigits'    => $decimalDigits,
        'mIsAutoIncrement'  => $isAutoIncrement,
        }, $class;

    #post-attribute init after we bless our $self (allows use of accessor methods):
    #printf STDERR "%s:  constructing column object for table '%s', column '%s'\n", $pkgname, $self->tableName(), $self->columnName();

    return $self;
}

################################### PACKAGE ####################################

sub columnCreateAttributes
#return string with additional create attributes for a column
{
    my ($self) = @_;

    my $defaultStr = "";
    
    if (defined($self->columnDefault()) && $self->columnDefault() ne "") {
        #if numerical value, then don't quote the value:
        if ($self->columnType() =~ /(int|decimal)/i ) {
            $defaultStr = sprintf(" default %s", $self->columnDefault());
        } else {
            $defaultStr = sprintf(" default '%s'", $self->columnDefault());
        }
    }

    #set auto_increment:
    my $autoStr = "";

    $autoStr = " auto_increment" if ($self->isAutoIncrement());
    
    return sprintf("%s%s", $autoStr, $defaultStr);
}

sub qcolumnName
#return quoted column name
#TODO look up quote char in metadata.
{
    my ($self) = @_;

    return( "`" . $self->columnName() . "`" );
}

sub columnCreateType
#return string for type name needed for the create table statement
{
    my ($self) = @_;

    my ($ctype) = $self->columnType();
    $ctype =~ tr/[A-Z]/[a-z]/;

    if ($ctype =~ /(text|time)/ ) {
        #length is implied for certain data types:
        return sprintf("%s", $ctype);
    } elsif ($ctype =~ /decimal/ ) {
        return sprintf("%s(%s,%s)", $ctype, $self->columnSize(), $self->decimalDigits());
    } else {
        return sprintf("%s(%s)", $ctype, $self->columnSize());
    }
}

sub tableName
#return value of mTableName
{
    my ($self) = @_;
    return $self->{'mTableName'};
}

sub columnName
#return value of mColumnName
{
    my ($self) = @_;
    return $self->{'mColumnName'};
}

sub columnType
#return value of mColumnType
{
    my ($self) = @_;
    return $self->{'mColumnType'};
}

sub columnSize
#return value of mColumnSize
{
    my ($self) = @_;
    return $self->{'mColumnSize'};
}

sub columnIsNullable
#return value of mColumnIsNullable
{
    my ($self) = @_;
    return $self->{'mColumnIsNullable'};
}

sub columnDefault
#return value of mColumnDefault
{
    my ($self) = @_;
    return $self->{'mColumnDefault'};
}

sub decimalDigits
#return value of mDecimalDigits
{
    my ($self) = @_;
    return $self->{'mDecimalDigits'};
}

sub isAutoIncrement
#return value of mIsAutoIncrement
{
    my ($self) = @_;
    return $self->{'mIsAutoIncrement'};
}

1;
} #end of sqlpj::sqlcolumn
{
#
#sqltable - manange metadata for a single sql table
#

use strict;

package sqlpj::sqltable;
my $pkgname = __PACKAGE__;

#imports:

#package variables:

sub new
{
    my ($invocant) = @_;
    shift @_;

    #allows this constructor to be invoked with reference or with explicit package name:
    my $class = ref($invocant) || $invocant;

    my ($jdbc_metadata, $dbname, $tblname) = @_;

    #set up class attribute  hash and bless it into class:
    my $self = bless {
        'mMetaData'     => $jdbc_metadata,
        'mDatabaseName' => $dbname,
        'mTableName'    => $tblname,
        'mColumnsByName' => {},             #hash - column objects keyed by column name
        'mAllColumns'    => [],             #array - list of column objects
        'mColumnNames'   => [],             #array - list of column names
        'mAllIndices'    => [],             #array - list of indices for this table
        'mIndexNames'    => [],             #array - list of index names
        }, $class;

    #post-attribute init after we bless our $self (allows use of accessor methods):
    #printf STDERR "%s:  constructing table object for '%s'\n", $pkgname, $self->tableName();
    $self->setTableAttributes();

    return $self;
}

################################### PACKAGE ####################################

sub columnsByName
#return mColumnsByName list
{
    my ($self, $cname) = @_;

    return $self->{'mColumnsByName'}->{$cname};
}

sub addIndex
#add an sql index to the list of indicies associated with this table
{
    my ($self, $idx) = @_;

    push @{$self->{'mAllIndices'}}, $idx;
    push @{$self->{'mIndexNames'}}, $idx->name();
}

sub setTableAttributes
#initialize column attributes for our table.
{
    my ($self) = @_;

    my $dbMetaData = $self->metaData();
    my $dbname = $self->databaseName();
    my $tblname = $self->tableName();
    my $str = "";

#printf STDERR "setTableAttributes: tblname='%s' dbname='%s'\n", $tblname, $dbname;

    eval {
        my $rset = undef;
        my %autoIncrementColumns = ();

        ######
        #DUMMY select to get information about columns
        ######
        my $con = $dbMetaData->getConnection();
        my $stmt = $con->createStatement();
        my $sqlbuf = sprintf("select * from %s where 1 = 2", $tblname);
        if ($stmt->execute($sqlbuf)) {
            $rset      = $stmt->getResultSet();
            my $m      = $rset->getMetaData();
            my $colcnt = $m->getColumnCount();

            for (my $ii = 1; $ii <= $colcnt; $ii++) {
                my $cname = $m->getColumnLabel($ii);
#printf STDERR "%s[%s]:isAutoIncrement(%d)=%d\n", $tblname, $cname, $ii, $m->isAutoIncrement($ii);
                $autoIncrementColumns{$cname} = $m->isAutoIncrement($ii);
            }
        } else {
            printf STDERR "%s[setTableAttributes]:  cannot exec DUMMY query on %s\n", $pkgname, $tblname;
        }

        #######
        #column info
        #######
#'getColumns(String catalog, String schemaPattern, String tableNamePattern, String columnNamePattern)'  => 'ResultSet',
        $rset = $dbMetaData->getColumns($dbname, "%", $tblname, "%");

        #######
        # table atributes:
        # TABLE_CAT, TABLE_SCHEM, TABLE_NAME, COLUMN_NAME,
        # DATA_TYPE, TYPE_NAME, COLUMN_SIZE, BUFFER_LENGTH,
        # DECIMAL_DIGITS, NUM_PREC_RADIX, NULLABLE, REMARKS,
        # COLUMN_DEF, SQL_DATA_TYPE, SQL_DATETIME_SUB, CHAR_OCTET_LENGTH,
        # ORDINAL_POSITION, IS_NULLABLE
        #######

        #for each entry, allocate a new column object:
        while ($rset->next()) {
            #note - you have to do the fetch first, which sets wasNull() for the current column.
            $str = $rset->getString("COLUMN_NAME"); $str = $rset->wasNull() ? undef : $str;
            my $cname = $str;

            $str = $rset->getString("TYPE_NAME"); $str = $rset->wasNull() ? undef : $str;
            my $ctype = $str;

            $str = $rset->getString("COLUMN_SIZE"); $str = $rset->wasNull() ? undef : $str;
            my $csize = $str;

            $str = $rset->getString("NULLABLE"); $str = $rset->wasNull() ? undef : $str;
            #my $cnullable = ($str eq "0")? 0 : 1;
            my $cnullable = $str;

            $str = $rset->getString("COLUMN_DEF"); $str = $rset->wasNull() ? undef : $str;
            my $cdefault = $str;

            $str = $rset->getString("DECIMAL_DIGITS"); $str = $rset->wasNull() ? undef  : $str;
            my $decimalDigits = $str;

            #######
            #create new column object:
            #######
            $self->{'mColumnsByName'}->{$cname} =
                new sqlpj::sqlcolumn(
                    $tblname, $cname, $ctype, $csize, $cnullable, $cdefault, $decimalDigits,
                    $autoIncrementColumns{$cname}
                );

            #push column name & reference to column object:
            push @{$self->{'mColumnNames'}}, $cname;
            push @{$self->{'mAllColumns'}}, $self->{'mColumnsByName'}->{$cname};
        }

        ########
        #primary keys:
        # TABLE_CAT, TABLE_SCHEM, TABLE_NAME, COLUMN_NAME, KEY_SEQ, PK_NAME
        ########
#'getPrimaryKeys(String catalog, String schema, String table)'  => 'ResultSet',
        #$rsetb = $dbMetaData->getPrimaryKeys($dbname, "%", $tblname);

        #########
        #Indicies
        # TABLE_CAT, TABLE_SCHEM, TABLE_NAME, NON_UNIQUE, INDEX_QUALIFIER,
        # INDEX_NAME, TYPE, ORDINAL_POSITION, COLUMN_NAME, ASC_OR_DESC,
        # CARDINALITY, PAGES, FILTER_CONDITION
        #########
#'getIndexInfo(String catalog, String schema, String table, boolean unique, boolean approximate)'  => 'ResultSet',
        my $lastIndexName = "";
        my $indexName = "";
        my $cname = "";

        my $idxobj = undef;
        my $keyobj = undef;
        my $isPrimary = 0;
        my $isUnique  = 0;

        $rset = $dbMetaData->getIndexInfo($dbname, "%", $tblname, 0, 0);
        while ($rset->next()) {

            #note - we should never get a null index:
            $str = $rset->getString("INDEX_NAME"); $str = $rset->wasNull() ? undef : $str;
            $indexName = $str;

            $str = $rset->getString("COLUMN_NAME"); $str = $rset->wasNull() ? undef : $str;
            $cname = $str;

            $str = $rset->getString("NON_UNIQUE"); $str = $rset->wasNull() ? undef : $str;
            $isUnique = ($str =~ /true/i)? 0 : 1;

            if ($lastIndexName eq $indexName) {
#printf "%s: CONTINUE OLD RECORD lastIndexName=%s indexName=%s cname=%s\n", $tblname, $lastIndexName, $indexName, $cname;
                $keyobj = new sqlpj::sqlindexkey ($indexName, $cname, $self->columnsByName($cname));
                #push key on index:
                $idxobj->addKey($keyobj);
            } else {

                if ($lastIndexName eq "" ){
#printf "\n%s: FIRST ITERATION: SKIP CLOSE lastIndexName=%s indexName=%s cname=%s\n", $tblname, $lastIndexName, $indexName, $cname;
                } else {
#printf "%s: CLOSE OLD RECORD lastIndexName=%s indexName=%s cname=%s\n", $tblname, $lastIndexName, $indexName, $cname;
#$idxobj->showIndex();
                }

                #create new record:
                $isPrimary = ($indexName eq "PRIMARY")? 1 : 0;

#printf "%s: CREATE NEW RECORD lastIndexName=%s indexName=%s cname=%s isPrimary=%d isUnique=%d\n", $tblname, $lastIndexName, $indexName, $cname, $isPrimary, $isUnique;

                $idxobj = new sqlpj::sqlindex ($tblname, $indexName, $isPrimary, $isUnique);
                #push index on table:
                $self->addIndex($idxobj);

                $keyobj = new sqlpj::sqlindexkey ($indexName, $cname, $self->columnsByName($cname));
                #push key on index:
                $idxobj->addKey($keyobj);
            }

            $lastIndexName = $indexName;
        }

        #if we entered the loop, then we need to close the last record:
        if ($lastIndexName ne "" ) {
#printf "%s: CLOSE OLD RECORD lastIndexName=%s indexName=%s cname=%s\n", $tblname, $lastIndexName, $indexName, $cname;
#$idxobj->showIndex();
        }
    };

    if ($@) {
        if (&Inline::Java::caught("java.sql.SQLException")){
            my $msg = $@->getMessage() ;
            printf STDERR "%s[setTableAttributes]:  Java exception: '%s'\n", $pkgname, $msg;
        } else {
            printf STDERR "%s[setTableAttributes]:  ERROR: '%s'\n",$pkgname, $@;
        }
        return;
    }
}

sub showCreateSql
#show the create table commands.
{
    my ($self) = @_;

    my $tbl = $self->tableName();

#### SOI
    printf <<"!", $tbl, $tbl;
-- DROP TABLE IF EXISTS `%s`;
CREATE TABLE `%s` (
!
#### EOI

    $self->showCreateTableCommon();
}

sub showCreateSqlWithDb
#show the create table commands, including the database name as prefix.
{
    my ($self) = @_;

    my $db = $self->databaseName();
    my $tbl = $self->tableName();

#### SOI
    printf <<"!", $db, $tbl, $db, $tbl;
-- DROP TABLE IF EXISTS `%s`.`%s`;
CREATE TABLE `%s`.`%s` (
!
#### EOI

    $self->showCreateTableCommon();
}

sub showCreateTableCommon
#generate the common part of the table create statement.
{
    my ($self) = @_;

    my @lines = ();
    for my $col ($self->allColumns()) {
        push @lines, sprintf("    %s %s %s%s",
            $col->qcolumnName(),
            $col->columnCreateType(),
            $col->columnIsNullable() ? "NULL" : "NOT NULL",
            $col->columnCreateAttributes(),
            );
    }

    #generate index creates:
    for my $idx ($self->allIndices()) {
        push @lines, sprintf("    %s", $idx->indexCreateStr());
    }

    #ouput lines:
    printf "%s\n", join(",\n", @lines);

#### SOI
    print <<"!";
);

!
#### EOI

}

sub metaData
#return value of mMetaData
{
    my ($self) = @_;
    return $self->{'mMetaData'};
}

sub databaseName
#return value of mDatabaseName
{
    my ($self) = @_;
    return $self->{'mDatabaseName'};
}

sub tableName
#return value of mTableName
{
    my ($self) = @_;
    return $self->{'mTableName'};
}

sub allColumns
#return mAllColumns list
{
    my ($self) = @_;
    return @{$self->{'mAllColumns'}};
}

sub columnNames
#return mColumnNames list
{
    my ($self) = @_;
    return @{$self->{'mColumnNames'}};
}

sub allIndices
#return mAllIndices list
{
    my ($self) = @_;
    return @{$self->{'mAllIndices'}};
}

sub indexNames
#return mIndexNames list
{
    my ($self) = @_;
    return @{$self->{'mIndexNames'}};
}

1;
} #end of sqlpj::sqltable
{
#
#sqltables - manange sql table metadata
#

use strict;

package sqlpj::sqltables;
my $pkgname = __PACKAGE__;

#imports:

#package variables:

sub new
{
    my ($invocant) = @_;
    shift @_;

    #allows this constructor to be invoked with reference or with explicit package name:
    my $class = ref($invocant) || $invocant;

    my ($jdbc_metadata, $dbname) = @_;

    #set up class attribute  hash and bless it into class:
    my $self = bless {
        'mMetaData'     => $jdbc_metadata,
        'mDatabaseName' => $dbname,
        'mTablesByName' => {},             #hash - table objects keyed by table name
        'mAllTables'    => [],             #array - list of table objects
        'mTableNames'   => [],             #array - list of table names
        }, $class;

    #post-attribute init after we bless our $self (allows use of accessor methods):
    #printf STDERR "%s:  constructing tables collection object\n", $pkgname;
    @{$self->{'mTableNames'}} = &retrieveTableNames($self->metaData(), $self->databaseName());

    for my $tblname ($self->tableNames()) {
        #set tables information from jdbc metaData:
        $self->{'mTablesByName'}->{$tblname} = new sqlpj::sqltable($self->metaData(), $self->databaseName(), $tblname);
    }

    @{$self->{'mAllTables'}} = values %{$self->{'mTablesByName'}};

    return $self;
}

################################### PACKAGE ####################################
sub tableByName
#lookup table object in tables hash.
{
    my ($self, $tblname) = @_;

    return $self->{'mTablesByName'}->{$tblname};
}

sub allTables
#return mAllTables list
{
    my ($self) = @_;
    return @{$self->{'mAllTables'}};
}

sub tableNames
#return mTableNames list
{
    my ($self) = @_;
    return @{$self->{'mTableNames'}};
}

sub metaData
#return value of mMetaData
{
    my ($self) = @_;
    return $self->{'mMetaData'};
}

sub databaseName
#return value of mDatabaseName
{
    my ($self) = @_;
    return $self->{'mDatabaseName'};
}

#######
#static methods
#######

sub retrieveTableNames
#retrieve the table names and return as a list..
{
    my ($dbMetaData, $dbname) = @_;

#names of tables columns for mysql:
#       "TABLE_CAT",
#       "TABLE_SCHEM",
#       "TABLE_NAME",
#       "TABLE_TYPE",
#       "REMARKS",

    my @table_names = ();

    eval {
        my $rset = $dbMetaData->getTables($dbname, "%", "%", []);

        #for each entry, save the table name only:
        while ($rset->next()) {
            #note - you have to do the fetch first, which sets wasNull() for the current column.
            my $str = $rset->getString("TABLE_NAME");
            $str = $rset->wasNull() ? "(null)" : $str;

            push @table_names, $str;
        }
    };

    if ($@) {
        if (&Inline::Java::caught("java.sql.SQLException")){
            my $msg = $@->getMessage() ;
            printf STDERR "%s[retrieveTableNames]:  Java exception: '%s'\n", $pkgname, $msg;
        } else {
            printf STDERR "%s[retrieveTableNames]:  ERROR: '%s'\n",$pkgname, $@;
        }
        return ();
    }

#printf STDERR "retrieveTableNames: table_names=(%s)\n", join(",", @table_names);
    return @table_names;
}

1;
} #end of sqlpj::sqltables
{
#
#pkgconfig - Configuration parameters for sqlpj package
#

use strict;

package sqlpj::pkgconfig;
my $pkgname = __PACKAGE__;

#imports:

#package variables:

sub new
{
    my ($invocant) = @_;
    shift @_;

    #allows this constructor to be invoked with reference or with explicit package name:
    my $class = ref($invocant) || $invocant;


    #set up class attribute  hash and bless it into class:
    my $self = bless {
        'mProgName' => undef,
        'mUserSuppliedPrompt' => undef,
        'mJdbcClassPath' => undef,
        'mJdbcDriverClass' => undef,
        'mJdbcUrl' => undef,
        'mJdbcUser' => undef,
        'mJdbcPassword' => undef,
        'mJdbcPropsFileName' => undef,
        'mVersionNumber' => "1.34",
        'mVersionDate'   => "14-Feb-2013",
        'mPathSeparator' => undef,
        'mDebug'         => 0,
        'mDDebug'        => 0,
        'mQuiet'         => 0,
        'mVerbose'       => 0,
        'mExecCommandString' => undef,  #note - currently only used in main package.
        'mSuppressOutput' => 0,
        }, $class;

    #post-attribute init after we bless our $self (allows use of accessor methods):

    return $self;
}

################################### PACKAGE ####################################
sub parseJdbcPropertiesFile
#parse the jdbc properties file if defined
#return 0 if successful.
{
    my ($self) = @_;

    return 0 unless (defined($self->getJdbcPropsFileName()));

    #open file and read each line, ignoring comments.
    my $infile;
    my @props = ();
#printf STDERR "parseJdbcPropertiesFile: fn='%s'\n", $self->getJdbcPropsFileName();
    if (open($infile, $self->getJdbcPropsFileName())) {
        #read into @props:
        @props = <$infile>;
#printf STDERR "parseJdbcPropertiesFile: props=(%s)\n", join("", @props);
        close $infile;
    } else {
        printf STDERR "%s[%s]:  ERROR: cannot open properities file, '%s':  '%s'\n",
            $self->getProgName(), $pkgname, $self->getJdbcPropsFileName(), $!;
        return 1;
    }

#printf STDERR "self->setJdbcClassPath is a %s\n", ref($self->can('setJdbcClassPath'));

    #this is a list of the valid property names and their setters:
    #NOTE:  can() is in the UNIVERSAL class.
    my %ValidProp = (
        'JDBC_CLASSPATH'    => $self->can('setJdbcClassPath'),
        'JDBC_DRIVER_CLASS' => $self->can('setJdbcDriverClass'),
        'JDBC_URL'          => $self->can('setJdbcUrl'),
        'JDBC_USER'         => $self->can('setJdbcUser'),
        'JDBC_PASSWORD'     => $self->can('setJdbcPassword'),
    );

    #keep track of number of properties we set:
    my $npropsSet = 0;

    for my $prop (@props) {
        chomp $prop;

        #skip empty lines:
        next if ($prop =~ /^\s*$/);
        #skip comments:
        next if ($prop =~ /^\s*[#\*]/);

        my (@line) = split(/\s*=\s*/, $prop, 2);    #values (db url) can have "=" in them!  RT 8/30/12
        if ($#line < 1) {
            printf STDERR "%s[%s]:  WARNING: bad record, '%s' in property file, '%s'\n",
                $self->getProgName(), $pkgname, $prop, $self->getJdbcPropsFileName();
            next;
        }

        my ($key, $value) = @line;
#printf STDERR "parseJdbcPropertiesFile:  key='%s' value='%s' ValidProp{%s}='%s'\n", $key, $value, $key, $ValidProp{$key};

        #if valid jdbc property...
        if (defined($ValidProp{$key})) {
            #... then set it:
            my $fref = $ValidProp{$key};

            ####
            #set property:
            ####
            &{$fref}($self, $value);

#printf STDERR "set property %s=%s\n", $key, $value;
            ++$npropsSet;
        }
    }

#printf STDERR "set %d properties successfully\n", $npropsSet;

    return 0;    #SUCCESS
}

sub getProgName
#return value of ProgName
{
    my ($self) = @_;
    return $self->{'mProgName'};
}

sub setProgName
#set value of ProgName and return value.
{
    my ($self, $value) = @_;
    $self->{'mProgName'} = $value;
    return $self->{'mProgName'};
}

sub getJdbcClassPath
#return value of JdbcClassPath
{
    my ($self) = @_;
    return $self->{'mJdbcClassPath'};
}

sub setJdbcClassPath
#set value of JdbcClassPath and return value.
{
    my ($self, $value) = @_;
    $self->{'mJdbcClassPath'} = $value;
    return $self->{'mJdbcClassPath'};
}

sub getJdbcDriverClass
#return value of JdbcDriverClass
{
    my ($self) = @_;
    return $self->{'mJdbcDriverClass'};
}

sub setJdbcDriverClass
#set value of JdbcDriverClass and return value.
{
    my ($self, $value) = @_;
    $self->{'mJdbcDriverClass'} = $value;
    return $self->{'mJdbcDriverClass'};
}

sub getJdbcUrl
#return value of JdbcUrl
{
    my ($self) = @_;
    return $self->{'mJdbcUrl'};
}

sub setJdbcUrl
#set value of JdbcUrl and return value.
{
    my ($self, $value) = @_;
    $self->{'mJdbcUrl'} = $value;
    return $self->{'mJdbcUrl'};
}

sub getJdbcUser
#return value of JdbcUser
{
    my ($self) = @_;
    return $self->{'mJdbcUser'};
}

sub setJdbcUser
#set value of JdbcUser and return value.
{
    my ($self, $value) = @_;
    $self->{'mJdbcUser'} = $value;
    return $self->{'mJdbcUser'};
}

sub getJdbcPassword
#return value of JdbcPassword
{
    my ($self) = @_;
    return $self->{'mJdbcPassword'};
}

sub setJdbcPassword
#set value of JdbcPassword and return value.
{
    my ($self, $value) = @_;
    $self->{'mJdbcPassword'} = $value;
    return $self->{'mJdbcPassword'};
}

sub getJdbcPropsFileName
#return value of JdbcPropsFileName
{
    my ($self) = @_;
    return $self->{'mJdbcPropsFileName'};
}

sub setJdbcPropsFileName
#set value of JdbcPropsFileName and return value.
{
    my ($self, $value) = @_;
    $self->{'mJdbcPropsFileName'} = $value;
    return $self->{'mJdbcPropsFileName'};
}

sub getPathSeparator
#return value of PathSeparator
{
    my ($self) = @_;
    return $self->{'mPathSeparator'};
}

sub setPathSeparator
#set value of PathSeparator and return value.
{
    my ($self, $value) = @_;
    $self->{'mPathSeparator'} = $value;
    return $self->{'mPathSeparator'};
}

sub getUserSuppliedPrompt
#return value of UserSuppliedPrompt
{
    my ($self) = @_;
    return $self->{'mUserSuppliedPrompt'};
}

sub setUserSuppliedPrompt
#set value of UserSuppliedPrompt and return value.
{
    my ($self, $value) = @_;
    $self->{'mUserSuppliedPrompt'} = $value;
    return $self->{'mUserSuppliedPrompt'};
}

sub getDebug
#return value of Debug
{
    my ($self) = @_;
    return $self->{'mDebug'};
}

sub setDebug
#set value of Debug and return value.
{
    my ($self, $value) = @_;
    $self->{'mDebug'} = $value;
    return $self->{'mDebug'};
}

sub getDDebug
#return value of DDebug
{
    my ($self) = @_;
    return $self->{'mDDebug'};
}

sub setDDebug
#set value of DDebug and return value.
{
    my ($self, $value) = @_;
    $self->{'mDDebug'} = $value;
    return $self->{'mDDebug'};
}

sub getVerbose
#return value of Verbose
{
    my ($self) = @_;
    return $self->{'mVerbose'};
}

sub setVerbose
#set value of Verbose and return value.
{
    my ($self, $value) = @_;
    $self->{'mVerbose'} = $value;
    return $self->{'mVerbose'};
}

sub getQuiet
#return value of Quiet
{
    my ($self) = @_;
    return $self->{'mQuiet'};
}

sub setQuiet
#set value of Quiet and return value.
{
    my ($self, $value) = @_;
    $self->{'mQuiet'} = $value;
    return $self->{'mQuiet'};
}

sub getExecCommandString
#return value of ExecCommandString
{
    my ($self) = @_;
    return $self->{'mExecCommandString'};
}

sub setExecCommandString
#set value of ExecCommandString and return value.
{
    my ($self, $value) = @_;
    $self->{'mExecCommandString'} = $value;
    return $self->{'mExecCommandString'};
}

sub getSuppressOutput
#return value of SuppressOutput
{
    my ($self) = @_;
    return $self->{'mSuppressOutput'};
}

sub setSuppressOutput
#set value of SuppressOutput and return value.
{
    my ($self, $value) = @_;
    $self->{'mSuppressOutput'} = $value;
    return $self->{'mSuppressOutput'};
}

sub versionNumber
#return value of mVersionNumber
{
    my ($self) = @_;
    return $self->{'mVersionNumber'};
}

sub versionDate
#return value of mVersionDate
{
    my ($self) = @_;
    return $self->{'mVersionDate'};
}

1;
} #end of sqlpj::pkgconfig
{
#
#sqlpjImpl - perl/jdbc sql command line interpreter
#

use strict;

package sqlpj::sqlpjImpl;
my $pkgname = __PACKAGE__;

#imports:

#package variables:
my $mPROMPT = $pkgname . "> ";
my ($VERBOSE, $DEBUG, $DDEBUG, $QUIET) = (0,0,0,0);

sub new
{
    my ($invocant) = @_;
    shift @_;

    #allows this constructor to be invoked with reference or with explicit package name:
    my $class = ref($invocant) || $invocant;

    my ($cfg) = @_;

    #set up class attribute  hash and bless it into class:
    my $self = bless {
        'mJdbcClassPath'  => $cfg->getJdbcClassPath(),
        'mJdbcDriver'  => $cfg->getJdbcDriverClass(),
        'mJdbcUrl'     => $cfg->getJdbcUrl(),
        'mUser'        => $cfg->getJdbcUser(),
        'mPassword'    => $cfg->getJdbcPassword(),
        'mProgName'    => $cfg->getProgName(),
        'mPrompt'      => "sqlpj> ",
        'mUserSuppliedPrompt' => $cfg->getUserSuppliedPrompt(),
        'mSuppressOutput' => $cfg->getSuppressOutput(),
        'mConnection'  => undef,
        'mMetaData'    => undef,
        'mMetaFuncs'    => undef,
        'mDatabaseName' => undef,
        'mDatabaseProductName' => undef,
        'mIsOracle' => 0,
        'mIsMysql' => 0,
        'mIsDerby' => 0,
        'mIsFirebird' => 0,
        'mSqlTables'    => undef,      #handle to tables object for this connection
        'mXmlDisplay'   => 0,          #if true, display result-sets as sql/xml
        'mCsvDisplay'   => 0,          #if true, display result-sets as comma-separated-data
        'mHeaderSetting' => 1,         #if true, display table headers with data (default is on)
        'mPathSeparator' => $cfg->getPathSeparator(),
        }, $class;

    #post-attribute init after we bless our $self (allows use of accessor methods):
    $DEBUG   = $cfg->getDebug();
    $DDEBUG  = $cfg->getDDebug();
    $QUIET   = $cfg->getQuiet();
    $VERBOSE = $cfg->getVerbose();

    #read in database meta-function interface definitions:
    %{$self->{'mMetaFuncs'}}      = (
        'allProceduresAreCallable()'  => 'boolean',
        'allTablesAreSelectable()'  => 'boolean',
        'getURL()'  => 'String',
        'getUserName()'  => 'String',
        'isReadOnly()'  => 'boolean',
        'nullsAreSortedHigh()'  => 'boolean',
        'nullsAreSortedLow()'  => 'boolean',
        'nullsAreSortedAtStart()'  => 'boolean',
        'nullsAreSortedAtEnd()'  => 'boolean',
        'getDatabaseProductName()'  => 'String',
        'getDatabaseProductVersion()'  => 'String',
        'getDriverName()'  => 'String',
        'getDriverVersion()'  => 'String',
        'getDriverMajorVersion()'  => 'int',
        'getDriverMinorVersion()'  => 'int',
        'usesLocalFiles()'  => 'boolean',
        'usesLocalFilePerTable()'  => 'boolean',
        'supportsMixedCaseIdentifiers()'  => 'boolean',
        'storesUpperCaseIdentifiers()'  => 'boolean',
        'storesLowerCaseIdentifiers()'  => 'boolean',
        'storesMixedCaseIdentifiers()'  => 'boolean',
        'supportsMixedCaseQuotedIdentifiers()'  => 'boolean',
        'storesUpperCaseQuotedIdentifiers()'  => 'boolean',
        'storesLowerCaseQuotedIdentifiers()'  => 'boolean',
        'storesMixedCaseQuotedIdentifiers()'  => 'boolean',
        'getIdentifierQuoteString()'  => 'String',
        'getSQLKeywords()'  => 'String',
        'getNumericFunctions()'  => 'String',
        'getStringFunctions()'  => 'String',
        'getSystemFunctions()'  => 'String',
        'getTimeDateFunctions()'  => 'String',
        'getSearchStringEscape()'  => 'String',
        'getExtraNameCharacters()'  => 'String',
        'supportsAlterTableWithAddColumn()'  => 'boolean',
        'supportsAlterTableWithDropColumn()'  => 'boolean',
        'supportsColumnAliasing()'  => 'boolean',
        'nullPlusNonNullIsNull()'  => 'boolean',
        'supportsConvert()'  => 'boolean',
        'supportsConvert(int fromType, int toType)'  => 'boolean',
        'supportsTableCorrelationNames()'  => 'boolean',
        'supportsDifferentTableCorrelationNames()'  => 'boolean',
        'supportsExpressionsInOrderBy()'  => 'boolean',
        'supportsOrderByUnrelated()'  => 'boolean',
        'supportsGroupBy()'  => 'boolean',
        'supportsGroupByUnrelated()'  => 'boolean',
        'supportsGroupByBeyondSelect()'  => 'boolean',
        'supportsLikeEscapeClause()'  => 'boolean',
        'supportsMultipleResultSets()'  => 'boolean',
        'supportsMultipleTransactions()'  => 'boolean',
        'supportsNonNullableColumns()'  => 'boolean',
        'supportsMinimumSQLGrammar()'  => 'boolean',
        'supportsCoreSQLGrammar()'  => 'boolean',
        'supportsExtendedSQLGrammar()'  => 'boolean',
        'supportsANSI92EntryLevelSQL()'  => 'boolean',
        'supportsANSI92IntermediateSQL()'  => 'boolean',
        'supportsANSI92FullSQL()'  => 'boolean',
        'supportsIntegrityEnhancementFacility()'  => 'boolean',
        'supportsOuterJoins()'  => 'boolean',
        'supportsFullOuterJoins()'  => 'boolean',
        'supportsLimitedOuterJoins()'  => 'boolean',
        'getSchemaTerm()'  => 'String',
        'getProcedureTerm()'  => 'String',
        'getCatalogTerm()'  => 'String',
        'isCatalogAtStart()'  => 'boolean',
        'getCatalogSeparator()'  => 'String',
        'supportsSchemasInDataManipulation()'  => 'boolean',
        'supportsSchemasInProcedureCalls()'  => 'boolean',
        'supportsSchemasInTableDefinitions()'  => 'boolean',
        'supportsSchemasInIndexDefinitions()'  => 'boolean',
        'supportsSchemasInPrivilegeDefinitions()'  => 'boolean',
        'supportsCatalogsInDataManipulation()'  => 'boolean',
        'supportsCatalogsInProcedureCalls()'  => 'boolean',
        'supportsCatalogsInTableDefinitions()'  => 'boolean',
        'supportsCatalogsInIndexDefinitions()'  => 'boolean',
        'supportsCatalogsInPrivilegeDefinitions()'  => 'boolean',
        'supportsPositionedDelete()'  => 'boolean',
        'supportsPositionedUpdate()'  => 'boolean',
        'supportsSelectForUpdate()'  => 'boolean',
        'supportsStoredProcedures()'  => 'boolean',
        'supportsSubqueriesInComparisons()'  => 'boolean',
        'supportsSubqueriesInExists()'  => 'boolean',
        'supportsSubqueriesInIns()'  => 'boolean',
        'supportsSubqueriesInQuantifieds()'  => 'boolean',
        'supportsCorrelatedSubqueries()'  => 'boolean',
        'supportsUnion()'  => 'boolean',
        'supportsUnionAll()'  => 'boolean',
        'supportsOpenCursorsAcrossCommit()'  => 'boolean',
        'supportsOpenCursorsAcrossRollback()'  => 'boolean',
        'supportsOpenStatementsAcrossCommit()'  => 'boolean',
        'supportsOpenStatementsAcrossRollback()'  => 'boolean',
        'getMaxBinaryLiteralLength()'  => 'int',
        'getMaxCharLiteralLength()'  => 'int',
        'getMaxColumnNameLength()'  => 'int',
        'getMaxColumnsInGroupBy()'  => 'int',
        'getMaxColumnsInIndex()'  => 'int',
        'getMaxColumnsInOrderBy()'  => 'int',
        'getMaxColumnsInSelect()'  => 'int',
        'getMaxColumnsInTable()'  => 'int',
        'getMaxConnections()'  => 'int',
        'getMaxCursorNameLength()'  => 'int',
        'getMaxIndexLength()'  => 'int',
        'getMaxSchemaNameLength()'  => 'int',
        'getMaxProcedureNameLength()'  => 'int',
        'getMaxCatalogNameLength()'  => 'int',
        'getMaxRowSize()'  => 'int',
        'doesMaxRowSizeIncludeBlobs()'  => 'boolean',
        'getMaxStatementLength()'  => 'int',
        'getMaxStatements()'  => 'int',
        'getMaxTableNameLength()'  => 'int',
        'getMaxTablesInSelect()'  => 'int',
        'getMaxUserNameLength()'  => 'int',
        'getDefaultTransactionIsolation()'  => 'int',
        'supportsTransactions()'  => 'boolean',
        'supportsTransactionIsolationLevel(int level)'  => 'boolean',
        'supportsDataDefinitionAndDataManipulationTransactions()'  => 'boolean',
        'supportsDataManipulationTransactionsOnly()'  => 'boolean',
        'dataDefinitionCausesTransactionCommit()'  => 'boolean',
        'dataDefinitionIgnoredInTransactions()'  => 'boolean',
        'getProcedures(String catalog, String schemaPattern, String procedureNamePattern)'  => 'ResultSet',
        'getProcedureColumns(String catalog, String schemaPattern, String procedureNamePattern, String columnNamePattern)'  => 'ResultSet',
        'getTables(String catalog, String schemaPattern, String tableNamePattern, String types[])'  => 'ResultSet',
        'getSchemas()'  => 'ResultSet',
        'getCatalogs()'  => 'ResultSet',
        'getTableTypes()'  => 'ResultSet',
        'getColumns(String catalog, String schemaPattern, String tableNamePattern, String columnNamePattern)'  => 'ResultSet',
        'getColumnPrivileges(String catalog, String schema, String table, String columnNamePattern)'  => 'ResultSet',
        'getTablePrivileges(String catalog, String schemaPattern, String tableNamePattern)'  => 'ResultSet',
        'getBestRowIdentifier(String catalog, String schema, String table, int scope, boolean nullable)'  => 'ResultSet',
        'getVersionColumns(String catalog, String schema, String table)'  => 'ResultSet',
        'getPrimaryKeys(String catalog, String schema, String table)'  => 'ResultSet',
        'getImportedKeys(String catalog, String schema, String table)'  => 'ResultSet',
        'getExportedKeys(String catalog, String schema, String table)'  => 'ResultSet',
        'getCrossReference( String primaryCatalog, String primarySchema, String primaryTable, String foreignCatalog, String foreignSchema, String foreignTable)'  => 'ResultSet',
        'getTypeInfo()'  => 'ResultSet',
        'getIndexInfo(String catalog, String schema, String table, boolean unique, boolean approximate)'  => 'ResultSet',
        'supportsResultSetType(int type)'  => 'boolean',
        'supportsResultSetConcurrency(int type, int concurrency)'  => 'boolean',
        'ownUpdatesAreVisible(int type)'  => 'boolean',
        'ownDeletesAreVisible(int type)'  => 'boolean',
        'ownInsertsAreVisible(int type)'  => 'boolean',
        'othersUpdatesAreVisible(int type)'  => 'boolean',
        'othersDeletesAreVisible(int type)'  => 'boolean',
        'othersInsertsAreVisible(int type)'  => 'boolean',
        'updatesAreDetected(int type)'  => 'boolean',
        'deletesAreDetected(int type)'  => 'boolean',
        'insertsAreDetected(int type)'  => 'boolean',
        'supportsBatchUpdates()'  => 'boolean',
        'getUDTs(String catalog, String schemaPattern, String typeNamePattern, int[] types)'  => 'ResultSet',
        'getConnection()'  => 'Connection',
        'supportsSavepoints()'  => 'boolean',
        'supportsNamedParameters()'  => 'boolean',
        'supportsMultipleOpenResults()'  => 'boolean',
        'supportsGetGeneratedKeys()'  => 'boolean',
        'getSuperTypes(String catalog, String schemaPattern, String typeNamePattern)'  => 'ResultSet',
        'getSuperTables(String catalog, String schemaPattern, String tableNamePattern)'  => 'ResultSet',
        'getAttributes(String catalog, String schemaPattern, String typeNamePattern, String attributeNamePattern)'  => 'ResultSet',
        'supportsResultSetHoldability(int holdability)'  => 'boolean',
        'getResultSetHoldability()'  => 'int',
        'getDatabaseMajorVersion()'  => 'int',
        'getDatabaseMinorVersion()'  => 'int',
        'getJDBCMajorVersion()'  => 'int',
        'getJDBCMinorVersion()'  => 'int',
        'getSQLStateType()'  => 'int',
        'locatorsUpdateCopy()'  => 'boolean',
        'supportsStatementPooling()'  => 'boolean',
    );

    return $self;
}

################################### PACKAGE ####################################
sub sqlsession
# Parse and execute sql statements.  Grammar:
# sqlsession     -> sql_statement* '<EOF>'
# sql_statement  -> stuff ';' '<EOL>'
#             -> stuff '<EOL>' 'go' ( '<EOL>' | '<EOF>' )
#             -> stuff '<EOL>' ';' ( '<EOL>' | '<EOF>' )
#             -> stuff '<EOF>'
# Display prompts if session is interactive.
# @param aFh is the input stream containing the sql statements.
# @return false if error getting connection
{
    my ($self, $aFh, $fn) = @_;

#printf STDERR "%s[sqlsession]: reading from file '%s'\n", $pkgname, $fn;
#printf STDERR "%s[sqlsession]: aFh is a '%s'\n", $pkgname, ref($aFh);

    if (!$self->sql_init_connection()) {
        printf STDERR "%s:[sqlsession]:  cannot get a database connection:  ABORT\n", $pkgname;
        return 0;
    }

    my $sqlbuf = "";
    my $lbuf = "";

    print $self->getPrompt();

    while ($lbuf = <$aFh>)
    {
        #discard comments:
        #TODO:  handle /* */ C-style comments.
        if ($lbuf =~ /^[ \t\f]*--/) {
            #prevent comments from being "executed" by deleting any semi-colons at EOI:
            $lbuf =~ s/;[;\s]*$//;
        } 
        
        #local command?
        if ($self->localCommand($lbuf)) {
            print $self->getPrompt();
            $sqlbuf = "";    #clear the buffer:
            next;
        }

        #append the buffer:
        $sqlbuf .= $lbuf;

        #if it is time to execute the buffer ...
        if ($sqlbuf =~ /;[;\s]*$/) {
            #... then remove the semi-colon:
            $sqlbuf =~ s/;[;\s]*$//;

            #if the buffer has something in it, then send it to the database:
            if ($sqlbuf !~ /^\s*$/) {
                $self->sql_exec($sqlbuf);

                #display the results:
            }

            #in any case, zero the buffer:
            $sqlbuf = "";
        }

        print $self->getPrompt();
    }

    $self->sql_close_connection();

    return 1;
}

sub sql_exec
# Execute a single sql statement.
# @param sqlbuf is the buffer containing the input.
# return true (1) on success
{
    my ($self, $sqlbuf) = @_;

    #ensure no semi-colon(s) at end of buffer:
    $sqlbuf =~ s/;[;\s]*$//;

    printf STDERR "sql_exec: buf='%s'\n", $sqlbuf if ($DEBUG);

    my $stmt = undef;
    my $con  = $self->getConnection();

    eval {
        $stmt = $con->createStatement();
        #mStatement = mConnection.createStatement();

        my $results = undef;
        #java.sql.ResultSet results = null;

        my $updateCount = -1;

        printf STDERR "sql_exec: BEGIN exceute...\n" if ($DEBUG);

        #if we have results...
        if ($stmt->execute($sqlbuf)) {
            printf STDERR "\tsql_exec:  get results...\n" if ($DEBUG);
            $results = $stmt->getResultSet();
            printf STDERR "\tsql_exec:  display results...\n" if ($DEBUG);
            $self->fastDisplayResultSet($results);
        } else {
            #no results - see if we have an update count
            printf STDERR "\tsql_exec:  no results...get update count\n" if ($DEBUG);
            $updateCount = $stmt->getUpdateCount();

            #if we have an update count...
            if ($updateCount != -1) {
                printf "update count=%d\n", $updateCount;
            }
        }
    };
    printf STDERR "sql_exec: END exceute.\n" if ($DEBUG);

    if ($@) {
        if (Inline::Java::caught("java.lang.Exception")) {
            my $xcptn = $@;
            (my $xcptnName = $xcptn->toString()) =~ s/:.*//;

            if ( isSqlException($xcptnName) ) {
                printf STDERR "%s[sql_exec]: %s\n", __PACKAGE__, $xcptn->getMessage();
                #dump the buffer:
                printf STDERR "Buffer Contents:\n%s\n", $sqlbuf;
            } else {
                #java exception, but not an java.sql exception:
                printf STDERR "%s[sql_exec]: ", __PACKAGE__;
                $xcptn->printStackTrace();
            }
        } else {
            #not a java exception:
            printf STDERR "%s[sql_exec]: eval FAILED:  %s\n", __PACKAGE__, $@;
        }
        return 0;
    }

    return 1;    #success
}

sub displayXmlResults
#we get a list of lists as input.  The first row containes the column names.
#row elements may have undef values, in which case we do not display them
#(this is the "absent rows" method in the spec).
{
    my ($self, $tblname, $hdref, $rows) = @_;

    $tblname = "UNKNOWN_TABLE" if ($tblname eq "");

    my $nrows = $#{$rows};

    my $indentlevel = 0;
    my $indentstr = " " x 2;
    my $indent = $indentstr x $indentlevel;

    printf "%s<%s>\n", $indent, $tblname;
    $indentlevel++; $indent = $indentstr x $indentlevel;

    #deref header row:
    my (@headers) = @$hdref;

#printf STDERR "nrows=%d headers=(%s)\n", $nrows, join(',', @headers);

    #foreach row of data:
    for (my $ii = 0; $ii <= $nrows; $ii++) {
        printf "%s<row>\n", $indent;
        $indentlevel++; $indent = $indentstr x $indentlevel;

        my $rref = $$rows[$ii];
        #foreach column in the row:
        for (my $jj = 0; $jj <= $#$rref; $jj++) {
            #display the row unless it was SQL NULL:
            if (defined($$rref[$jj])) {
                printf "%s<%s>%s</%s>\n", $indent, $headers[$jj], $$rref[$jj], $headers[$jj];
            }
        }

        $indentlevel--; $indent = $indentstr x $indentlevel;
        printf "%s</row>\n", $indent;
    }

    $indentlevel--; $indent = $indentstr x $indentlevel;
    printf "%s</%s>\n", $indent, $tblname;
}

sub fastDisplayResultSet
# this version is optimized for displaying large datasets without need for column exclude feature.
# if -nooutput arg, then process but do not display.
# return 1 if successful.
{
    my ($self, $rset) = @_;

    return 0 unless defined($rset);

    #this is a constant from the metadata for a given resultSet:
    my $m        = $rset->getMetaData();
    my $colcnt   = $m->getColumnCount();

    my $tableName = &getTableName($rset);

    printf STDERR "getHeaderSetting=%d\n", $self->getHeaderSetting() if ($DEBUG);

    #we need headers to tag xml elements - make sure they are turned on:
    $self->setHeaderSetting(1) if ($self->getXmlDisplay());

    #save column headers unless we are not displaying::
    my @headerRow = ();
    if ($self->getHeaderSetting()) {
        @headerRow = (1..$colcnt);
        @headerRow = map {
            $m->getColumnLabel($_);
        } @headerRow;
    }

    #clever way to calculate the number of rows we have.
    #but will it works with all drivers? RT 2/13/13
    $rset->last();
    my $nrows = $rset->getRow();
    $rset->beforeFirst();

    my @datarows = ();
    $#datarows = $nrows-1;    #allocate the array to hold the results

    my $dot = 0;
    @datarows = map {
        ++$dot;
        print STDERR "." if (!$QUIET && !($dot % 1000));

        $rset->next();

        my @data = (1..$colcnt);
        @data = map {
            $rset->getString($_);
        } @data;

        \@data;    #result of calculation is an array ref.
    } @datarows;

    print STDERR "\n" if (!$QUIET && $dot >= 1000);

    if ($self->suppressOutput) {
        printf STDERR "%s: INFO: supressing display of %d query results (-nooutput specified).\n", $self->progName(), $dot;
        return 1;
    }

    ########
    #XML/SQL if set:
    ########
    if ($self->getXmlDisplay()) {
        return $self->displayXmlResults($tableName, \@headerRow, \@datarows);
    }

    #for a normal (non-xml) display, we have to loop through the results to set max column width.
    my (@sizes) = ();
    if ($self->getHeaderSetting()) {
        for (\@headerRow, @datarows) {
            &setMaxColumnSizes(\@sizes, $_);
        }
    } else {
        for (@datarows) {
            &setMaxColumnSizes(\@sizes, $_);
        }
    }

    #generate a format spec based on display sizes:
    my $fmt = "|";
    my $total = 0;
    for my $sz (@sizes) {
        $fmt .= "%-" . "$sz" . "s|";
        $total +=  $sz;
    }

    #create a row divider:
    my $divider =  "+" . "-" x ($#sizes + $total) . "+" . "\n";

#printf STDERR "fmt='%s' divider=\n%s\n", $fmt, $divider;

    my $rowref = undef;

    #######
    #column headers:
    #######
    if ($self->getHeaderSetting()) {
        print $divider;
        printf $fmt. "\n", @headerRow;
        print $divider;
    }

    {
        # since we expect to have data with newlines in it, we turn off
        # "Newline in left-justified string for printf ..." warnings for this block only:

        no warnings 'printf';

        #display data:
        while (defined($rowref =  shift(@datarows))) {
            printf $fmt. "\n", map { defined($_) ? $_ : "(NULL)" } @{$rowref};
            #printf $fmt. "\n", @{$rowref};
        }
        print $divider if ($self->getHeaderSetting());
    }

    return 1;    #success
}

sub displayResultSet
# display resultSet <rset>
# note:  this version is used in the table & schema commands and
#        requires <colmap> list to filter the column display.
{
    my ($self, $rset, @colmap) = @_;

    return 0 unless defined($rset);

    #we first make a pass to get all the rows into memory:
    my @allrows = ();
    
    printf "getHeaderSetting=%d\n", $self->getHeaderSetting() if ($DEBUG);

    #we need headers to tag xml elements - make sure they are turned on:
    $self->setHeaderSetting(1) if ($self->getXmlDisplay());

    #save column headers unless we are not displaying::
    push @allrows, [&getColumns($rset, @colmap)] if ($self->getHeaderSetting());

    my $tableName = &getTableName($rset);

    #save data rows:
    my $dot = 0;
    while ($rset->next()) {
        ++$dot;
        push @allrows, getRow($rset, $self->getXmlDisplay(), @colmap);
        print STDERR "." if (!$QUIET && !($dot % 1000));
    }
    print STDERR "\n" if (!$QUIET && $dot >= 1000);

    ########
    #XML/SQL if set:
    ########
    if ($self->getXmlDisplay()) {
        my $hdref = shift @allrows;
        return $self->displayXmlResults($tableName, $hdref, \@allrows);
    }

    #next, we iterate through the rows to set the max column size:
    my (@sizes) = ();
    for my $rowref (@allrows) {
        &setMaxColumnSizes(\@sizes, $rowref);
    }

    #generate a format spec based on display sizes:
    my $fmt = "|";
    my $total = 0;
    for my $sz (@sizes) {
        $fmt .= "%-" . "$sz" . "s|";
        $total +=  $sz;
    }

    #create a row divider:
    my $divider =  "+" . "-" x ($#sizes + $total) . "+" . "\n";

#printf STDERR "fmt='%s' divider=\n%s\n", $fmt, $divider;

    my $rowref = undef;

    #######
    #column headers:
    #######
    if ($self->getHeaderSetting()) {
        $rowref =  shift(@allrows);
        print $divider;
        printf $fmt. "\n", @{$rowref};
        print $divider;
    }


    {
        # since we expect to have data with newlines in it, we turn off
        # "Newline in left-justified string for printf ..." warnings for this block only:

        no warnings 'printf';

        #display data:
        while (defined($rowref =  shift(@allrows))) {
            printf $fmt. "\n", @{$rowref};
        }
        print $divider if ($self->getHeaderSetting());
    }

    return 1;    #success
}

# Check and initialize our jdbc driver class.
# @return true if driver is in the CLASSPATH
sub check_driver
{
    my ($self) = @_;

#note - this pulls in JDBC.  we use require so we can set our CLASSPATH
#before loading the inline java packages:
require JDBC;
require Inline::Java;

    #initialize our driver class:
    eval {
        JDBC->load_driver($self->jdbcDriver());
    };

    if ($@) {
        if (Inline::Java::caught("java.lang.Exception")) {
            my $xcptn = $@;
            (my $xcptnName = $xcptn->toString()) =~ s/:.*//;

            if ( $xcptnName =~ /ClassNotFoundException/ ) {
                #dump the buffer:
                printf STDERR "%s[check_driver]:  JDBC->load_driver(%s): '%s'\n", __PACKAGE__, $self->jdbcDriver(), $xcptn->getMessage();
            } else {
                #java exception, but not ClassNotFoundException:
                printf STDERR "%s[check_driver]: JDBC->load_driver(%s): ", __PACKAGE__, $self->jdbcDriver();
                $xcptn->printStackTrace();
            }
        } else {
            #not a java exception:
            printf STDERR "%s[sql_exec]: eval FAILED:  %s\n", __PACKAGE__, $@;
        }
        return 0;
    }

    return 1;
}

sub sql_init_connection
# open the jdbc connection.
# return true if successful.
{
    my ($self) = @_;

    #make sure currentl connection is closed:
    $self->sql_close_connection();

    printf STDERR "jdbcDriver='%s getJdbcUrl='%s' user='%s' password='%s'\n",
        $self->jdbcDriver(), $self->getJdbcUrl(), $self->user(), $self->password() if ($DEBUG);

    #try to get a connection:
    eval {
        $self->setConnection(JDBC->getConnection($self->getJdbcUrl(), $self->user(), $self->password()));
        #mConnection = java.sql.DriverManager.getConnection(mURL, mUSER, mPASSWORD);

        #also set a handle for DatabaseMetaData:
        $self->setMetaData( $self->getConnection()->getMetaData() );

        #get DatabaseProductName from meta data:
        $self->setDatabaseProductName( $self->getMetaData()->getDatabaseProductName() );

        if ($self->getDatabaseProductName() =~ /MySQL/i ) {
            $self->setIsMysql(1);
            $self->setPrompt("mysql> ") unless (defined($self->userSuppliedPrompt()));

            #set database name from connection url:  relies on $self->getDatabaseProductName()):
            $self->setDatabaseName( &getDbnameFromUrl($self->getJdbcUrl()) );
        } elsif ($self->getDatabaseProductName() =~ /Oracle/i ) {
            $self->setIsOracle(1);
            $self->setPrompt("oracle> ") unless (defined($self->userSuppliedPrompt()));

            #the database name is really the "schema" name in oracle.
            $self->setDatabaseName( $self->user() );
        } elsif ($self->getDatabaseProductName() =~ /Firebird/i ) {
            $self->setIsFirebird(1);
            $self->setPrompt("firebird> ") unless (defined($self->userSuppliedPrompt()));
            #$self->setDatabaseName( &getDbnameFromUrl($self->getJdbcUrl()) );
        } elsif ($self->getDatabaseProductName() =~ /Derby/i ) {
            $self->setIsDerby(1);
            $self->setPrompt("derbydb> ") unless (defined($self->userSuppliedPrompt()));
        }

        $self->setDatabaseProductName( $self->getMetaData()->getDatabaseProductName() );
    };

    if ($@) {
        if (Inline::Java::caught("java.lang.Exception")) {
            my $xcptn = $@;
            (my $xcptnName = $xcptn->toString()) =~ s/:.*//;

            if ( isSqlException($xcptnName) ) {
                printf STDERR "%s[sql_init_connection]: SQL Connection FAILED: '%s'\n", __PACKAGE__, $xcptn->getMessage();
            } else {
                printf STDERR "%s[sql_init_connection]: SQL Connection FAILED: ", __PACKAGE__;
                $xcptn->printStackTrace();
            }
        } else {
            #not a java exception:
            printf STDERR "%s[sql_init_connection]: eval FAILED:  %s\n", __PACKAGE__, $@;
        }
        return 0;
    }

    printf STDERR "isOracle=%d isMySql=%d isDerby=%d isFirebird=%d\n", $self->getIsOracle(), $self->getIsMysql(), $self->getIsDerby(), $self->getIsFirebird() if ($DEBUG);

    #init or re-init our tables object:
    $self->setSqlTables( new sqlpj::sqltables($self->getMetaData(), $self->getDatabaseName()) );

    return 1;    #success
}

sub sql_close_connection
# close the jdbc connection.
# true if successful
{
    my ($self) = @_;

    return unless defined($self->getConnection());

    #close connection: #don't care if this fails
    eval {
        $self->getConnection()->close();
    };

    if ($@) {
        if (Inline::Java::caught("java.lang.Exception")) {
            my $xcptn = $@;
            (my $xcptnName = $xcptn->toString()) =~ s/:.*//;

            if ( isSqlException($xcptnName) ) {
                printf STDERR "%s[sql_close_connection]: '%s'\n", __PACKAGE__, $xcptn->getMessage();
            } else {
                printf STDERR "%s[sql_close_connection]: ", __PACKAGE__;
                $xcptn->printStackTrace();
            }
        } else {
            #not a java exception:
            printf STDERR "%s[sql_close_connection]: eval FAILED:  %s\n", __PACKAGE__, $@;
        }
        return 0;
    }

    return 1;    #success
}

######
#local command processing
######

sub localCommand
#process a local command:
#    help
#    info
{
    my ($self, $buf) = @_;

    #trim buf:
    $buf =~ s/^\s+//;
    $buf =~ s/[;\s]*$//;

    my $handled = 0;

    if ($buf =~ /^help/i) {
        $buf =~ s/help\s*//i;
        $handled = $self->helpCommand($buf);
    } elsif ($buf  =~ /^echo/i) {
        $buf =~ s/echo\s*//i;
        $handled = $self->echoCommand($buf);
    } elsif ($buf  =~ /^set/i) {
        $buf =~ s/set\s*//i;
        $handled = $self->setCommand($buf);
    } elsif ($buf  =~ /^use/i) {
        $buf =~ s/use\s*//i;
        $handled = $self->useCommand($buf);
    } elsif ($buf  =~ /^show/i) {
        $buf =~ s/show\s*//i;
        $handled = $self->showCommand($buf);
    } elsif ($buf  =~ /^schema/i) {
        $buf =~ s/tables\s*//i;
        $handled = $self->showSchemaCommand($buf);
    } elsif ($buf  =~ /^tables/i) {
        $buf =~ s/tables\s*//i;
        $handled = $self->showTablesCommand($buf);
    } elsif ($buf  =~ /^table/i) {
        $buf =~ s/table\s*//i;
        $handled = $self->showTableCommand($buf);
    }

    return $handled;
}

sub helpCommand
#return 1 if we handled the command, otherwise 0.
{
    my ($self, $args) = @_;

    print <<"!";
Local commands are:
 help                 - show this message.
 echo [text]          - display <text>.  Useful for scripts to insert documentation.

 tables [db]          - show information about tables in <db>, defaults to connection db.
                        (similar to "show tables" in mysql).
 table name [db]      - show information about table <name> in <db>, defaults to connection db.
                        (can also use "describe <table>" in mysql & oracle).
                        (can also use "show columns from <table>" in mysql).

 schema               - display a consise schema of the database.

 show conn[ection]    - show jdbc connection properties, including product & version
 show create [table]  - generate sql to create all tables, or a single table.
 show ind[ices] table - show the indices for a single table
 show db              - show db name
 show metadata        - show jdbc metadata (long)

 set csv [on]         - output tables as comma-separated data.
 set csv off          - turn off csv output display.

 set headers [on]     - output table header rows with data
 set headers off      - turn off output table headers

 set xml [on]         - output result-sets in sql/xml form.
 set xml off          - turn off xml output of result-sets.

 NOTES on `set':      Do not include `;' in a local set commands, to avoid interpretation as SQL.
                      Unrecognized `set' commands (e.g. Derby "SET SCHEMA") are also passed to SQL.
!

#not yet implemented:
#help [command]       - show this message, or help about specific <command>.
#dump [table] [filename]
#                     - dump all or named table to stdout or <filename>

    return 1;    #we processed the help command.
}

sub echoCommand
#return 1 if we handled the command, otherwise 0.
{
    my ($self, $text) = @_;

    printf "%s\n", $text;

    return 1;    #we processed the echo command.
}

sub showCommand
#show meta-info about the database and/or tables
#return 1 if we handled the command, otherwise 0.
{
    my ($self, $buf) = @_;

    #trim buf:
    $buf =~ s/^\s+//;
    $buf =~ s/[;\s]*$//;

    if ($buf =~ /^conn/i) {
        $buf =~ s/conn[^\s]*\s*//i;
        $self->showConnection($buf);
    } elsif ($buf  =~ /^create/i) {
        $buf =~ s/create\s*//i;
        $self->showCreate($buf);
    } elsif ($buf  =~ /^db/i) {
        $buf =~ s/db\s*//i;
        $self->showDataBase($buf);
    } elsif ($buf  =~ /^ind/i) {
        $buf =~ s/ind[^\s]*\s*//i;
        $self->showIndicesCommand($buf);
    } elsif ($buf  =~ /^meta/i) {
        $buf =~ s/meta[^\s]*\s*//i;
        $self->showMetaData($buf);
    } else {
        return 0;    #not a local command
    }

    return 1;    #we processed the show command locally.
}

sub setCommand
#set display or other options for the cli.
#return 1 if we handled the command, otherwise 0.
{
    my ($self, $buf) = @_;

    if ($buf =~ /;/) {
        #we assume it is a database command and pass it to sql:
        return 0;
    } elsif ($buf =~ /^xml/i) {
        $buf =~ s/xml\s*//i;
        my $howsay = "remains";
        if ($buf eq "" || $buf =~ /^on/i) {
            if (!$self->getXmlDisplay()) {
                $self->setXmlDisplay(1);
                $self->setHeaderSetting(1);    #xml display requires column headings.
                $howsay = "is now";
            }
        } elsif ($buf =~ /^off/i) {
            if ($self->getXmlDisplay()) {
                $self->setXmlDisplay(0);
                $howsay = "is now";
            }
        } else {
            printf STDERR "%s: ERROR: set xml '%s' not recognized - ignored.\n", $pkgname, $buf;
        }
        printf STDOUT "SQL/XML result-sets display %s %s\n",
            $howsay, $self->getXmlDisplay()? "ON" : "OFF" unless($QUIET);
    } elsif ($buf  =~ /^csv/i) {
        $buf =~ s/csv\s*//i;
        my $howsay = "remains";
        if ($buf eq "" || $buf =~ /^on/i) {
            if (!$self->getCsvDisplay()) {
                $self->setCsvDisplay(1);
                $howsay = "is now";
            }
        } elsif ($buf =~ /^off/i) {
            if ($self->getCsvDisplay()) {
                $self->setCsvDisplay(0);
                $howsay = "is now";
            }
        } else {
            printf STDERR "%s: ERROR: set csv '%s' not recognized - ignored.\n", $pkgname, $buf;
        }

        printf STDOUT "CSV output %s %s\n",
            $howsay, $self->getCsvDisplay()? "ON" : "OFF" unless($QUIET);
    } elsif ($buf  =~ /^headers/i) {
        $buf =~ s/headers\s*//i;
        my $howsay = "remains";
        if ($buf eq "" || $buf =~ /^on/i) {
            if (!$self->getHeaderSetting()) {
                $self->setHeaderSetting(1);
                $howsay = "is now";
            }
        } elsif ($buf =~ /^off/i) {
            if ($self->getHeaderSetting()) {
                $self->setHeaderSetting(0);
                $howsay = "is now";
            }
        } else {
            printf STDERR "%s: ERROR: set headers '%s' not recognized - ignored.\n", $pkgname, $buf;
        }

        printf STDOUT "HEADER output %s %s\n",
            $howsay, $self->getHeaderSetting()? "ON" : "OFF" unless($QUIET);
    } else {
        #not an internal set - maybe it is sql:
        return 0;
    }

    return 1;    #we found and processed a set command
}

sub showCreate
#generate sql to create one or all tables
#returns non-zero if error (called to process show create).
{
    my ($self, $buf) = @_;

    #get a copy of current tables object:
    my $tables = $self->getSqlTables();
    my $tbl = undef;
    my $nerrs = 0;

    #get table name if present:
    my ($tblname) = $buf;

#printf STDERR "showCreate: tblname='%s'\n", $tblname;

    #limit to one table?
    if ($tblname ne "") {
        if (!defined($tbl = $tables->tableByName($tblname))) {
            printf STDERR "%s [showCreate]:  table '%s' not found\n", $pkgname, $tblname;
            return 1;    #ERROR
        }

        #otherwise:
        return $tbl->showCreateSql();
    }

    #otherwise, get list of tables and show create for each table:
    for $tbl ($tables->allTables()) {
#printf STDERR "tbl=%s\n", $tbl;
        $tbl->showCreateSql();
    }

    return $nerrs;
}

sub showDataBase
#show database name
{
    my ($self, $buf) = @_;

    if ($self->getIsOracle()) {
        printf "%s\n", $self->getDatabaseName();
    } else {
        $self->sql_exec("select DATABASE()");
    }
}

sub showIndicesCommand
#implement the show indices command, which displays the indices for a single table
#Usage:  show ind[ices] table_name
#return 1 if we handled the command, otherwise 0.
{
    my ($self, $tblname) = @_;
    my $dbname = "";

    my @excludenamesc = (
        "TABLE_CAT",
        "TABLE_SCHEM",
#       "TABLE_NAME",
#       "NON_UNIQUE",
#       "INDEX_QUALIFIER",
#       "INDEX_NAME",
        "TYPE",
#       "ORDINAL_POSITION",
#       "COLUMN_NAME",
#       "ASC_OR_DESC",
        "CARDINALITY",
        "PAGES",
        "FILTER_CONDITION"
    );

#printf STDERR "tblname='%s' dbname='%s'\n", $tblname, $dbname;

    my $dbMetaData = $self->getMetaData();
    my $rsetc = undef;

    eval {
        #########
        #Indicies
        #########
#'getIndexInfo(String catalog, String schema, String table, boolean unique, boolean approximate)'  => 'ResultSet',
        $rsetc = $dbMetaData->getIndexInfo($dbname, "%", $tblname, 0, 0);
    };

    if ($@) {
        if (Inline::Java::caught("java.lang.Exception")) {
            my $xcptn = $@;
            (my $xcptnName = $xcptn->toString()) =~ s/:.*//;

            if ( isSqlException($xcptnName) ) {
                printf STDERR "%s[showIndicesCommand]: SQL Connection FAILED: '%s'\n", __PACKAGE__, $xcptn->getMessage();
            } else {
                printf STDERR "%s[showIndicesCommand]: SQL Connection FAILED: ", __PACKAGE__;
                $xcptn->printStackTrace();
            }
        } else {
            #not a java exception:
            printf STDERR "%s[showIndicesCommand]: eval FAILED:  %s\n", __PACKAGE__, $@;
        }
        return 1;  #we handled the command, even if we did get an exception
    }

    $self->displayResultSet($rsetc, &columnExcludeMap($rsetc, @excludenamesc));
    return 1;
}

sub showTableCommand
#implement the table command, which shows information about a single table
#Usage:  table table_name
#return 1 if we handled the command, otherwise 0.
{
    my ($self, $args) = @_;

    my ($tblname, $dbname) = split(/\s+/, $args);

    if ($self->getIsOracle()) {
        return showTableCommandOracle($self, $tblname, $dbname);
    }

    my @excludenames = (
        "TABLE_CAT",
        "TABLE_SCHEM",
#       "TABLE_NAME",
#       "COLUMN_NAME",
        "DATA_TYPE",
#       "TYPE_NAME",
#       "COLUMN_SIZE",
        "BUFFER_LENGTH",
#       "DECIMAL_DIGITS",
#       "NUM_PREC_RADIX",
#       "NULLABLE",
        "REMARKS",
#       "COLUMN_DEF",
        "SQL_DATA_TYPE",
        "SQL_DATETIME_SUB",
        "CHAR_OCTET_LENGTH",
#       "ORDINAL_POSITION",
        "IS_NULLABLE",
    );

    my @excludenamesb = (
        "TABLE_CAT",
        "TABLE_SCHEM",
#       "TABLE_NAME",
#       "COLUMN_NAME",
#       "KEY_SEQ",
#       "PK_NAME",
    );

    my @excludenamesc = (
        "TABLE_CAT",
        "TABLE_SCHEM",
#       "TABLE_NAME",
#       "NON_UNIQUE",
#       "INDEX_QUALIFIER",
#       "INDEX_NAME",
        "TYPE",
#       "ORDINAL_POSITION",
#       "COLUMN_NAME",
#       "ASC_OR_DESC",
        "CARDINALITY",
        "PAGES",
        "FILTER_CONDITION"
    );

#printf STDERR "tblname='%s' dbname='%s'\n", $tblname, $dbname;

    my $dbMetaData = $self->getMetaData();
    my $rseta = undef;
    my $rsetb = undef;
    my $rsetc = undef;

    eval {
        #######
        #column info
        #######
#'getColumns(String catalog, String schemaPattern, String tableNamePattern, String columnNamePattern)'  => 'ResultSet',
        $rseta = $dbMetaData->getColumns($dbname, "%", $tblname, "%");


#my $rseta_stmt =  $rseta->getStatement();
#printf "STATEMENT FOR getColumns() resultSet='%s'\n", defined($rseta_stmt)? "defined" : "undefined";
#my $rseta_stmt =  $rseta->getType();
#printf "TYPE FOR getColumns() resultSet='%s'\n", defined($rseta_stmt)? $rseta_stmt : "undefined" ;

        ########
        #primary keys:
        ########
#'getPrimaryKeys(String catalog, String schema, String table)'  => 'ResultSet',
        $rsetb = $dbMetaData->getPrimaryKeys($dbname, "%", $tblname);
#$rsetb_stmt =  $rsetb->getStatement();
#printf "STATEMENT FOR getPrimaryKeys()='%s'\n", $rsetb_stmt->toString();

        #########
        #Indicies
        #########
#'getIndexInfo(String catalog, String schema, String table, boolean unique, boolean approximate)'  => 'ResultSet',
        $rsetc = $dbMetaData->getIndexInfo($dbname, "%", $tblname, 0, 0);
    };

    if ($@) {
        if (Inline::Java::caught("java.lang.Exception")) {
            my $xcptn = $@;
            (my $xcptnName = $xcptn->toString()) =~ s/:.*//;

            if ( isSqlException($xcptnName) ) {
                printf STDERR "%s[showTableCommand]: '%s'\n", __PACKAGE__, $xcptn->getMessage();
            } else {
                printf STDERR "%s[showTableCommand]: ", __PACKAGE__;
                $xcptn->printStackTrace();
            }
        } else {
            #not a java exception:
            printf STDERR "%s[showTableCommand]: eval FAILED:  %s\n", __PACKAGE__, $@;
        }
        return 1;  #we handled the command, even if we did get an exception
    }

    $self->displayResultSet($rseta, &columnExcludeMap($rseta, @excludenames ));
    $self->displayResultSet($rsetb, &columnExcludeMap($rsetb, @excludenamesb));
    $self->displayResultSet($rsetc, &columnExcludeMap($rsetc, @excludenamesc));

    return 1;
}

sub getTableAttributes
#used by show schema command to get column name and type for a single table
#return 1 if we handled the command, otherwise 0.
{
    my ($self, $dbname, $tblname) = @_;

    my @excludenames = (
        "TABLE_CAT",
        "TABLE_SCHEM",
        "TABLE_NAME",
#       "COLUMN_NAME",
        "DATA_TYPE",
#       "TYPE_NAME",
#       "COLUMN_SIZE",
        "BUFFER_LENGTH",
        "DECIMAL_DIGITS",
        "NUM_PREC_RADIX",
        "NULLABLE",
        "REMARKS",
        "COLUMN_DEF",
        "SQL_DATA_TYPE",
        "SQL_DATETIME_SUB",
        "CHAR_OCTET_LENGTH",
        "ORDINAL_POSITION",
        "IS_NULLABLE",
    );

#printf STDERR "getTableAttributes: dbname='%s' tblname='%s'\n", $dbname, $tblname;

    my $dbMetaData = $self->getMetaData();
    my $rseta = undef;

    eval {
        #######
        #column info
        #######
#'getColumns(String catalog, String schemaPattern, String tableNamePattern, String columnNamePattern)'  => 'ResultSet',
        $rseta = $dbMetaData->getColumns($dbname, "%", $tblname, "%");
    };

    if ($@) {
        if (Inline::Java::caught("java.lang.Exception")) {
            my $xcptn = $@;
            (my $xcptnName = $xcptn->toString()) =~ s/:.*//;

            if ( isSqlException($xcptnName) ) {
                printf STDERR "%s[showTableCommand]: '%s'\n", __PACKAGE__, $xcptn->getMessage();
            } else {
                printf STDERR "%s[showTableCommand]: ", __PACKAGE__;
                $xcptn->printStackTrace();
            }
        } else {
            #not a java exception:
            printf STDERR "%s[showTableCommand]: eval FAILED:  %s\n", __PACKAGE__, $@;
        }
        return 1;  #we handled the command, even if we did get an exception
    }

    #foreach result set ...
    my @allrows = ();
    while ($rseta->next()) {
        push @allrows, getRow($rseta, 0, columnExcludeMap($rseta, @excludenames));
    }

    my @tableColumnDescriptions = ();

    for (@allrows) {
        my ($name, $type, $size) = @{$_};

        push @tableColumnDescriptions, sprintf("%s[%s%d]", $name, $type, $size);
    }

    return ($tblname, \@tableColumnDescriptions);
}

sub showSchemaCommand
#implement the schema command, which displays a consise schema of the database.
#return 1 if we handled the command, otherwise 0.
{
    my ($self, $dbname) = @_;

    my $dbMetaData = $self->getMetaData();

#   if (!$self->getIsMysql()) {
#       printf STDERR "sorry, schema command is only implemented for mysql.\n";
#       return 1;
#   }

    my $rseta = undef;
    my $rsetb = undef;
    my $rsetc = undef;

    #this is passed to displayResultSet() and is probably different for every db.
    my @excludenames = (
#       "TABLE_CAT",   #keep
        "TABLE_SCHEM",
#       "TABLE_NAME",  #keep
        "TABLE_TYPE",
        "REMARKS",
    );

#getTables(String catalog, String schemaPattern, String tableNamePattern, String types[])  => ResultSet,
#getSuperTables(String catalog, String schemaPattern, String tableNamePattern)  => ResultSet,
#getSuperTypes(String catalog, String schemaPattern, String typeNamePattern)  => ResultSet,

#ResultSet tables = metaData.getTables( null, null, "customer", new String[]{"TABLE"});

    #show the tables from the named database:
    eval {
        $rseta = $dbMetaData->getTables(undef, undef, "%", undef);
    };

    if ($@) {
        if (Inline::Java::caught("java.lang.Exception")) {
            my $xcptn = $@;
            (my $xcptnName = $xcptn->toString()) =~ s/:.*//;

            if ( isSqlException($xcptnName) ) {
                printf STDERR "%s[showTablesCommand]: '%s'\n", __PACKAGE__, $xcptn->getMessage();
            } else {
                printf STDERR "%s[showTablesCommand]: ", __PACKAGE__;
                $xcptn->printStackTrace();
            }
        } else {
            #not a java exception:
            printf STDERR "%s[showTablesCommand]: eval FAILED:  %s\n", __PACKAGE__, $@;
        }
        return 1;  #we handled the command, even if we did get an exception
    }

    #foreach table, show attributes:
    #$self->displayResultSet($rseta, &columnExcludeMap($rseta, @excludenames));
    my @allrows = ();
    while ($rseta->next()) {
        push @allrows, getRow($rseta, 0, columnExcludeMap($rseta, @excludenames));
    }

    my @tables = ();
    $dbname = undef;  #the name passed in is wrong

    for (@allrows) {
        my @theRow = @{$_};

#printf STDERR "showSchemaCommand: theRow=(%s)\n", join('|', @theRow);

        $dbname = $theRow[0] unless ($dbname);
        push @tables, $theRow[1];
    }

    my @tablesWithAttributes = ();
    for (@tables) {
        push @tablesWithAttributes, [$self->getTableAttributes($dbname, $_)];
    }

    #now we can display the tables the way we want:
    $self->displaySchemaTables($dbname, @tablesWithAttributes);

    return 1;
}

sub displaySchemaTables
{
    my ($self, $dbname, @tablesWithAttributes) = @_;

    printf "Concise Schema for database '%s'\n", $dbname;

    for (@tablesWithAttributes) {
        my ($tableName, $attrRef) = @{$_};
        my @colAttributes = @{$attrRef};

        printf "\n%s:(%s)\n", $tableName, join(', ', @colAttributes);
    }
}

sub showTablesCommand
#implement the tables command, which shows information about tables
#return 1 if we handled the command, otherwise 0.
{
    my ($self, $dbname) = @_;

    my $dbMetaData = $self->getMetaData();

    if ($self->getIsOracle()) {
        return showTablesCommandOracle($self, $dbname);
    }

    my $rseta = undef;
    my $rsetb = undef;
    my $rsetc = undef;

    my @excludenames = (
        "TABLE_CAT",
        "TABLE_SCHEM",
#       "TABLE_NAME",  #keep
#       "TABLE_TYPE",  #keep
        "REMARKS",
    );

#getTables(String catalog, String schemaPattern, String tableNamePattern, String types[])  => ResultSet,
#getSuperTables(String catalog, String schemaPattern, String tableNamePattern)  => ResultSet,
#getSuperTypes(String catalog, String schemaPattern, String typeNamePattern)  => ResultSet,

#ResultSet tables = metaData.getTables( null, null, "customer", new String[]{"TABLE"});

    #show the tables from the named database:
    eval {
        $rseta = $dbMetaData->getTables(undef, undef, "%", undef);
        #my @list = ("TABLE","SYSTEM TABLE","VIEW");
        #@list = ("TABLE");
        #$rseta = $dbMetaData->getTables(undef, undef, "%", [@list]);
        #$rseta = $dbMetaData->getTables(undef, undef, "%", ["TABLE","SYSTEM TABLE","VIEW"]);
        #$rseta = $dbMetaData->getTables(undef, undef, "%", ["TABLE"]);
        #$rseta = $dbMetaData->getTables($dbname, "%", "%", []);
        $rsetb = $dbMetaData->getSuperTables(undef, "%", "%");
        #$rsetc = $dbMetaData->getSuperTypes($dbname, "%", "%");
    };

    if ($@) {
        if (Inline::Java::caught("java.lang.Exception")) {
            my $xcptn = $@;
            (my $xcptnName = $xcptn->toString()) =~ s/:.*//;

            if ( isSqlException($xcptnName) ) {
                printf STDERR "%s[showTablesCommand]: '%s'\n", __PACKAGE__, $xcptn->getMessage();
            } else {
                printf STDERR "%s[showTablesCommand]: ", __PACKAGE__;
                $xcptn->printStackTrace();
            }
        } else {
            #not a java exception:
            printf STDERR "%s[showTablesCommand]: eval FAILED:  %s\n", __PACKAGE__, $@;
        }
        return 1;  #we handled the command, even if we did get an exception
    }

    $self->displayResultSet($rseta, &columnExcludeMap($rseta, @excludenames));
    $self->displayResultSet($rsetb, &columnExcludeMap($rsetb, @excludenames));
    return 1;
}

sub showTablesCommandOracle
#implement the tables command for ORACLE databases
{
    my ($self, $dbname) = @_;

    $self->sql_exec("select table_name from USER_CATALOG");

    return 1;
}

sub showTableCommandOracle
#implement the table command for oracle.
#Usage:  table table_name
#return 1 if we handled the command, otherwise 0.
{
    my ($self, $tblname, $dbname) = @_;

    my $query = sprintf(
                    "select TABLE_NAME, COLUMN_NAME, DATA_TYPE from ALL_TAB_COLUMNS where TABLE_NAME = '%s'",
                    $tblname
                );

    $self->sql_exec($query);

    return 1;
}

sub useCommand
#change the database, get new metadata
{
    my ($self, $dbname) = @_;

    if (!defined($dbname) || $dbname eq "") {
        printf STDERR "%s: use:  you must supply a database name\n", $pkgname;
        return;
    }

    my $oldurl = $self->getJdbcUrl();

    #set connection to use new database name:
    $self->setJdbcUrl( &setDbNameInUrl($oldurl, $dbname) );

#printf STDERR "SET DATABASE TO '%s' jdbcurl='%s'\n", $dbname, $self->getJdbcUrl();

#printf STDERR "GET NEW METADATA\n";
    #get metadata for new database:
    if ($self->sql_init_connection()) {
        $self->sql_exec(sprintf("use %s;", $dbname));
    } else {
        #restore old connection url:
        $self->setJdbcUrl($oldurl);
        $self->sql_init_connection();
    }
}

sub showConnection
#show database info
{
    my ($self, $buf) = @_;
    my $func = "";

    my $metafuncs = $self->metaFuncs();

    $func = 'getURL()';
    $self->callMetaFunc($func, $$metafuncs{$func});

    $func = 'getUserName()';
    $self->callMetaFunc($func, $$metafuncs{$func});

    $func = 'getDriverName()';
    $self->callMetaFunc($func, $$metafuncs{$func});

    $func = 'getDriverVersion()';
    $self->callMetaFunc($func, $$metafuncs{$func});

    $func = 'getDatabaseProductName()';
    $self->callMetaFunc($func, $$metafuncs{$func});

    $func = 'getDatabaseProductVersion()';
    $self->callMetaFunc($func, $$metafuncs{$func});
}

sub showMetaData
#show meta-info about the database and/or tables
{
    my ($self, $buf) = @_;

    my $metafuncs = $self->metaFuncs();

    my (@noargkeys)     = grep($_ =~ /\(\)$/, sort keys %$metafuncs);
    my (@yesargkeys)    = grep($_ !~ /\(\)$/, sort keys %$metafuncs);
    my (@boolkeys)      = grep($$metafuncs{$_} eq "boolean", @noargkeys);
    my (@intkeys)       = grep($$metafuncs{$_} eq "int", @noargkeys);
    my (@strkeys)       = grep($$metafuncs{$_} eq "String", @noargkeys);
    my (@resultSetkeys) = grep($$metafuncs{$_} eq "ResultSet", @noargkeys);

    my $divider =  "-" x 56 . "\n";

    for my $kk (@boolkeys) {
        $self->callMetaFunc($kk, $$metafuncs{$kk});
    }

    print $divider;

    for my $kk (@strkeys) {
        $self->callMetaFunc($kk, $$metafuncs{$kk});
    }

    print $divider;

    for my $kk (@intkeys) {
        $self->callMetaFunc($kk, $$metafuncs{$kk});
    }

    print $divider;

    for my $kk (@resultSetkeys) {
        $self->callMetaFunc($kk, $$metafuncs{$kk});
    }

    print $divider;

#printf "yesargkeys=(%s)\n", join(",", @yesargkeys);
    for my $kk (@yesargkeys) {
        printf "%-56s %s\n", $kk, $$metafuncs{$kk};
    }
}

sub callMetaFunc
{
    my ($self, $func, $type) = @_;

    my $dbMetaData = $self->getMetaData();
    my $call = '$dbMetaData->' . "$func";

    my $val = eval($call);
    my $valstr = "$val";

    if ($type eq "boolean") {
        $valstr = ($val ? "true" : "false")
    } elsif ($type eq "int") {
        ;
    } elsif ($type eq "String") {
        ;
    } elsif ($type eq "ResultSet") {
        # dump the result:
        printf "\n%s:\n", $func;
        $self->displayResultSet($val, &columnExcludeMap($val, () ));
        return;
    } elsif ($type eq "Connection") {
        ;
    } else {
        ;
    }

    printf "%-56s %s\n", $func, $valstr;
}

#########
#accessor methods for sqlpjImpl object attributes:
#########

sub getConnection
#return value of Connection
{
    my ($self) = @_;
    return $self->{'mConnection'};
}

sub setConnection
#set value of Connection and return value.
{
    my ($self, $value) = @_;
    $self->{'mConnection'} = $value;
    return $self->{'mConnection'};
}

sub getMetaData
#return value of MetaData
{
    my ($self) = @_;
    return $self->{'mMetaData'};
}

sub setMetaData
#set value of MetaData and return value.
{
    my ($self, $value) = @_;
    $self->{'mMetaData'} = $value;
    return $self->{'mMetaData'};
}

sub getJdbcUrl
#return value of JdbcUrl
{
    my ($self) = @_;
    return $self->{'mJdbcUrl'};
}

sub setJdbcUrl
#set value of JdbcUrl and return value.
{
    my ($self, $value) = @_;
    $self->{'mJdbcUrl'} = $value;
    return $self->{'mJdbcUrl'};
}

sub getDatabaseName
#return value of DatabaseName
{
    my ($self) = @_;
    return $self->{'mDatabaseName'};
}

sub setDatabaseName
#set value of DatabaseName and return value.
{
    my ($self, $value) = @_;
    $self->{'mDatabaseName'} = $value;
    return $self->{'mDatabaseName'};
}

sub getDatabaseProductName
#return value of DatabaseProductName
{
    my ($self) = @_;
    return $self->{'mDatabaseProductName'};
}

sub setDatabaseProductName
#set value of DatabaseProductName and return value.
{
    my ($self, $value) = @_;
    $self->{'mDatabaseProductName'} = $value;
    return $self->{'mDatabaseProductName'};
}

sub getIsOracle
#return value of IsOracle
{
    my ($self) = @_;
    return $self->{'mIsOracle'};
}

sub setIsOracle
#set value of IsOracle and return value.
{
    my ($self, $value) = @_;
    $self->{'mIsOracle'} = $value;
    return $self->{'mIsOracle'};
}

sub getIsMysql
#return value of IsMysql
{
    my ($self) = @_;
    return $self->{'mIsMysql'};
}

sub setIsMysql
#set value of IsMysql and return value.
{
    my ($self, $value) = @_;
    $self->{'mIsMysql'} = $value;
    return $self->{'mIsMysql'};
}

sub getIsDerby
#return value of IsDerby
{
    my ($self) = @_;
    return $self->{'mIsDerby'};
}

sub setIsDerby
#set value of IsDerby and return value.
{
    my ($self, $value) = @_;
    $self->{'mIsDerby'} = $value;
    return $self->{'mIsDerby'};
}

sub getIsFirebird
#return value of IsFirebird
{
    my ($self) = @_;
    return $self->{'mIsFirebird'};
}

sub setIsFirebird
#set value of IsFirebird and return value.
{
    my ($self, $value) = @_;
    $self->{'mIsFirebird'} = $value;
    return $self->{'mIsFirebird'};
}

sub getSqlTables
#return value of SqlTables
{
    my ($self) = @_;
    return $self->{'mSqlTables'};
}

sub setSqlTables
#set value of SqlTables and return value.
{
    my ($self, $value) = @_;
    $self->{'mSqlTables'} = $value;
    return $self->{'mSqlTables'};
}

sub getXmlDisplay
#return value of XmlDisplay
{
    my ($self) = @_;
    return $self->{'mXmlDisplay'};
}

sub setXmlDisplay
#set value of XmlDisplay and return value.
{
    my ($self, $value) = @_;
    $self->{'mXmlDisplay'} = $value;
    return $self->{'mXmlDisplay'};
}

sub getCsvDisplay
#return value of CsvDisplay
{
    my ($self) = @_;
    return $self->{'mCsvDisplay'};
}

sub setCsvDisplay
#set value of CsvDisplay and return value.
{
    my ($self, $value) = @_;
    $self->{'mCsvDisplay'} = $value;
    return $self->{'mCsvDisplay'};
}

sub getHeaderSetting
#return value of HeaderSetting
{
    my ($self) = @_;
    return $self->{'mHeaderSetting'};
}

sub setHeaderSetting
#set value of HeaderSetting and return value.
{
    my ($self, $value) = @_;
    $self->{'mHeaderSetting'} = $value;
    return $self->{'mHeaderSetting'};
}

sub getPrompt
#return value of Prompt
{
    my ($self) = @_;
    return $self->{'mPrompt'};
}

sub setPrompt
#set value of Prompt and return value.
{
    my ($self, $value) = @_;
    $self->{'mPrompt'} = $value;
    return $self->{'mPrompt'};
}

sub jdbcClassPath
#return value of mJdbcClassPath
{
    my ($self) = @_;
    return $self->{'mJdbcClassPath'};
}

sub jdbcDriver
#return value of mJdbcDriver
{
    my ($self) = @_;
    return $self->{'mJdbcDriver'};
}

sub user
#return value of mUser
{
    my ($self) = @_;
    return $self->{'mUser'};
}

sub password
#return value of mPassword
{
    my ($self) = @_;
    return $self->{'mPassword'};
}

sub progName
#return value of mProgName
{
    my ($self) = @_;
    return $self->{'mProgName'};
}

sub pathSeparator
#return value of mPathSeparator
{
    my ($self) = @_;
    return $self->{'mPathSeparator'};
}

sub userSuppliedPrompt
#return value of mUserSuppliedPrompt
{
    my ($self) = @_;
    return $self->{'mUserSuppliedPrompt'};
}

sub metaFuncs
#return value of mMetaFuncs
{
    my ($self) = @_;
    return $self->{'mMetaFuncs'};
}

sub suppressOutput
#return value of mSuppressOutput
{
    my ($self) = @_;
    return $self->{'mSuppressOutput'};
}

#######
#static class methods
#######

sub columnExcludeMap
#return an array map excluding <cnames>.
#in the returned map, 0 => column not selected for display.
{
    my ($rset, @cnames) = @_;

    return () unless defined($rset);

    my (@selected) = ();

#printf STDERR "columnExcludeMap:  #cnames=%d cnames=(%s)\n", $#cnames, join(",", @cnames);

    eval {
        my $m        = $rset->getMetaData();
        my $colcnt   = $m->getColumnCount();

        #if no columns are excluded...
        if ($#cnames < 0) {
            #then return all 1's:
            @selected = ((1) x $colcnt);
#printf STDERR "columnExcludeMap:  RETURN A: selected=(%s)\n", join(",", @selected);
            return @selected;
        }

        #otherwise, exclude columns named in <cnames>:
        for (my $ii = 1; $ii <= $colcnt; $ii++) {
            my $cname = $m->getColumnLabel($ii);
#printf STDERR "columnExcludeMap: grep(%s,(%s))=%d\n", $cname, join(",", @cnames), scalar(grep($cname eq $_, @cnames));

            #exlcude  found   selected
            #      0      0          0
            #      0      1          1
            #      1      0          1
            #      1      1          0

            push @selected, (scalar(grep($cname eq $_, @cnames))? 0 : 1);
        }
    };

    if ($@) {
        if (Inline::Java::caught("java.lang.Exception")) {
            my $xcptn = $@;
            (my $xcptnName = $xcptn->toString()) =~ s/:.*//;

            if ( isSqlException($xcptnName) ) {
                printf STDERR "%s[columnExcludeMap]: '%s'\n", __PACKAGE__, $xcptn->getMessage();
            } else {
                printf STDERR "%s[columnExcludeMap]: ", __PACKAGE__;
                $xcptn->printStackTrace();
            }
        } else {
            #not a java exception:
            printf STDERR "%s[showTableCommand]: eval FAILED:  %s\n", __PACKAGE__, $@;
        }
        return ();  #empty list
    }

#printf STDERR "columnExcludeMap:  RETURN B: selected=(%s)\n", join(",", @selected);
    return @selected;
}

sub getColumns
#return the list of column names for a result set
#we only return the columns numbers in <colmap>.
{
    my ($rset, @colmap) = @_;

    return () unless defined($rset);

    my (@header) = ();

#printf STDERR "getColumns:  #colmap=%d colmap=(%s)\n", $#colmap, join(",", @colmap);

    eval {
        my $m        = $rset->getMetaData();
        my $colcnt   = $m->getColumnCount();

        #store column headers:
        for (my $ii = 1; $ii <= $colcnt; $ii++) {
            push @header, $m->getColumnLabel($ii) if ($colmap[$ii-1]);
        }
    };

    if ($@) {
        if (Inline::Java::caught("java.lang.Exception")) {
            my $xcptn = $@;
            (my $xcptnName = $xcptn->toString()) =~ s/:.*//;

            if ( isSqlException($xcptnName) ) {
                printf STDERR "%s[getColumns]: '%s'\n", __PACKAGE__, $xcptn->getMessage();
            } else {
                printf STDERR "%s[getColumns]: ", __PACKAGE__;
                $xcptn->printStackTrace();
            }
        } else {
            #not a java exception:
            printf STDERR "%s[getColumns]: eval FAILED:  %s\n", __PACKAGE__, $@;
        }
        return ();  #empty list
    }

    return @header;
}

sub getTableName
#return the table name of a rowset.
{
    my ($rset) = @_;

    return () unless defined($rset);

    my $tableName = "";

    eval {
        my $m        = $rset->getMetaData();
#        my $colcnt   = $m->getColumnCount();
#printf STDERR "getTableName getColumnCount()=%d\n", $colcnt;

        #this gets the table name of a particular column (1..N), so we ask for column 1:
        $tableName   = $m->getTableName(1);
    };

    if ($@) {
        if (Inline::Java::caught("java.lang.Exception")) {
            my $xcptn = $@;
            (my $xcptnName = $xcptn->toString()) =~ s/:.*//;

            if ( isSqlException($xcptnName) ) {
                printf STDERR "%s[getTableName]: '%s'\n", __PACKAGE__, $xcptn->getMessage();
            } else {
                printf STDERR "%s[getTableName]: ", __PACKAGE__;
                $xcptn->printStackTrace();
            }
        } else {
            #not a java exception:
            printf STDERR "%s[getTableName]: eval FAILED:  %s\n", __PACKAGE__, $@;
        }
        return "";  #empty string
    }

    return $tableName;
}

sub getColumnSizes
#return the list of column display sizes for a result set
#if <colmap> is set, then collect for the named columns.
{
    my ($rset, @colmap) = @_;

    return () unless defined($rset);

    my (@widths) = ();

    eval {
        my $m        = $rset->getMetaData();
        my $colcnt   = $m->getColumnCount();

        for (my $ii = 1; $ii <= $colcnt; $ii++) {
            push @widths, $m->getColumnDisplaySize($ii) if ($colmap[$ii-1]);
        }
    };

    if ($@) {
        if (Inline::Java::caught("java.lang.Exception")) {
            my $xcptn = $@;
            (my $xcptnName = $xcptn->toString()) =~ s/:.*//;

            if ( isSqlException($xcptnName) ) {
                printf STDERR "%s[getColumnSizes]: '%s'\n", __PACKAGE__, $xcptn->getMessage();
            } else {
                printf STDERR "%s[getColumnSizes]: ", __PACKAGE__;
                $xcptn->printStackTrace();
            }
        } else {
            #not a java exception:
            printf STDERR "%s[getColumnSizes]: eval FAILED:  %s\n", __PACKAGE__, $@;
        }
        return ();  #empty list
    }

    return @widths;
}

sub getRow
#return the list of row values for the current row of <rset>.
#if <colmap> is set, then only retrieve the named columns.
{
    my ($rset, $xmldisplay, @colmap) = @_;

    return () unless defined($rset);

    my (@data) = ();

    eval {
        my $m        = $rset->getMetaData();
        my $colcnt   = $m->getColumnCount();
#printf STDERR "getRow:  colcnt=%d\n", $colcnt;

        my $str = undef;
        if ($xmldisplay) {
            for (my $ii = 1; $ii <= $colcnt; $ii++) {
                next unless ($colmap[$ii-1]);   #skip if column is not selected

                #note - you have to do the fetch first, which sets wasNull() for the current column.
                $str = $rset->getString($ii);
                #printf STDERR "\tgetRow:  str='%s'\n", $str if ($DEBUG);

                #we are displaying xml rowsets - set SQL NULL elements to undef:
                #push @data, ($rset->wasNull() ? undef : $str);
                push @data, $str;
            }
        } else {
            for (my $ii = 1; $ii <= $colcnt; $ii++) {
                next unless ($colmap[$ii-1]);   #skip if column is not selected

                #note - you have to do the fetch first, which sets wasNull() for the current column.
                $str = $rset->getString($ii);

                #printf STDERR "\tgetRow:  str='%s'\n", $str if ($DEBUG);

                #not displaying xml rowsets - display the string "(NULL)":
                #push @data, ($rset->wasNull() ? "(NULL)" : $str);
                push @data, (defined($str) ?  $str : "(NULL)");
            }
        }
    };

    if ($@) {
        if (Inline::Java::caught("java.lang.Exception")) {
            my $xcptn = $@;
            (my $xcptnName = $xcptn->toString()) =~ s/:.*//;

            if ( isSqlException($xcptnName) ) {
                printf STDERR "%s[getRow]: '%s'\n", __PACKAGE__, $xcptn->getMessage();
            } else {
                printf STDERR "%s[getRow]: ", __PACKAGE__;
                $xcptn->printStackTrace();
            }
        } else {
            #not a java exception:
            printf STDERR "%s[getRow]: eval FAILED:  %s\n", __PACKAGE__, $@;
        }
        return ();  #empty list
    }

    return \@data;
}

sub setMaxColumnSizes
#set each element in <szref> to be max(curr, new) width for display
{
    my ($szref, $rowref) = @_;

    my @sizes = @{$szref};
    my @data =  @{$rowref};

    if ($#sizes != $#data) {
        #initialize sizes:
        @sizes = (0) x ($#data + 1);
    }

    for (my $ii = 0; $ii <= $#data; $ii++) {
        $sizes[$ii] = &maxwidth( $sizes[$ii], length(sprintf("%s", (defined($data[$ii]) ? $data[$ii] : "(NULL)"))) );
    }

    @{$szref} = @sizes;
}

sub maxwidth
#return the max of two numbers
{
    my ($ii, $jj) = @_;

    return (($ii >= $jj)? $ii : $jj);
}

sub getDbnameFromUrl
#this only works for mysql.
{
    my ($url) = @_;

    return $1 if ( $url =~ /\/([^\/]+)$/ );

    return undef;
}

sub setDbNameInUrl
{
    my ($url, $dbname) = @_;

    $url =~ s/\/([^\/]+)$//;
    return sprintf("%s/%s", $url, $dbname) if (defined($1));

    return undef;
}

sub isSqlException
#true if a java exception is from an SQL or JDBC package
{
    my ($xcptnName) = @_;
    return ( $xcptnName =~ /sql/i );
}


1;
} #end of sqlpj::sqlpjImpl
{
#
#sqlpj - Main driver for sqlpj - a command-line SQL interpreter for JDBC.pm
#

use strict;

package sqlpj;
my $pkgname = __PACKAGE__;

#imports:
use Config;


#standard global options:
my $p = $main::p;
my ($VERBOSE, $HELPFLAG, $DEBUGFLAG, $DDEBUGFLAG, $QUIET) = (0,0,0,0,0);

#package global variables:
my $USE_STDIN = 1;
my @SQLFILES = ();
my $scfg = new sqlpj::pkgconfig();
#this allows signal to close/open connection:
my $psqlImpl = undef;

&init;      #init globals

##################################### MAIN #####################################

sub main
{
    local(*ARGV, *ENV) = @_;

    &init;      #init globals

    return (1) if (&parse_args(*ARGV, *ENV) != 0);
    return (0) if ($HELPFLAG);


    #we handle our own signals:
    $SIG{'INT'}  = 'sqlpj::rec_signal';
    $SIG{'KILL'} = 'sqlpj::rec_signal';
    $SIG{'QUIT'} = 'sqlpj::rec_signal';
    $SIG{'TERM'} = 'sqlpj::rec_signal';
    $SIG{'HUP'}  = 'sqlpj::rec_signal';
    $SIG{'TRAP'} = 'sqlpj::rec_signal';

    #######
    #create implementation class, passing in our configuration:
    #######
    $psqlImpl = new sqlpj::sqlpjImpl($scfg);

    #reset the prompt string if user supplied the option:
    $psqlImpl->setPrompt($psqlImpl->userSuppliedPrompt()) if (defined($psqlImpl->userSuppliedPrompt()));

    #initialize our driver class:
    if (!$psqlImpl->check_driver()) {
        printf STDERR "%s:  ERROR: JDBC driver '%s' is not available for url '%s', user '%s', password '%s'\n",
            $pkgname, $psqlImpl->jdbcDriver(), $psqlImpl->getJdbcUrl(), $psqlImpl->user(), $psqlImpl->password();
        return 1;
    }

    if ( $scfg->getExecCommandString() ) {
        #...if we have an immediate command to execute, then do it and exit:
        if (!$psqlImpl->sql_init_connection()) {
            printf STDERR "%s:[sqlsession]:  cannot get a database connection:  ABORT\n", $pkgname;
            return 1;
        } else {
            my $lbuf = $scfg->getExecCommandString();

            if ($psqlImpl->localCommand($lbuf)) {
                #return zero status if execute is successful
                return 0;
            } else {
                return !( $psqlImpl->sql_exec($lbuf) );
            }
        }
    } elsif ($USE_STDIN) {
    #printf STDERR "%s:  using stdin\n", $pkgname;
        my $stdinh = "STDIN";
        $psqlImpl->sqlsession($stdinh, "<STDIN>");
    } else {
        my $infile;
        for (my $ii = 0; $ii <= $#SQLFILES; $ii++) {
            if (open($infile, $SQLFILES[$ii])) {
                $psqlImpl->sqlsession($infile, $SQLFILES[$ii]);
                close $infile;
            } else {
                printf STDERR "%s:  ERROR: cannot open sql input file, '%s':  '%s'\n", $pkgname, $SQLFILES[$ii], $!;
            }
        }
    }

    return 0;
}

################################### PACKAGE ####################################

sub checkSetClasspath
#if we have a classpath setting, then add to the environemnt.
#
#NOTE:  inline java will ignore any new CLASSPATH setting after
#       the module is loaded.  A work-around is to use "require" to load it.
{
    my ($cfg) = @_;

#printf STDERR "BEFORE CLASSPATH='%s'\n", $ENV{'CLASSPATH'};
    if (defined($cfg->getJdbcClassPath())) {
        if (defined($ENV{'CLASSPATH'}) && $ENV{'CLASSPATH'} ne "") {
            $ENV{'CLASSPATH'} = sprintf("%s%s%s", $cfg->getJdbcClassPath(), $cfg->getPathSeparator(), $ENV{'CLASSPATH'});
        } else {
            $ENV{'CLASSPATH'} = $cfg->getJdbcClassPath();
        }
    }
#printf STDERR "AFTER CLASSPATH='%s'\n", $ENV{'CLASSPATH'};
}

sub checkJdbcSettings
#return true(1) if jdbc properties are all defined.
{
    my ($cfg) = @_;
    my $errs = 0;

    if (!defined($cfg->getJdbcDriverClass())) {
        ++$errs; printf STDERR "%s:  missing JDBC driver class\n", $p;
    }
    if (!defined($cfg->getJdbcUrl())) {
        ++$errs; printf STDERR "%s:  missing JDBC URL\n", $p
    }
    if (!defined($cfg->getJdbcUser())) {
        ++$errs; printf STDERR "%s:  missing JDBC User name\n", $p;
    }
    if (!defined($cfg->getJdbcPassword())) {
        ++$errs; printf STDERR "%s:  missing JDBC User password\n", $p;
    }

    return($errs == 0);
}

sub rec_signal
# we only want to abort sqlexec in progress, not program.
{
    local($SIG) = @_;
    my($prevHandler) = $SIG{$SIG};

    # Reestablish the handler.
    $SIG{$SIG} = $prevHandler;
    printf STDERR ("\n%s:  Received SIG%s%s\n", $p, $SIG, ($SIG eq "HUP")? " - IGNORED" : "");

#printf STDERR "psqlImpl=%s connection=%s\n", ref($psqlImpl), ref($psqlImpl->getConnection());

    #reinitialize the connection if we got that far:
    if ($psqlImpl->getConnection()) {
        #none of this works...don't know how to recover the JVM or SQL connections.  RT 2/8/13
        #Inline::Java->reconnect_JVM();
        #JDBC->load_driver($psqlImpl->jdbcDriver());
        #$psqlImpl->sql_init_connection() 
    } else {
        #if we have not initialized Inline::Java, then we can safetly continue.
        return;
    }

    main::abort("Shutting down.\n");
}

#################################### USAGE #####################################

sub usage
{
    my($status) = @_;

    print STDERR <<"!";
Usage:  $pkgname [options] [file ...]

SYNOPSIS
  Creates a new database connection and runs each
  sql file provided on the command line.  If no files
  are given, then prompts for sql statements on stdin.

  Sql statements will be executed when the input contains
  a ';' command delimiter.  The delimiter must
  appear at the end of the line or alone on a line.

OPTIONS
  -help             Display this help message.
  -V                Show the $pkgname version.
  -verbose          Display additional informational messages.
  -debug            Display debug messages.
  -ddebug           Display deep debug messages.
  -quiet            Display severe errors only.

  -props file       A java property file containing the JDBC connection parameters:
                    The following property keys are recognized:

                        JDBC_CLASSPATH, JDBC_DRIVER_CLASS,
                        JDBC_URL, JDBC_USER, JDBC_PASSWORD

  -classpath string Classpath containing the JDBC driver (can be a single jar).
  -driver classname Name of the driver class
  -url name         Jdbc connection url
  -user name        Username used for connection
  -password string  Password for this user

  -e string         Execute commands from "string" and exit.  Useful for timing commands.
  -prompt string    Use <string> as prompt instead of default.
  -noprompt         Shorthand for -prompt ""
  -nooutput         Supress output of query results (for testing query times).

ENVIRONMENT
 CLASSPATH      Java CLASSPATH, inherited by JDBC.pm

EXAMPLES
  $pkgname -url jdbc:mysql://localhost:3306/mysql -user root -password secret -classpath mysqljdbc.jar -driver com.mysql.jdbc.Driver

  Similar example, with connection properties in "localmysql.props",
  and reading commands from "myscript.sql":

  % cat localmysql.props
JDBC_CLASSPATH=mysqljdbc.jar
JDBC_DRIVER_CLASS=com.mysql.jdbc.Driver
JDBC_URL=jdbc:mysql://localhost:3306/mysql
JDBC_USER=root
JDBC_PASSWORD=secret

  $pkgname -props localmysql.props -prompt "" myscript.sql
!
    return ($status);
}

sub parse_args
#proccess command-line aguments
{
    local(*ARGV, *ENV) = @_;

    #set defaults:
    $scfg->setProgName($p);
    $scfg->setPathSeparator($Config{path_sep});

    #eat up flag args:
    my ($flag);
    while ($#ARGV+1 > 0 && $ARGV[0] =~ /^-/) {
        $flag = shift(@ARGV);

        if ($flag =~ '^-debug') {
            $DEBUGFLAG = 1;
        } elsif ($flag =~ '^-V') {
            # -V                show version and exit
            printf STDOUT "%s, Version %s, %s.\n",
                $scfg->getProgName(), $scfg->versionNumber(), $scfg->versionDate();
            $HELPFLAG = 1;    #display version and exit.
            return 0;
        } elsif ($flag =~ '^-user') {
            # -user name        Username used for connection
            if ($#ARGV+1 > 0 && $ARGV[0] !~ /^-/) {
                $scfg->setJdbcUser(shift(@ARGV));
            } else {
                printf STDERR "%s:  -user requires user name.\n", $p;
                return 1;
            }
        } elsif ($flag =~ '^-pass') {
            # -password string  Password for this user
            if ($#ARGV+1 > 0 && $ARGV[0] !~ /^-/) {
                $scfg->setJdbcPassword(shift(@ARGV));
            } else {
                printf STDERR "%s:  -password requires password string.\n", $p;
                return 1;
            }
        } elsif ($flag =~ '^-e') {
            # -e string  Execute commands from "string" and exit.
            if ($#ARGV+1 > 0 && $ARGV[0] !~ /^-/) {
                $scfg->setExecCommandString(shift(@ARGV));
            } else {
                printf STDERR "%s:  -e requires string containing commands.\n", $p;
                return 1;
            }
        } elsif ($flag =~ '^-driver') {
            # -driver classname Name of the driver class
            if ($#ARGV+1 > 0 && $ARGV[0] !~ /^-/) {
                $scfg->setJdbcDriverClass(shift(@ARGV));
            } else {
                printf STDERR "%s:  -driver requires driver class name.\n", $p;
                return 1;
            }
        } elsif ($flag =~ '^-classpath') {
            # -classpath string Classpath containing the JDBC driver (can be a single jar).
            if ($#ARGV+1 > 0 && $ARGV[0] !~ /^-/) {
                $scfg->setJdbcClassPath(shift(@ARGV));
            } else {
                printf STDERR "%s:  -classpath requires classpath setting.\n", $p;
                return 1;
            }
        } elsif ($flag =~ '^-props') {
            # -props <file>        Set JDBC connection properties from <file>
            if ($#ARGV+1 > 0 && $ARGV[0] !~ /^-/) {
                $scfg->setJdbcPropsFileName(shift(@ARGV));
                #parse the properties file - additional command line args can override:
                $scfg->parseJdbcPropertiesFile();
            } else {
                printf STDERR "%s:  -props requires a file name containing JDBC connection properties.\n", $p;
                return 1;
            }
        } elsif ($flag =~ '^-url') {
            # -url name         Jdbc connection url
            if ($#ARGV+1 > 0 && $ARGV[0] !~ /^-/) {
                $scfg->setJdbcUrl(shift(@ARGV));
            } else {
                printf STDERR "%s:  -url requires the JDBC connection url\n", $p;
                return 1;
            }
        } elsif ($flag =~ '^-nooutput') {
            # supress output of query results (for testing query times)
            $scfg->setSuppressOutput(1);
        } elsif ($flag =~ '^-noprompt') {
            # clear prompt, same as "-prompt ''"
            $scfg->setUserSuppliedPrompt('');
        } elsif ($flag =~ '^-prompt') {
            # -prompt string    Use <string> as prompt instead of default.
            if ($#ARGV+1 > 0 && $ARGV[0] !~ /^-/) {
                $scfg->setUserSuppliedPrompt(shift(@ARGV));
            } else {
                printf STDERR "%s:  -prompt requires the prompt string.\n", $p;
                return 1;
            }
        } elsif ($flag =~ '^-dd') {
            $DDEBUGFLAG = 1;
        } elsif ($flag =~ '^-v') {
            $VERBOSE = 1;
        } elsif ($flag =~ '^-q') {
            $QUIET = 1;
        } elsif ($flag =~ '^-h') {
            $HELPFLAG = 1;
            return &usage(0);
        } else {
            printf STDERR "%s:  unrecognized option, '%s'\n", $p, $flag;
            return &usage(1);
        }
    }

    #eliminate empty args (this happens on some platforms):
    @ARGV = grep(!/^$/, @ARGV);

    #set debug, verbose options:
    $scfg->setDebug($DEBUGFLAG);
    $scfg->setDDebug($DDEBUGFLAG);
    $scfg->setQuiet($QUIET);
    $scfg->setVerbose($VERBOSE);

    #check the JDBC configuration:
    if (!&checkJdbcSettings($scfg)) {
        printf STDERR "%s:  one or more JDBC connection settings are missing or incomplete - ABORT.\n", $p;
        return 1;
    }

    #add to the CLASSPATH if required:
    &checkSetClasspath($scfg);

    #do we have file args?
    #take remaining args as directories to walk:
    if ($#ARGV >= 0) {
        @SQLFILES = @ARGV;
        $USE_STDIN = 0;
    }
    return 0;
}

################################ INITIALIZATION ################################

sub init
{
}

sub cleanup
{
}
1;
} #end of sqlpj
