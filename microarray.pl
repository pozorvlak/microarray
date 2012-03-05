#!/usr/bin/perl -w
 
use strict;
use List::MoreUtils qw/any/;
use List::Util qw/sum/;
use Scalar::Util qw/looks_like_number/;
 
######################
#Microarray Filter and Fold Change Finder
######################
 
#Open data file and read into array:
 
print "\nMicroarray Filter and Analysis Tool:\n";
 
 
if (@ARGV != 1) {
        die ("\nUse: perl microarray.pl <Input datafile.txt>");
}
 
my @genes;
 
while (my $line = <>) {
        chomp $line;
        next if $line =~ /^probes/; # Header line: ignore
        my ($name, @values) = split(" ", $line);
        die "File '$ARGV' contains non-numeric data at line $."
                if any { !looks_like_number($_) } @values;
        push @genes, { name => $name, values => \@values };
}
 
# We only care about genes which have at least one sample greater than 300.
my @filtered = grep { any { $_ > 300 } @{$_->{values}} } @genes;
 
print "\nThere are " . scalar(@filtered) .
    " genes that meet filter criteria.\n";
 
my %scoreHash = ();
my $i = 0; 
for my $gene (@filtered) {
        my $data = $gene->{values};
        my @controlArray = @$data[ 0 .. 19];    # first 20
        my @sampleArray  = @$data[20 .. 40];    # next 21
        my ($controlMean, $controlSD) = average_and_stdev(\@controlArray);
        my ($sampleMean, $sampleSD) = average_and_stdev(\@sampleArray);
        my $fldNum = $controlMean - $sampleMean;
        my $fldDenom = $controlSD + $sampleSD;
        my $fldScore = $fldNum / $fldDenom;
        $scoreHash{$fldScore} = $gene->{name};
        print "\nFLD score: $fldScore";
        if (++$i % 100 == 0) {
                print "\nCurrent cycle: " . $i;
        }
}
 
print "\nTop Ranking Differentially Expressed Genes:";
my $scoreCounter = 1;
foreach my $key (sort keys %scoreHash) {
        print "\n$scoreCounter. $scoreHash{$key}";
        $scoreCounter++;
}
               
######################
sub average_and_stdev
######################
#This proceedure takes the address of an array as input.
#to use this subroutine, input the following line
#($average,$stdev) = average_and_stdev(\@input_array)
#which will take your @input_array and output its $average and $stdev
#It returns the mean and standard deviation of the values in the array
{
    my ($array) = @_;
    my $sum = sum(@$array);
    my $n = @$array;
    my $mean = $sum / $n;
    my $deviations = sum(map { ($_ - $mean)**2 } @$array);
    #Take the square root of the S2 to find S.
    my $stdev = sqrt($deviations / ($n - 1));
    #Return the mean and standard deviation.
    return $mean, $stdev;
}              
##########################
##########################

