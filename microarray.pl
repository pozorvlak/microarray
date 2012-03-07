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
 
die ("\nUse: perl microarray.pl <Input datafile.txt>") unless @ARGV == 1;
 
my @genes;
 
while (<>) {
        chomp;
        next if /^probes/; # Header line: ignore

        my ($name, @values) = split;

        # Die on unexpected non-numeric data
        die "File '$ARGV' contains non-numeric data at line $."
                if any { !looks_like_number($_) } @values;

        # We only care about genes which have at least one sample greater than 300.
        next unless any { $_ > 300 } @values;

        push @genes, { name => $name, values => \@values };
}
 
say "\nThere are " . scalar(@genes) . " genes that meet filter criteria.\n";
 

my %score;
for my $gene (@genes) {
        my $data = $gene->{values};
        my @control = @$data[ 0 .. 19];    # first 20
        my @sample  = @$data[20 .. 40];    # next 21
        my $fldNum = mean(@control) - mean(@sample);
        my $fldDenom = stddev(@control) + stddev(@sample);
        my $fldScore = $fldNum / $fldDenom;
        $score{$fldScore} = $gene->{name};
        say "FLD score: $fldScore";
        say "Current cycle: ", scalar keys %score
                if keys(%score) % 100 == 0;
}
 
say "Top Ranking Differentially Expressed Genes:";
my $scoreCounter = 1;
foreach my $key (sort keys %score) {
        say "$scoreCounter. $score{$key}";
        $scoreCounter++;
}

