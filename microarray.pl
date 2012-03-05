#!/usr/bin/perl -w
 
use strict;
use List::MoreUtils qw/all any each_array/;
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
 
my $file = $ARGV[0];
 
open(my $in, "<", $file) or die "\nCouldn't open file $file: $!";
 
my $topLine;
my @nameArray;
my @dataArray =();
my $indexLine = 0;
my $sampleNum = 0;
 
while (my $line = <$in>) {
        chomp $line;
        if ($line =~ /^probes/) {
                $topLine = $line;
                $indexLine = -1;
        }
        else {
                my ($name, @values) = split(" ", $line);
                $nameArray[$indexLine] = $name;
                $sampleNum = @values;
                die "File '$file' contains non-numeric data at line $."
                        if any { !looks_like_number($_) } @values;
                $dataArray[$indexLine] = \@values;
        }
        $indexLine++;
}
 
close $in;
 
my @filterNames;
my @filterData;
 
my $ea = each_array(@nameArray, @dataArray);
while (my ($name, $gene) = $ea->())  {
        if (any { $_ > 300 } @$gene) {
                push (@filterNames,$name);
                push (@filterData,$gene);
        }
}
 
my $filterNumber = scalar @filterNames;
 
print "\nThere are $filterNumber genes that meet filter criteria.\n";
 
my %scoreHash = ();
my $reporter = 0;
my $incrementor = 0;
 
for my $i (0 .. $filterNumber - 1) {
        my $data = $filterData[$i];
        my @controlArray = @$data[ 0 .. 19];    # first 20
        my @sampleArray  = @$data[20 .. 40];    # next 21
        my ($controlMean, $controlSD) = average_and_stdev(\@controlArray);
        my ($sampleMean, $sampleSD) = average_and_stdev(\@sampleArray);
        my $fldNum = $controlMean - $sampleMean;
        my $fldDenom = $controlSD + $sampleSD;
        my $fldScore = $fldNum / $fldDenom;
        $scoreHash{$fldScore} = $i;
        $reporter++;
        $incrementor++;
        print "\nFLD score: $fldScore";
        if ($incrementor == 100) {
                print "\nCurrent cycle: $reporter";
                $incrementor = 0;
        }
}
 
my $scoreCounter = 1;
foreach my $key (sort keys %scoreHash) {
        print "\nTop Ranking Differentially Expressed Genes:";
        print "\n$scoreCounter. $filterNames[$scoreHash{$key}]";
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

