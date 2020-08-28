#!/bin/bash

blastResults_file=$1
#echo "In BASH script $blastResults_file"

temp_merged_intervals=`echo $blastResults_file | sed 's/.txt//g'`
#echo "In BASH script $temp_merged_intervals"

#for d in $(ls *.fasta);  do blastn -db /home/prakki/sw/CPgeneProfiler/CPGP_17092020/CPgeneProfiler/testData/db/NCBI_BARRGD_CPG.DB -query <(sed 's/ /_/g' $d)  -outfmt '6 qseqid sseqid pident nident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen'  | awk '{print $0,($5*100)/$NF}'  |awk '$3>99.5 && $NF>99.5' | awk '{print $0"\t"$3*$NF}' | sort -grk17,17 >"$d"_vs_NCBI_BARRGD_CPG_DB_BlastResults_min99.5_pident_cov.txt & done


bedtools merge -i <(cat $blastResults_file | awk '{print $1"\t"$8"\t"$9}' | sortBed) >"$temp_merged_intervals"_bedtools_merge.txt;

#echo "bedtools done with $blastResults_file";
