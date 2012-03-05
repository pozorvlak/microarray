#!/usr/bin/perl -w
 
use strict;
use List::MoreUtils qw/any each_array/;
 
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
        if ($line =~ /^probes/) {
                chomp $line;
                $topLine = $line;
                $indexLine = -1;
        }
        else {
                chomp $line;
                my @tempArray = split(" ",$line);
                $nameArray[$indexLine] = shift @tempArray;
                $sampleNum = @tempArray;
                @{$dataArray[$indexLine]} = @tempArray;
        }
        $indexLine++;
}
 
close $in;
 
my $geneNumber = $indexLine;
 
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
 
my $controlMean;
my $controlSD;
my $sampleMean;
my $sampleSD;
my $fldScore = 0;
my %scoreHash = ();
my $reporter = 0;
my $incrementor = 0;
 
 
for (my $i = 0; $i < $filterNumber; $i++) {
        my @controlArray;
        my @sampleArray;
        for (my $j = 0; $j < 20; $j++) {
                push (@controlArray,$filterData[$i][$j]);
        }
        for (my $k = 20; $k < 41; $k++) {
                push(@sampleArray, $filterData[$i][$k]);
        }
        my $controlLength = @controlArray;
        my $sampleLength = @sampleArray;
 
        ($controlMean,$controlSD) = &average_and_stdev(\@controlArray);
        ($sampleMean,$sampleSD) = &average_and_stdev(\@sampleArray);
        my $fldNum = $controlMean - $sampleMean;
        my $fldDenom = $controlSD + $sampleSD;
        $fldScore = $fldNum / $fldDenom;
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
    my $sum = 0;
    my $deviations = 0;
    for my $elt (@$array) {
        $sum += $elt;
    }
    my $mean = $sum/@$array;
    for my $elt (@$array)
    {
        #Find the deviation from the mean and square it.
        $deviations = $deviations + ($elt - $mean)**2;
    }
    #Take the square root of the S2 to find S.
    my $stdev = sqrt($deviations/(@$array-1));
    #Return the mean and standard deviation.
    return $mean,$stdev;
}              
##########################
##########################

