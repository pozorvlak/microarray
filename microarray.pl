#!/usr/bin/perl -w
 
use strict;
use List::MoreUtils qw/any/;
use List::Util qw/sum/;
use Scalar::Util qw/looks_like_number/;
use Statistics::Lite qw/mean stddev/;
 
######################
#Microarray Filter and Fold Change Finder
######################
 
#Open data file and read into array:
 
print "\nMicroarray Filter and Analysis Tool:\n";
 
 
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
 
print "\nThere are " . scalar(@filtered) .
    " genes that meet filter criteria.\n";
 
my %scoreHash;
for my $gene (@filtered) {
        my $data = $gene->{values};
        my @controlArray = @$data[ 0 .. 19];    # first 20
        my @sampleArray  = @$data[20 .. 40];    # next 21
        my $fldNum = mean(@controlArray) - mean(@sampleArray);
        my $fldDenom = stddev(@controlArray) + stddev(@sampleArray);
        my $fldScore = $fldNum / $fldDenom;
        $scoreHash{$fldScore} = $gene->{name};
        print "\nFLD score: $fldScore";
        print "\nCurrent cycle: ", scalar keys %scoreHash
                if keys(%scoreHash) % 100 == 0;
}
 
print "\nTop Ranking Differentially Expressed Genes:\n";
my $scoreCounter = 1;
foreach my $key (sort keys %scoreHash) {
        print "$scoreCounter. $scoreHash{$key}\n";
        $scoreCounter++;
}

