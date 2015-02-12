#!/bin/sh
 
#$ -cwd
#$ -V
#$ -pe smp 4
## Join the standard error and the standard output into 1 file output
#$ -j y

##File names
ORGAN=Genome
basename1=500bp_insert_lane1_2_read1PE_single_appended
basename2=500bp_insert_lane1_2_read2PE_single_appended

echo "started @"
date
echo "$basename1.adapter.trimmed.fastq"

###Dont forget to change the adapters for different samples!!!

echo "Started Adapter trim"
~/sw/cutadapt-1.2.1/bin/cutadapt -b AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT -b AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT -b CAAGCAGAAGACGGCATACGAGATACAGTGGTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT -b AGATCGGAAGAGCACACGTCTGAACTCCAGTCACCACAGTGTCTCGTATGCCGTCTTCTGCTTG -b GATCGGAAGAGCACACGTCTGAACTCCAGTCAACAGTGATCTCGTATGCCGTCTTCTGCTTG -b CAAGCAGAAGACGGCATACGAGATGTGAAAGTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT -b AGATCGGAAGAGCACACGTCTGAACTCCAGTCACCGTGAAATCTCGTATGCCGTCTTCTGCTTG -b GATCGGAAGAGCACACGTCTGAACTCCAGTCAGTGAAAATCTCGTATGCCGTCTTCTGCTTG 500bp_insert_lane1_2_read1PE_single_appended.fastq >$basename1.adapter.trimmed.fastq
~/sw/cutadapt-1.2.1/bin/cutadapt -b AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT -b AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT -b CAAGCAGAAGACGGCATACGAGATACAGTGGTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT -b AGATCGGAAGAGCACACGTCTGAACTCCAGTCACCACAGTGTCTCGTATGCCGTCTTCTGCTTG -b GATCGGAAGAGCACACGTCTGAACTCCAGTCAACAGTGATCTCGTATGCCGTCTTCTGCTTG -b CAAGCAGAAGACGGCATACGAGATGTGAAAGTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT -b AGATCGGAAGAGCACACGTCTGAACTCCAGTCACCGTGAAATCTCGTATGCCGTCTTCTGCTTG -b GATCGGAAGAGCACACGTCTGAACTCCAGTCAGTGAAAATCTCGTATGCCGTCTTCTGCTTG  500bp_insert_lane1_2_read2PE_single_appended.fastq >$basename2.adapter.trimmed.fastq

Read1Cnt=`LC_ALL=C fgrep -c ":N:"  500bp_insert_lane1_2_read1PE_single_appended.fastq`
Read2Cnt=`LC_ALL=C fgrep -c ":N:"  500bp_insert_lane1_2_read2PE_single_appended.fastq`
echo " 500bp_insert_lane1_2_read1PE_single_appended.fastq read count is $Read1Cnt" >>ReadStats.txt
echo " 500bp_insert_lane1_2_read2PE_single_appended.fastq read count is $Read2Cnt" >>ReadStats.txt

mkdir original_reads
mv 500bp_insert_lane1_2_read1PE_single_appended.fastq original_reads
mv 500bp_insert_lane1_2_read2PE_single_appended.fastq original_reads


AdapterTrimmed1=$basename1.adapter.trimmed.fastq
AdapterTrimmed2=$basename2.adapter.trimmed.fastq
AdapterTrimmed1Cnt=`LC_ALL=C fgrep -c ":N:"  $AdapterTrimmed1` 
AdapterTrimmed2Cnt=`LC_ALL=C fgrep -c ":N:"  $AdapterTrimmed2`
echo " $AdapterTrimmed1 read count is $AdapterTrimmed1Cnt" >>ReadStats.txt
echo " $AdapterTrimmed2 read count is $AdapterTrimmed2Cnt" >>ReadStats.txt

VERBOSE=Genome_verbose
## Quality Trimming
echo "Started Quality Trimming"
echo "$AdapterTrimmed1 Starting Quality Trimming" >$VERBOSE.fastx_toolkit_verbose
fastq_quality_trimmer -Q33 -t 20 -l 30 -i $AdapterTrimmed1 -o $basename1.adapter.quality.trimmed.fastq -v >>$VERBOSE.fastx_toolkit_verbose

##Deleting the $AdapterTrimmed1 
echo "Deleting $basename1.adapter.trimmed.fastq file @" 
rm $AdapterTrimmed1
date

echo "$AdapterTrimmed2 Starting Quality Trimming" >>$VERBOSE.fastx_toolkit_verbose
fastq_quality_trimmer -Q33 -t 20 -l 30 -i $AdapterTrimmed2 -o $basename2.adapter.quality.trimmed.fastq -v >>$VERBOSE.fastx_toolkit_verbose

##Deleting the $AdapterTrimmed2
#LC_ALL=C fgrep -c ":N:" $basename2.adapter.trimmed.fastq 
echo "Deleting $basename2.adapter.trimmed.fastq file @" 
rm $basename2.adapter.trimmed.fastq
date


AdapterQualityTrimmed1=$basename1.adapter.quality.trimmed.fastq
AdapterQualityTrimmed2=$basename2.adapter.quality.trimmed.fastq

AdapterQualityTrimmed1Cnt=`LC_ALL=C fgrep -c ":N:"  $AdapterQualityTrimmed1`
AdapterQualityTrimmed2Cnt=`LC_ALL=C fgrep -c ":N:"  $AdapterQualityTrimmed2`
echo " $AdapterQualityTrimmed1 read count is $AdapterQualityTrimmed1Cnt" >>ReadStats.txt
echo " $AdapterQualityTrimmed2 read count is $AdapterQualityTrimmed2Cnt" >>ReadStats.txt

## Quality Filtering
echo "$AdapterQualityTrimmed1 Starting Quality Filtering" >>$VERBOSE.fastx_toolkit_verbose

fastq_quality_filter -Q33 -q 20 -p 30 -i $AdapterQualityTrimmed1 -o $basename1.adapter.quality.trimmed.filtered.fastq -v >>$VERBOSE.fastx_toolkit_verbose

echo "Deleting $AdapterQualityTrimmed1 file @" 
rm $AdapterQualityTrimmed1
date

echo "$AdapterQualityTrimmed2 Starting Quality Filtering" >>$VERBOSE.fastx_toolkit_verbose
fastq_quality_filter -Q33 -q 20 -p 30 -i $AdapterQualityTrimmed2 -o $basename2.adapter.quality.trimmed.filtered.fastq -v >>$VERBOSE.fastx_toolkit_verbose

echo "Deleting $AdapterQualityTrimmed2 file @" 
rm $AdapterQualityTrimmed2
date

Adapter_QualityTrimmed_QualityFiltered1=$basename1.adapter.quality.trimmed.filtered.fastq
Adapter_QualityTrimmed_QualityFiltered2=$basename2.adapter.quality.trimmed.filtered.fastq

Adapter_QualityTrimmed_QualityFiltered1Cnt=`LC_ALL=C fgrep -c ":N:"  $Adapter_QualityTrimmed_QualityFiltered1` 
Adapter_QualityTrimmed_QualityFiltered2Cnt=`LC_ALL=C fgrep -c ":N:"  $Adapter_QualityTrimmed_QualityFiltered2` 

echo " $Adapter_QualityTrimmed_QualityFiltered1 read count is $Adapter_QualityTrimmed_QualityFiltered1Cnt" >>ReadStats.txt
echo " $Adapter_QualityTrimmed_QualityFiltered2 read count is $Adapter_QualityTrimmed_QualityFiltered2Cnt" >>ReadStats.txt

echo "$AdapterQualityTrimmed_QualityFiltered1 POLYA/T/N trimming"
## poly A/T/N trimming, Duplicate read removal if number > 100, 
perl /home/prakkisr/sw/prinseq-lite-0.20.3/prinseq-lite.pl -fastq $Adapter_QualityTrimmed_QualityFiltered1 -fastq2 $Adapter_QualityTrimmed_QualityFiltered2 -no_qual_header -min_len 30 -derep 1 -derep_min 101 -trim_tail_left 5 -trim_tail_right 5 -trim_ns_left 1 -trim_ns_right 1 -out_good file_passed

echo "Deleting Adapter_QualityTrimmed_QualityFiltered1 file @" 
rm $Adapter_QualityTrimmed_QualityFiltered1 $Adapter_QualityTrimmed_QualityFiltered2
date

echo "Collecting Mapped reads @"
date
# decontammination [output files contamination_unmapped.fastq, contamination_NTZF_mapped.fastq]
bowtie --un $ORGAN.contamination_unmapped.fastq --al $ORGAN.contamination_mapped.fastq /home/prakkisr/Seabass_Silok_Transcriptome/Contaminant/Contamination.fasta.idx file_passed_1.fastq,file_passed_2.fastq,file_passed_1_singletons.fastq,file_passed_2_singletons.fastq -t -p 2 #collect unmapped reads

bowtie --un $ORGAN.Onlycontamination_mapped.fastq --al $ORGAN.contamination_NTZF_mapped.fastq /home/prakkisr/Seabass_Silok_Transcriptome/NTZF/NTZF.index $ORGAN.contamination_mapped.fastq -t -p 2 #mapping contaminants to retain the fish reads

##Append the retained reads to the contaminant unmapped reads
cat $ORGAN.contamination_NTZF_mapped.fastq >>$ORGAN.contamination_unmapped.fastq

##Rename the file names
echo "Renaming files @"
date
 LC_ALL=C fgrep -A3 '1:N:0:' $ORGAN.contamination_unmapped.fastq >$basename1.$ORGAN.completely.cleaned.fastq
 LC_ALL=C fgrep -A3 '2:N:0:' $ORGAN.contamination_unmapped.fastq >$basename2.$ORGAN.completely.cleaned.fastq

## order the paired reads
echo "Reordering the fastq reads files @"
date
echo "$basename1.$ORGAN.completely.cleaned.fastq $basename2.$ORGAN.completely.cleaned.fastq are being re-order by ReadsInorder script\n";
sh ReadsInOrder.sh $basename1.$ORGAN.completely.cleaned.fastq $basename2.$ORGAN.completely.cleaned.fastq 
echo "Reordering the fastq reads files finished @"
date

##cleanup the intermediate files
mkdir Contamination_RelatedReads;
mv $ORGAN.contamination_mapped.fastq Contamination_RelatedReads;
mv $ORGAN.Onlycontamination_mapped.fastq Contamination_RelatedReads;
mv $ORGAN.contamination_NTZF_mapped.fastq Contamination_RelatedReads;
mv $ORGAN.contamination_unmapped.fastq Contamination_RelatedReads;
#rm GS509_Testis_read1_cleaned.fastq;
#rm GS509_Testis_read2_cleaned.fastq;
mkdir cleanedDataForAssembly;
mv *_matched.fastq cleanedDataForAssembly;
mv *ORPHAN* cleanedDataForAssembly;
## Assembly
echo "ended @"
date
#Trinity_MaxHeapsp2G.pl --seqType fq --JM 2G --left /scratch/natascha/2_R1-split.fastq --right /scratch/natascha/2_R2-split.fastq  --SS_lib_type FR --output brain --group_pairs_distance 470 --min_kmer_cov 2 --CPU 2 --inchworm_cpu 2 --no_cleanup --output /scratch/natascha/2_Results









