#!/bin/bash

#echo "Type the coordinate index sorted bam file name\n";
rm -R SAM_output_Headers
mkdir SAM_output_Headers
#$BAM_FILE=<>;
BAM_FILE=$1 #500bp_insert_mapping_subset2_sorted.bam
#echo $BAM_FILE

samtools view -f 0x2 $BAM_FILE | cut -f1 >SAM_output_Headers/Properly_Paired_Read_headers.txt
Properly_paired="$(samtools view -f 0x2 $BAM_FILE| cut -f 1 | wc -l)"
#samtools view -f 0x2 $BAM_FILE| cut -f 1 | wc -l
echo "Properly paired with correct insert distances: $Properly_paired"

samtools view -F 2 -f 1 $BAM_FILE | awk '$7!="*" {print $0}' | cut -f1  >SAM_output_Headers/Mates_out_of_InsertSizeRange_headers.txt
Out_of_Range="$(samtools view -F 2 -f 1 $BAM_FILE | awk '$7!="*" {print $0}' | wc -l)" ## mates out of insert Size range
echo "Wrong insert Distance or mates inverted: $Out_of_Range"

#samtools view $BAM_FILE | cut -f7 | fgrep '*' | cut -f1 >Broken_Reads.txt
Broken_Reads="$(samtools view $BAM_FILE | cut -f7 | fgrep '*' | wc -l)" ##Contains mates on different contigs + mates does not map
echo "Broken Reads: $Broken_Reads"

samtools view $BAM_FILE | awk '$7=="*" {print $0}' | cut -f1 -d "_" | sort | uniq -c | sort -nr | fgrep '      1' >SAM_output_Headers/Mates_does_not_map.txt
Mates_does_not_map="$(samtools view $BAM_FILE | awk '$7=="*" {print $0}' | cut -f1 -d "_" | sort | uniq -c | sort -nr | fgrep -c '      1')"

echo "Out of $Broken_Reads broken reads $Mates_does_not_map does not have a mate mapped"

samtools view $BAM_FILE | awk '$7=="*" {print $0}' | cut -f1 -d "_" | sort | uniq -c | sort -nr | fgrep '      2' >SAM_output_Headers/Mates_falling_diff_contigs.txt
Mates_falling_diff_contigs="$(samtools view $BAM_FILE | awk '$7=="*" {print $0}' | cut -f1 -d "_" | sort | uniq -c | sort -nr | fgrep -c '      2')"

echo "Out of $Broken_Reads broken reads, $Mates_falling_diff_contigs pairs fall on different contigs"

#echo -e "total numbers of reads is: Properly_paired ($Properly_paired) + Out_of_Range ($Out_of_Range) + Broken_Reads ($Broken_Reads)\n";


