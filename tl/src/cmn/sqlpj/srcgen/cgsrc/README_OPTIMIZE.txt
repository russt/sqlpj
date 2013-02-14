So in conclusion, we went from about 8 seconds to 4 seconds (startup time is about 9 seconds)
by:

1) getting colcnt one per resultSet instead of once per row
2) eliminating wasNull() call once per table cell
3) eliminating perl foreach loops in favor of map {} function calls.

For full query (516,140 records) time went from 893 seconds to 402 seconds, for a 54% reduction in overall time.

=====
TEST:  FULL QUERY:
sqlpj -debug -noprompt -props ~/.jdbc/lcommander.props ../prop_kids.sql > ! prop_kids.out &
289.715u 61.425s 6:41.84 87.3%	0+0k 45+57io 0pf+0w

BEFORE OPT:  610.396u 157.311s 14:52.31 86.0%	0+0k 89+16io 0pf+0w

=====
TEST:  implement nested map for resultSet & getRow iterations limit 5000 rows
sqlpj -nooutput -noprompt -props ~/.jdbc/lcommander.props ../prop_kids.sql
.....
sqlpj: INFO: supressing display of 5000 query results (-nooutput specified).
12.834u 1.707s 0:13.00 111.7%	0+0k 0+3io 0pf+0w

=====
TEST:  implement getRow() as map, limit 5000 rows
sqlpj -nooutput -noprompt -props ~/.jdbc/lcommander.props ../prop_kids.sql
SQL/XML result-sets display is now ON
.....
sqlpj: INFO: supressing display of 5000 query results (-nooutput specified).
15.297u 2.298s 0:15.89 110.6%	0+0k 0+49io 0pf+0w

=====
TEST:  local getRow(), eliminate wasNull(), eliminate dot counter, limit 5000 rows
sqlpj -nooutput -noprompt -props ~/.jdbc/lcommander.props ../prop_kids.sql
SQL/XML result-sets display is now ON
sqlpj: INFO: supressing display of 0 query results (-nooutput specified).
15.128u 2.275s 0:15.77 110.2%	0+0k 0+2io 0pf+0w

=====
TEST:  local getRow(), eliminate wasNull(), limit 5000 rows
sqlpj -nooutput -noprompt -props ~/.jdbc/lcommander.props ../prop_kids.sql
SQL/XML result-sets display is now ON
.....
sqlpj: INFO: supressing display of 5000 query results (-nooutput specified).
15.319u 2.291s 0:15.79 111.4%	0+0k 0+33io 0pf+0w

=====
TEST:  local getRow(), using wasNull(), limit 5000 rows
sqlpj -nooutput -noprompt -props ~/.jdbc/lcommander.props ../prop_kids.sql
SQL/XML result-sets display is now ON
.....
sqlpj: INFO: supressing display of 5000 query results (-nooutput specified).
16.472u 2.671s 0:17.71 108.0%	0+0k 0+32io 0pf+0w

=====
TEST:  getRow as subroutine  (limit 5000 rows)
sqlpj -nooutput -noprompt -props ~/.jdbc/lcommander.props ../prop_kids.sql
SQL/XML result-sets display is now ON
.....
sqlpj: INFO: supressing display of 5000 query results (-nooutput specified).
14.891u 2.277s 0:16.05 106.9%	0+0k 0+3io 0pf+0w


