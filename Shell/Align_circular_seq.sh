cat iNDMv4db_deduplicated.fasta | sed 's/ /_/g' | paste - - | awk '{print $1,$2""$2}' | awk '{print $1"\n"$2}' >iNDMv4db_deduplicated_concat.fasta


makeblastdb -in iNDMv4db_deduplicated_concat.fasta -dbtype nucl -out iNDMv4db_deduplicated_concat.fasta.DB -logfile tmp.log

time blastn -db iNDMv4db_deduplicated_concat.fasta.DB -query iNDMv4db_deduplicated.fasta -outfmt '6 qseqid sseqid pident nident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen qcovs qcovhsp qcovus' -out Circular_Sequences_blastresults.txt -num_threads 48

sort -nrk4,4 Circular_Sequences_blastresults.txt | awk '$4>=35947' >Circular_Sequences_blastresults.filtered.txt

cat Circular_Sequences_blastresults.filtered.txt | awk '$3==100 && $5==$14' | awk '$1!=$2' | cut -f1,2

Ran the CLustR Maps

