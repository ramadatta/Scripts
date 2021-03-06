
##Source: http://wiki.bits.vib.be/index.php/Create_a_GC_content_track

##Descrption: Takes the fasta, 1) Generates Non-overlapping Sliding windows, 
#       		       2) Checks if the Sliding windows has N's and ignores if is more than default
# 			       3)Outputs the GC% content in each sliding window

#Dependencies: Bedtools,knowGC-contentHistogramrun2.pl (the other sister script in the same folder) 

##Script compiled by: Prakki Sai Rama Sridatta

##Date: August 06, 2014

##Email: prakkisr@tll.org.sg // ramadatta.88@gmail.com

## Usage: ./knowGC-contentrun1.sh <fileName.fasta> <windowsize>

filefasta="$1"; ##input fasta file
echo "Input file is: $filefasta"

width=$2 ##default
echo "Sliding window is: $width"

MaxN=`expr $width \* 25 / 100` ##more than 25% N's in the sliding window are ignored.
echo "Number of N's allowed in ${width} Sliding window: $MaxN"
	
	##step1

	echo "Checking fasta sequence sizes..1/4"
	faSize ${filefasta} -detailed > ${filefasta}.sizes

	##step2

	echo "Making windows..2/4"
	bedtools makewindows -g ${filefasta}.sizes -w ${width} > ${filefasta}.sizes.${width}.window.bed 

	##step3

	echo "Extracting sliding window sequence..3/4"
	bedtools nuc -fi ${filefasta} -bed ${filefasta}.sizes.${width}.window.bed -seq >${filefasta}.sizes.${width}.window.bed.nuc.out

	##step4

	echo "AWKING to get sliding windows with N's < 25% of the sliding window length..4/4"
	rm ${filefasta}.window${width}.GC-content.txt ##Deleting previous existing same files
	head -1 ${filefasta}.sizes.${width}.window.bed.nuc.out >${filefasta}.window${width}.GC-content.txt

	awk 'NR>1' ${filefasta}.sizes.${width}.window.bed.nuc.out | awk -v var1=${width} '$3-$2==var1 {print $0;}'  | awk -v var2=${MaxN} '$10 <= var2' | awk '{$NF=""}1' >>${filefasta}.window${width}.GC-content.txt ##1st awk checks if the windows is 20kb, 2nd awk checks if the N's in the window are less than 25% of the 20kb, 3rd awk ignores the sliding window sequence and output the file.(..window size is 20kb, 25% of 20kb is 5k)

	echo "Completed with Bedtools, Now calculating Intervals and proportions";

	##step 5
	awk '{print $5}' ${filefasta}.window${width}.GC-content.txt | awk 'NR>1' >${filefasta}.window${width}.GC-content.txt.in

	##step6

	perl knowGC-contentHistogramrun2.pl ${filefasta}.window${width}.GC-content.txt.in 0 1 0.05 >${filefasta}.window${width}.GC-content.txt.out


