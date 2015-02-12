#!/bin/sh
 
#$ -cwd
#$ -V
#$ -pe smp 5

## Join the standard error and the standard output into 1 file output
#$ -j y

#4 Major changes in this pileine

 	##	1) No adaptor trim
 	##	2) Changing quality score to 30 instead of 20 
 	##	3) No need of polyA/T trimming because the data is not RNASeq
 	##	4) Contamination database changed to Seabass 3807 Scaffolds.

##The Amplicon PE Reads all present in the one file only. So, sepearated the Read1 into one file and Read2 into other file using the following perl script/



#perl sepPE_Reads.pl sample.fastq ##will generate sample.Read1.fastq, sample.Read2.fastq

OUTPUT_FILE_NAME=sample ##Prefix for the intermediate files

File_BaseName1=$OUTPUT_FILE_NAME.Read1 ## Both Read1 and Read 2 are in order in the one file only
File_BaseName2=$OUTPUT_FILE_NAME.Read2

## STEP1: Count the number of reads in the fastq file

#ReadCount1=` grep -c "^+$"  $File_BaseName1.fastq` 
#ReadCount2=` grep -c "^+$"  $File_BaseName2.fastq` 

#echo "Reads in $File_BaseName1.fastq: $ReadCount1" 
#echo "Reads in $File_BaseName2.fastq: $ReadCount2"

###################################################################################### STEP1 COUNTING READS IS DONE!

## STEP2: Performing QUALITY TRIMMING

VERBOSE=OUTPUT_FILE_NAME

echo "Started Quality Trimming"
#echo "Starting Quality Trimming" >$VERBOSE.fastx_toolkit_verbose

fastq_quality_trimmer -Q33 -t 30 -l 30 -i $File_BaseName1.fastq -o $File_BaseName1.quality.trimmed.fastq -v >>$VERBOSE.fastx_toolkit_verbose
fastq_quality_trimmer -Q33 -t 30 -l 30 -i $File_BaseName2.fastq -o $File_BaseName2.quality.trimmed.fastq -v >>$VERBOSE.fastx_toolkit_verbose

#QT_ReadCount1=` grep -c "^+$"  $File_BaseName1.quality.trimmed.fastq` 
#QT_ReadCount2=` grep -c "^+$"  $File_BaseName2.quality.trimmed.fastq` 

#echo "Reads in $File_BaseName1.fastq: $QT_ReadCount1" 
#echo "Reads in $File_BaseName2.fastq: $QT_ReadCount2"

###################################################################################### STEP2 QUALITY TRIMMING IS DONE!

## STEP3: Performing QUALITY FILTERING

echo "Starting Quality Filtering" 
echo "Starting Quality Filtering" >>$VERBOSE.fastx_toolkit_verbose

fastq_quality_filter -Q33 -q 30 -p 30 -i $File_BaseName1.quality.trimmed.fastq -o $File_BaseName1.quality.trimmed.filtered.fastq -v >>$VERBOSE.fastx_toolkit_verbose
fastq_quality_filter -Q33 -q 30 -p 30 -i $File_BaseName2.quality.trimmed.fastq -o $File_BaseName2.quality.trimmed.filtered.fastq -v >>$VERBOSE.fastx_toolkit_verbose

#QF_QT_ReadCount1=` grep -c "^+$"  $File_BaseName1.quality.trimmed.filtered.fastq` 
#QF_QT_ReadCount2=` grep -c "^+$"  $File_BaseName2.quality.trimmed.filtered.fastq` 

#echo "Reads in $File_BaseName1.fastq: $QF_QT_ReadCount1" 
#echo "Reads in $File_BaseName2.fastq: $QF_QT_ReadCount2"

###################################################################################### STEP3 QUALITY FILTERING IS DONE!

## STEP4: Performing DECONTAMINATION

# Decontamination step1 - FINDING CONTAMINANT READS [output files are contamination_unmapped.fastq, contamination_mapped.fastq]
bowtie --un $OUTPUT_FILE_NAME.read1_2.quality.trimmed.filtered.fastq.contamination_unmapped.fastq --al $OUTPUT_FILE_NAME.read1_2.contamination_mapped.fastq /home/prakkisr/Seabass_Silok_Transcriptome/Contaminant/Contamination.fasta.idx $File_BaseName1.quality.trimmed.filtered.fastq,$File_BaseName2.quality.trimmed.filtered.fastq -t -p 5 #collect unmapped reads and reads mapping to bacteria
#bowtie --un sample.read1_2.quality.trimmed.filtered.fastq.contamination_unmapped.fastq --al sample.read1_2.contamination_mapped.fastq /home/prakkisr/Seabass_Silok_Transcriptome/Contaminant/Contamination.fasta.idx sample.Read1.quality.trimmed.filtered.fastq,sample.Read2.quality.trimmed.filtered.fastq -t -p 3 

# Decontamination step2 - RETAINING THE SEABASS SPECIFIC READS [output files are .Onlycontamination_mapped.fastq, .contamination_NTZF_mapped.fastq]
bowtie --un $OUTPUT_FILE_NAME.read1_2.Onlycontamination_mapped.fastq --al $OUTPUT_FILE_NAME.read1_2.contamination_SB_Genome_Scaff_mapped.fastq /data/LaszloLab/SB_Genome_90X_Scaffolds/PB_3807_Scaffolds.INDEX $OUTPUT_FILE_NAME.read1_2.contamination_mapped.fastq -t -p 5 #mapping contaminant reads to genome, to retain the seabass specfic reads
#bowtie --un sample.read1_2.Onlycontamination_mapped.fastq --al sample.read1_2.contamination_SB_Genome_Scaff_mapped.fastq /data/LaszloLab/SB_Genome_90X_Scaffolds/PB_3807_Scaffolds.INDEX sample.read1_2.contamination_mapped.fastq -t -p 3 

##Decontamination step3 - Append the retained reads to the contaminant unmapped reads

FILE=$OUTPUT_FILE_NAME.read1_2.contamination_SB_Genome_Scaff_mapped.fastq

if [ -f $FILE  ];
then
   echo "File $FILE exists"
   cat $FILE >>$OUTPUT_FILE_NAME.read1_2.quality.trimmed.filtered.fastq.contamination_unmapped.fastq
else
   echo "File $FILE does not exists, proceeding with unmapped reads."
   
fi

###################################################################################### STEP4 DECONTAMINATION IS DONE!

## STEP5: Seperate the Reads into two paired end files

perl sepPE_Reads.pl $OUTPUT_FILE_NAME.read1_2.quality.trimmed.filtered.fastq.contamination_unmapped.fastq

rm -rf cleaned_data						
mkdir cleaned_data

mv $OUTPUT_FILE_NAME.read1_2.quality.trimmed.filtered.fastq.contamination_unmapped.Read1.fastq cleaned_data/$OUTPUT_FILE_NAME.cleaned.unordered.Read1.fastq
mv $OUTPUT_FILE_NAME.read1_2.quality.trimmed.filtered.fastq.contamination_unmapped.Read2.fastq cleaned_data/$OUTPUT_FILE_NAME.cleaned.unordered.Read2.fastq

###################################################################################### STEP5 SEPERATED READS IS DONE!

## STEP6: RE-ORDERING THE PAIRED END FILES
#sh cleaned_data/ReadsInOrder.sh cleaned_data/$OUTPUT_FILE_NAME.cleaned.unordered.Read1.fastq $OUTPUT_FILE_NAME.cleaned.unordered.Read2.fastq

python pairUp_PE.py cleaned_data/$OUTPUT_FILE_NAME.cleaned.unordered.Read1.fastq cleaned_data/$OUTPUT_FILE_NAME.cleaned.unordered.Read2.fastq cleaned_data/$OUTPUT_FILE_NAME.cleaned.ordered.Read1.fastq cleaned_data/$OUTPUT_FILE_NAME.cleaned.ordered.Read2.fastq cleaned_data/$OUTPUT_FILE_NAME.cleaned.ORPHAN.Reads.fastq

cat cleaned_data/$OUTPUT_FILE_NAME.cleaned.ordered.Read1.fastq | paste - - - - | sort -k1,1 -t " " | tr "\t" "\n" > cleaned_data/$OUTPUT_FILE_NAME.cleaned.sorted.Read1.fastq 
cat cleaned_data/$OUTPUT_FILE_NAME.cleaned.ordered.Read2.fastq | paste - - - - | sort -k1,1 -t " " | tr "\t" "\n" > cleaned_data/$OUTPUT_FILE_NAME.cleaned.sorted.Read2.fastq 


###################################################################################### STEP6 RE-ORDERING READS IS DONE!

##Counting reads again in all files
rm $OUTPUT_FILE_NAME.ReadCounts.txt
 grep -c "^+$" $OUTPUT_FILE_NAME*fastq >$OUTPUT_FILE_NAME.ReadCounts.txt
 grep -c "^+$" cleaned_data/$OUTPUT_FILE_NAME*fastq >>$OUTPUT_FILE_NAME.ReadCounts.txt

 rm *quality.trimmed.fastq
 rm *quality.trimmed.filtered.fastq
 rm *_unmapped.fastq
 rm cleaned_data/*cleaned.unordered*
 rm cleaned_data/*cleaned.ordered*

rm -rf Contaminant_Related_Files
mkdir Contaminant_Related_Files
 mv *_mapped.fastq Contaminant_Related_Files
