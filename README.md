sqlpj
=====

Sqlpj is an command-line sql monitor implemented in perl, but using JDBC for database connectivity.

It can be used to browse database tables, execute sql queries, etc.

Database meta-data and tables can be dumped out in XML format if desired.

Can be used to explore JDBC metadata for a particular JDBC driver.

Sqlpj can be used as a library (sqlpj.pl) to provide high-level database connectivity for another program.

System Requirements:
====================
* Perl 5.8.x, with Inline::Java and JDBC.pm installed.  (Later versions of perl will *not* work with Inline::Java).
* JDBC driver jar for the database of interest, including MySql, Oracle, etc.  MySql is more heavily tested than others.

See Also:
=========
* Help message:  `sqlpj -help`
* Ecdump (Electric Commander Dump) uses sqlpj.pl to access the commander database - see:  <https://github.com/russt/ecdump>
* Cado is used to generate the sqlpj sources.  See `tl/src/cmn/sqlpj/srcgen`, <https://github.com/russt/cado>

