#!/bin/bash

## 1) This script takes Ensemble protein fasta sequences as input
## 2) Remove sequence duplicates and extracts the longest isoforms for each gene (useful in ortholog analysis)

##Script Author: Prakki Sai Rama Sridatta
##Date: January 27,2015
##Email: prakkisr@tll.org.sg // ramadatta.88@gmail.com

## Usage: ./extract_oneProt_Per_EnsemblGene.sh Homo_sapiens.GRCh38.pep.all.fa ## Better if Input filename should not have more than one period (.), because chops first portion

if [ ! -f "$1" ]; then

  echo 'Usage: ./extract_oneProt_Per_EnsembleGene.sh Homo_sapiens.GRCh38.pep.all.fa'
  exit 0

fi

#GenPeptFile=$1 #Homo_sapiens.gp

#trimmed_GenPeptName=$(echo $GenPeptFile | cut -d "." -f1) #Salmo_salar

RawFasta=$1 #Homo_sapiens.fasta

trimmed_RawFastaName=$(echo $RawFasta | cut -d "." -f1)

echo "Removing Exact Sequence Duplicates from the \"$RawFasta\" file..STEP 1 OUT 3" 

sed -e '/^>/s/$/@/' -e 's/^>/#/' $RawFasta | tr -d '\n'|tr "#" "\n"| tr "@" "\t" |sort -u -t '	' -f -k 2,2 |sed '/^$/d'|sed -e 's/^/>/' -e 's/\t/\n/' >$trimmed_RawFastaName\_.oneline_NoDUP.fasta

#echo "trimmed name is \"$var1\""

echo "Finding the lengths from fasta file..STEP 2 OUT 3"

sed '/^>/s% pep.*gene:%	%' $trimmed_RawFastaName\_.oneline_NoDUP.fasta | sed '/^>/s% transcript:.*%%' | awk '/^>/ {if (seqlen) print seqlen;print;seqlen=0;next} {seqlen+=length($0)}END{print seqlen}' | sed '/^>/s%>%%' | paste - - | sort -t "	" -k2,2 -k3nr,3 | perl -e 'while(<>) { @data = split; if (!exists( $test{$data[1]} ) ) { print $_; } $test{$data[1]} = $_; }' >$trimmed_RawFastaName\_longestProt_headers.txt

echo "Extracting the longest Isoform for each gene..STEP 3 OUT 3"
fgrep -A 1 -f <(cut -d "	" -f 1 $trimmed_RawFastaName\_longestProt_headers.txt) $trimmed_RawFastaName\_.oneline_NoDUP.fasta | sed 's/--//g' | sed '/^$/d' >$trimmed_RawFastaName\_longestProt.fasta
