#!/usr/bin/env perl -w
{
    #turn off "Newline in left-justified string for printf ..." warnings in this block only:
    no warnings 'printf';

    printf "ONE %-2s", "\n";
}

printf "TWO %-2s", "\n";

1;
