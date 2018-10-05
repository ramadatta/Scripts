#!/bin/bash

#Script: Given a fastq file, finds Total number of bases, Total Bases with minimum quality score of 30

#Usage: Q30_stats.sh filename.fastq

#Author: Prakki Sai Rama Sridatta

#Date: Oct 5, 2018

filename="$1"

#echo "Sample FileName: $filename"

TotalBases_inSample=`sed -n '0~4p' $filename |  tr -d '\n' | wc -m` ##1

#echo "Total Bases in Sample: $TotalBases_inSample"

Bases_withminQ30_inSample=`sed -n '0~4p' $filename |  tr -d '\n' | egrep -o "\?|@|A|B|C|D|E|F|G|H|I|J" | tr -d '\n' | wc -m` ##2
#echo "Total Bases in the sample with the minimum Qscore 30: $Bases_withminQ30_inSample"

Pcnt_Bases_inSample_withMinQ30=`echo "scale=2; $Bases_withminQ30_inSample*100/$TotalBases_inSample" | bc -l` ##3

#echo "Percentage of High Quality (with Q-score (>=Q30)) Bases in the sample: $Pcnt_Bases_inSample_withMinQ30"

TotalReads_inSample=`fgrep -c ':N:' $filename`

#echo "Total reads in the sample: $TotalReads_inSample"

AverageBases_per_Read=`echo "scale=0; $TotalBases_inSample/$TotalReads_inSample" | bc -l`	##4

#echo "Average number of bases per read in the sample: $AverageBases_per_Read"

Average_NumberofBases_with_MinQ30_per_Read=`echo "scale=0; $Bases_withminQ30_inSample/$TotalReads_inSample" | bc -l`	##5

#echo "Average number of High Quality bases (with Q-score (>=Q30)) per read in the sample: $Average_NumberofBases_with_MinQ30_per_Read"


echo "$filename	$TotalBases_inSample	$Bases_withminQ30_inSample	$Pcnt_Bases_inSample_withMinQ30	$TotalReads_inSample	$AverageBases_per_Read	$Average_NumberofBases_with_MinQ30_per_Read"

##line to be prepended
#echo "Sample FileName  Total Bases in Sample	Total Bases in the sample with the minimum Qscore 30	Percentage of High Quality (with Q-score (>=Q30)) Bases in the sample	Total reads in the sample	Average number of bases per read in the sample	Average number of High Quality bases (with Q-score (>=Q30)) per read in the sample"
