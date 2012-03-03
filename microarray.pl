#!/usr/bin/perl -w
 
use strict;
 
######################
#Microarray Filter and Fold Change Finder
######################
 
#Open data file and read into array:
 
print "\nMicroarray Filter and Analysis Tool:\n";
 
 
if (@ARGV != 1) {
        die ("\nUse: perl microarray.pl <Input datafile.txt>");
}
 
my $file = $ARGV[0];
 
open(IN,"$file") or die "\nCouldn't open file:\t$file";
 
my $topLine;
my @nameArray;
my @dataArray =();
my $indexLine = 0;
my $sampleNum = 0;
 
 
while (my $line = <IN>) {
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
 
close IN;
 
my $geneNumber = $indexLine;
 
 
 
#for (my $i = 0; $i < $geneNumber;$i++) {
#       for (my $j = 0; $j < $sampleNum - 1; $j++) {
#               print "\n$dataArray[$i][$j]";
#       }
#}
 
my @filterNames;
my @filterData;
my $counter = 0;
 
for (my $i = 0; $i < $geneNumber; $i++) {
        my $flag = 0;
        for (my $j = 0; $j < $sampleNum; $j++) {
                if ($dataArray[$i][$j] > 300) {
                        $flag = 1;
                }
        }
        if ($flag == 1) {
                push (@filterNames,$nameArray[$counter]);
                push (@filterData,$dataArray[$counter]);
        }
        $counter++
}
 
my $filterNumber = 0;
 
for (my $i = 0; $i < @filterNames;$i++) {
        #print "\n$filterNames[$i]";
        $filterNumber++;
}
print "\nThere are $filterNumber genes that meet filter criteria.\n";
 
my @controlArray;
my @sampleArray;
my $controlMean;
my $controlSD;
my $sampleMean;
my $sampleSD;
my $fldScore = 0;
my %scoreHash = ();
my $reporter = 0;
my $incrementor = 0;
 
 
for (my $i = 0; $i < $filterNumber; $i++) {
        for (my $j = 0; $j < 20; $j++) {
                push (@controlArray,$filterData[$i][$j]);
        }
        for (my $k = 20; $k < 41; $k++) {
                push(@sampleArray, $filterData[$i][$k]);
        }
        my $controlLength = @controlArray;
        my $sampleLength = @sampleArray;
 
        ($controlMean,$controlSD) = &average_and_stdev(\@controlArray,$controlLength);
        ($sampleMean,$sampleSD) = &average_and_stdev(\@sampleArray, $sampleLength);
        my $fldNum = $controlMean - $sampleMean;
        my $fldDenom = $controlSD + $sampleSD;
        $fldScore = $fldNum / $fldDenom;
        $scoreHash{$fldScore} = $i;
        $reporter++;
        $incrementor++;
        #print "Cycle: $reporter";
        print "\nFLD score: $fldScore";
        if ($incrementor = 100) {
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
#($average,$stdev) = &average_and_stdev(\@input_array)
#which will take your @input_array and output it's $average and $stdev
#It returns the mean and standard deviation of the values in the array
{
    my ($array, $arrayLength) = @_;
    my ($i,$j,$sum,$mean,$deviations,$stdev);  #Declare variables
    $sum=0;                                                                                                     #Set values of starting variables      
    $mean=();
    $deviations=0;
    $stdev=();
    for ($i=0;$i<@$array;$i++)                                                           #For each element in the array...
    {
        $sum=$sum+$array->[$i];                                                                   #Take the sum of the entire input array
    }
    $mean=$sum/$arrayLength;                                                                            #Find the mean of the input array values.
    for ($j=0;$j<@$array;$j++)                                                           #For each element in the array...
    {
        $deviations=$deviations+($array->[$j]-$mean)**2;                  #Find the deviation from the mean and square it.
    }
    $stdev=sqrt($deviations/(@$array-1));                                        #Take the square root of the S2 to find S.
    return $mean,$stdev;                                                                        #Return the mean and standard deviation.
}              
##########################
##########################

