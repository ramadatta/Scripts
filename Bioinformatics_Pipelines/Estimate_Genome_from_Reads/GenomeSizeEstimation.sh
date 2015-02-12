#!/bin/sh

#This script takes fasta seqeunces and counts the number of KMERS.
#R code estimates the Genome Size

#Source: 
	#Jellyfish: http://www.cbcb.umd.edu/software/jellyfish/
	#R-code: http://koke.asrc.kanazawa-u.ac.jp/HOWTO/kmer-genomesize.html

##Script Compiled by : Prakki Sai Rama Sridatta
##Date: Unknown date, 2014
##Email: prakkisr@tll.org.sg // ramadatta.88@gmail.com


#$ -cwd
#$ -V
#$ -pe smp 8
## Join the standard error and the standard output into 1 file output
#$ -j y

InputFile=polished_assemblyNamesChanged_90x_3917.biggest1st.fasta
#echo "$InputFile"
echo "Counting started on"
date
~/sw/jellyfish-1.1.11/bin/./jellyfish count -m 21 -s 100000000 -t $NSLOTS -o output -C $InputFile
echo "Counting finished on"
date

echo "Merging started on"
date
~/sw/jellyfish-1.1.11/bin/./jellyfish merge -o output.jf output_*
echo "Merging finished on"
date

~/sw/jellyfish-1.1.11/bin/./jellyfish histo -f output.jf > output_histogram.txt

~/sw/jellyfish-1.1.11/bin/./jellyfish stats -v -o stats.txt output.jf
echo "JellyFish ended on"
date

# Using Rscript a.R

IlluminaHist <- read.table(file="output_histogram.txt")
sum(as.numeric(IlluminaHist[11:9925,1]*IlluminaHist[11:9925,2]))
[1] 41757492264
> totalKmer <- sum(as.numeric(IlluminaHist[11:9925,1]*IlluminaHist[11:9925,2]))
> totalKmer/72
[1] 579965170 #(579 Mb)

