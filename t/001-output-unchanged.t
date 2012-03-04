#!/usr/bin/perl

use Test::More;

system("perl microarray.pl data > actual.out");
my $unchanged = system("diff actual.out expected.out") == 0;
ok($unchanged, "output unchanged");
if ($unchanged) {
    unlink "actual.out";
}

done_testing;
