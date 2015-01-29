#!/bin/bash

## 1) This script takes genpept file and fasta sequences as input
## 2) Remove sequence duplicates and extracts the longest isoforms for each gene (useful in ortholog analysis)

##Script Author: Prakki Sai Rama Sridatta
##Date: January 27,2015
##Email: prakkisr@tll.org.sg // ramadatta.88@gmail.com

## Usage: ./extract_oneProt_PerGene.sh Organism_Refseq.gp Organism_RefSeq.fasta ## Input filename should not have more than one period (.)

if [ ! -f "$1" ] || [ ! -f "$2" ]; then

  echo 'Usage: ./extract_oneProt_PerGene.sh Homo_sapiens.gp Homo_sapiens.fasta'
  exit 0

fi

GenPeptFile=$1 #Homo_sapiens.gp

trimmed_GenPeptName=$(echo $GenPeptFile | cut -d "." -f1) #Salmo_salar

RawFasta=$2 #Homo_sapiens.fasta

echo "Removing Exact Sequence Duplicates from the \"$RawFasta\" file..STEP 1 OUT 3" 
sed -e '/^>/s/$/@/' -e 's/^>/#/' $RawFasta | tr -d '\n'|tr "#" "\n"| tr "@" "\t" |sort -u -t '	' -f -k 2,2 |sed '/^$/d'|sed -e 's/^/>/' -e 's/\t/\n/' >$trimmed_GenPeptName\_RefSeq.oneline_NoDUP.fasta

#echo "trimmed name is \"$var1\""
echo "Processing the GenPept file..STEP 2 OUT 3"
perl 2extract_Acc_Len_geneName.pl $GenPeptFile | sort -t "	" -k2,2 -k3nr,3 | perl -e 'while(<>) { @data = split; if (!exists( $test{$data[1]} ) ) { print $_; } $test{$data[1]} = $_; }' >$trimmed_GenPeptName\_RefSeq_longestProt_headers_from_GenPeptFile.txt

#set posix
echo "Extracting the longest Isoform for each gene..STEP 3 OUT 3"
fgrep -A 1 -f <(cut -d "	" -f 1 $trimmed_GenPeptName\_RefSeq_longestProt_headers_from_GenPeptFile.txt) $trimmed_GenPeptName\_RefSeq.oneline_NoDUP.fasta | sed 's/--//g' | sed '/^$/d' >$trimmed_GenPeptName\_longestProt.fasta
