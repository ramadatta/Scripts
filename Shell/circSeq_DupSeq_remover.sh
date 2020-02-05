# Author: Prakki Sai Rama Sridatta

# Date: January 28, 2020

# A shell script to remove duplicates (including circular sequences) from the fasta file

# Usage: perl circSeq_DupSeq_remover.sh

#!/usr/bin/bash

#take the fasta file from the terminal
input_fasta=$1;
prefix=`echo $input_fasta | sed 's/.fasta//g'`;
echo "your input is $input_fasta, prefix will be $prefix";
date

#Renaming Header of fasta to suit the need of the rest of the script
sed -r 's/\s+/| /' $input_fasta | sed -r 's/>/>gbk|/' | sed -e 's/,/_/g' -e 's/ /_/g' | sed -e 's/__/_/g' -e 's/|_/__/g' -e 's/>gbk|/>gbk_/g' >"$prefix".renamed.fasta
date

#convert the multi-fasta file to oneline fasta
echo "converting your multi-fasta file input "$prefix".renamed.fasta, to oneline fasta $prefix.oneline.fasta"
awk '{if(NR==1) {print $0} else {if($0 ~ /^>/) {print "\n"$0} else {printf $0}}}' "$prefix".renamed.fasta >"$prefix".oneline.fasta
date

# append the sequence of each sequence to the end again
echo "appending sequences at the end to make circular sequences"
cat "$prefix".oneline.fasta | tr '\n' '@' | tr '>' '\n' | sed 's/@$//g' | sed '/^$/d' | awk -F'@' '{print ">"$1,$2.$2}' | tr ' ' '\n' >"$prefix"_Seqconcat.fasta
date

#Blast
echo "Blasting $prefix.oneline.fasta to circular sequences";
makeblastdb -in "$prefix"_Seqconcat.fasta -dbtype nucl -out "$prefix"_Seqconcat.fasta.DB
time blastn -db "$prefix"_Seqconcat.fasta.DB -query "$prefix".oneline.fasta -outfmt '6 qseqid sseqid pident nident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen' -out "$prefix"_vs_"$prefix"_Seqconcat_blastresults.txt -num_threads 48
echo "Blasting $prefix.oneline.fasta to circular sequences is done!!";
date

#Generate the pairsof duplicate sequences that have (qlength==alignment length) 100% alignment and 100% qcoverage and does not have hit to the same sequence 
echo "Possible duplicate pairs";
cat "$prefix"_vs_"$prefix"_Seqconcat_blastresults.txt | awk '$(NF-1)==$4 && $3==100 && $1!=$2 && ($NF/2)==$(NF-1)' | cut -f1,2 >"$prefix"_DuplicatePairs_Plausible.txt
date

#Cluster the duplicate sequences - form the clusters
# -- perl ClustrPairs.pl "$prefix"_DuplicatePairs_Plausible.txt
#sort the sequence from the cluster according to accession and choose the one with "N" else choose the top sequence
echo "choosing the best possible sequence from each cluster - preference given to refSeq sequences"
sed -e /^gbk_NC/s/^/_1/ -e /^gbk_AC/s/^/_1/ -e /^gbk_NG/s/^/_1/  -e /^gbk_NT/s/^/_1/  -e /^gbk_NW/s/^/_1/  -e /^gbk_NZ/s/^/_1/  -e /^gbk_NM/s/^/_1/  -e /^gbk_NR/s/^/_1/  -e /^gbk_XM/s/^/_1/  -e /^gbk_XR/s/^/_1/ -e /^gbk_CP/s/^/_2/  <(perl ClustrPairs_v3.pl *_DuplicatePairs_Plausible.txt) | sed '/^gbk_/s/^/_3/' | awk -v OFS='\t' 'match($0,/.*gbk\_.*\..*__/){print $0,substr($0,RSTART,RLENGTH)};match($0,/.*Cluster.*/){print $0}' | awk 'BEGIN { id=2000; }{if ( NF == 2 ){print id$(NF-1);}else{id++;print id"_0"$NF;id++;}}' | sort -nk1,1 | sed 's/^...._.//g'
date

# greppiong fpr refseq accession IDS <(perl ClustrPairs_v3.pl "$prefix"_DuplicatePairs_Plausible.txt) | sed '/^gbk_/s/^/_1/' | ease of AWK coding making into 2 fields | adding running number prefix for sorting (copied from forum https://www.linuxquestions.org/questions/linux-newbie-8/sort-lines-inside-blocks-in-a-file-716913/) | sort -rn | sed 's/^...._.//g'

#create a file without duplicate sequences
echo "Generating deduplicated fasta file"
fgrep -A1 -w -f <(fgrep -v -f <(perl ClustrPairs_v3.pl "$prefix"_DuplicatePairs_Plausible.txt| grep -v "^-") "$prefix".oneline.fasta | fgrep '>') "$prefix".oneline.fasta | sed 's/-//g' | sed '/^$/d' >"$prefix".unique.fasta

#fgrep extract unique sequences <(fgrep extract the unique headers  <(find the duplicate and form clusters| grep -v "^-") "$prefix".oneline.fasta | fgrep '>') "$prefix".oneline.fasta | sed 's/-//g' | sed '/^$/d' >"$prefix".unique.fasta

#create a fasta file with the representative fasta sequence for each of the cluster
fgrep -w -A1 -f <(sed -e /^gbk_NC/s/^/_3/ -e /^gbk_AC/s/^/_3/ -e /^gbk_NG/s/^/_3/  -e /^gbk_NT/s/^/_3/  -e /^gbk_NW/s/^/_3/  -e /^gbk_NZ/s/^/_3/  -e /^gbk_NM/s/^/_3/  -e /^gbk_NR/s/^/_3/  -e /^gbk_XM/s/^/_3/  -e /^gbk_XR/s/^/_3/ -e /^gbk_CP/s/^/_2/  <(perl ClustrPairs_v3.pl "$prefix"_DuplicatePairs_Plausible.txt) | sed '/^gbk_/s/^/_1/' | awk -v OFS='\t' 'match($0,/.*gbk\_.*\..*__/){print $0,substr($0,RSTART,RLENGTH)};match($0,/.*Cluster.*/){print $0}' | awk 'BEGIN { id=2000; }{if ( NF == 2 ){print id$(NF-1);}else{id--;print id"_0"$NF;id--;}}' | sort -rn | sed 's/^...._.//g' | fgrep -A1 'Cluster' | sed 's/^--//g' | sed '/^$/d' |paste - - | awk '{print $2}') "$prefix".oneline.fasta >"$prefix".dupsRepresentative.fasta


##Append both of the fasta files
cat "$prefix".unique.fasta "$prefix".dupsRepresentative.fasta >"$prefix".deduplicated.fasta
echo "Generating deduplicated fasta file is done! Thanks much!!"
date
