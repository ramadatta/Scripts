# Prakki Sai Rama Sridatta

# July 31, 2020

# % This script run blast on two datasets by taking fasta files
# 1) Step1 creates database from user entered
# 2) Step2 performs Blast

# Usage: ./run_blast.sh <query.fa> <database.fa>

query_fasta=$1
query_fasta_base=`echo $query_fasta | sed 's/.fasta//g'`
db_fasta=$2
db_fasta_base=`echo $db_fasta | sed 's/.fasta//g'`



makeblastdb -in $db_fasta -dbtype nucl -out "$db_fasta_base".DB -parse_seqids
blastn -db  "$db_fasta_base".DB -query $db_fasta -outfmt '6 qseqid sseqid pident nident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen' -out $query_fasta_base\_vs_$db_fasta_base\_blastresults.txt -num_threads 48
