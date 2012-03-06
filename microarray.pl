#!/usr/bin/perl -w
 
use strict;
use List::MoreUtils qw/any/;
use List::Util qw/sum/;
use Scalar::Util qw/looks_like_number/;
use Statistics::Lite qw/mean stddev/;
use feature 'say';
our $VERSION = '0.001';
 
######################
#Microarray Filter and Fold Change Finder
######################
 
#Open data file and read into array:
 
say "\nMicroarray Filter and Analysis Tool:";
 
 
if (@ARGV != 1) {
        die ("\nUse: perl microarray.pl <Input datafile.txt>");
}
 
my %score;
while (<>) {
        chomp;
        next if /^probes/; # Header line: ignore
        my ($name, @values) = split;
        die "File '$ARGV' contains non-numeric data at line $."
                if any { !looks_like_number($_) } @values;
        # We look at genes which have at least one sample greater than 300.
        if (any { $_ > 300 } @values) {
                my $fldScore = fld(@values);
                say "FLD score: $fldScore";
                $score{$fldScore} = $name;
                say "Current cycle: ", scalar keys %score
                        if keys(%score) % 100 == 0;
        }
}
 
say "Top Ranking Differentially Expressed Genes:";
my $scoreCounter = 1;
foreach my $key (sort keys %score) {
        say "$scoreCounter. $score{$key}";
        $scoreCounter++;
}

sub fld {
        my @control = @_[ 0 .. 19];    # first 20
        my @sample  = @_[20 .. 40];    # next 21
        my $fldNum = mean(@control) - mean(@sample);
        my $fldDenom = stddev(@control) + stddev(@sample);
        return $fldNum / $fldDenom;
}

