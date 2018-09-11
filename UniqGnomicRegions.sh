#!/bin/bash

#Author: PRAKKI SAI RAMA SRIDATTA

#Date: September 11, 2018

#Description: This script compares two genome sequences and outputs unique regions (> 1kb) for both files 

##Usage: bash unique_regions.sh <file1.fasta> <file2.fasta>


fasta1=$1
fasta2=$2

echo "$fasta1\t$fasta2"

## Making databases

makeblastdb -in $fasta1 -dbtype nucl -out "$fasta1".DB
makeblastdb -in $fasta2 -dbtype nucl -out "$fasta2".DB

echo "DATABASES CREATED!!"; echo ""

## BLASTing sequences both ways

blastn -db "$fasta2".DB -query $fasta1 -outfmt '6 qseqid sseqid pident nident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen' -out "$fasta1"_vs_"$fasta2".blastResults.txt -num_threads 6
blastn -db "$fasta1".DB -query $fasta2 -outfmt '6 qseqid sseqid pident nident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen' -out "$fasta2"_vs_"$fasta1".blastResults.txt -num_threads 6

echo "BLAST DONE!!"

### Merging intervals of fasta1

echo "EXTRACTING UNIQUE REGIONS FROM $fasta1!!"

bedtools merge -i <(cat "$fasta1"_vs_"$fasta2".blastResults.txt | cut -f1,8,9 | sort -nk2,2) >"$fasta1"_vs_"$fasta2".bedtools_merged.txt

### Extracting unique region's coordinates from fasta1

awk '/^>/ {if (sqlen){print sqlen}; print ;sqlen=0;next; } { sqlen = sqlen +length($0)}END{print sqlen}' $fasta1 | sed 's/>//g' | paste - - >"$fasta1".length ## Length of sequence since bedtools complement requires this output

bedtools complement -i "$fasta1"_vs_"$fasta2".bedtools_merged.txt -g "$fasta1".length | awk '($3-$2) > 1000' >"$fasta1".unique_gt1kb.regions.coords

### Extracting unique regions from fasta 1

bedtools getfasta -fi $fasta1 -bed "$fasta1".unique_gt1kb.regions.coords -fo "$fasta1".unique_gt1kb.regions.fasta

echo "DONE!"

### Merging intervals of fasta2

echo "EXTRACTING UNIQUE REGIONS FROM $fasta2!!"

bedtools merge -i <(cat "$fasta2"_vs_"$fasta1".blastResults.txt | cut -f1,8,9 | sort -nk2,2) >"$fasta2"_vs_"$fasta1".bedtools_merged.txt

### Extracting unique region's coordinates from fasta2

awk '/^>/ {if (sqlen){print sqlen}; print ;sqlen=0;next; } { sqlen = sqlen +length($0)}END{print sqlen}' $fasta2 | sed 's/>//g' | paste - - >"$fasta2".length ## Length of sequence since bedtools complement requires this output

bedtools complement -i "$fasta2"_vs_"$fasta1".bedtools_merged.txt -g "$fasta2".length | awk '($3-$2) > 1000' >"$fasta2".unique_gt1kb.regions.coords

### Extracting unique regions from fasta 2

bedtools getfasta -fi $fasta2 -bed "$fasta2".unique_gt1kb.regions.coords -fo "$fasta2".unique_gt1kb.regions.fasta

echo "DONE!"





