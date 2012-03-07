#!/usr/bin/perl

use Test::More tests => 1;

subtest 'Output matches expected output' => sub {
    is( system('perl microarray.pl data > actual.out'),  0,  'Creating actual.out file' );
    is( system('diff actual.out expected.out'),          0,  'actual.out matches expected.out')
      && unlink 'actual.out';
};

done_testing;
