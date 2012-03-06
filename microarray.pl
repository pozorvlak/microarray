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
 
my @genes;
 
while (<>) {
        chomp;
        next if /^probes/; # Header line: ignore
        my ($name, @values) = split;
        die "File '$ARGV' contains non-numeric data at line $."
                if any { !looks_like_number($_) } @values;
        push @genes, { name => $name, values => \@values };
}
 
# We only care about genes which have at least one sample greater than 300.
my @filtered = grep { any { $_ > 300 } @{$_->{values}} } @genes;
 
say "\nThere are " . scalar(@filtered) . " genes that meet filter criteria.\n";
 
my %scoreHash;
for my $gene (@filtered) {
        my $data = $gene->{values};
        my @controlArray = @$data[ 0 .. 19];    # first 20
        my @sampleArray  = @$data[20 .. 40];    # next 21
        my $fldNum = mean(@controlArray) - mean(@sampleArray);
        my $fldDenom = stddev(@controlArray) + stddev(@sampleArray);
        my $fldScore = $fldNum / $fldDenom;
        $scoreHash{$fldScore} = $gene->{name};
        say "FLD score: $fldScore";
        say "Current cycle: ", scalar keys %scoreHash
                if keys(%scoreHash) % 100 == 0;
}
 
say "Top Ranking Differentially Expressed Genes:";
my $scoreCounter = 1;
foreach my $key (sort keys %scoreHash) {
        say "$scoreCounter. $scoreHash{$key}";
        $scoreCounter++;
}

