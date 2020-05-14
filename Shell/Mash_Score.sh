
# Prakki Sai Rama Sridatta

# May 14, 2020


# % This script run Mash on two datasets by taking fasta files
# 1) Step1 creates pairs seperated by Hash from Mash output 
# 2) Step2 assigns the closest sequence to the nanopore sequence from the whole Database

#Usage: ./Mash_Score.sh <nanopore.fa> <Gbk_Nanopore.fa>

NP_Fasta=$1
Gbk_NP_Fasta=$2
Gbk_NP_Fasta_base=`echo $Gbk_NP_Fasta | sed 's/.fasta//g'`

sed 's/ /_/g' $Gbk_NP_Fasta >"$Gbk_NP_Fasta_base"_trimSpace.fasta

mash sketch -i "$Gbk_NP_Fasta_base"_trimSpace.fasta 
mash sketch -i $NP_Fasta

echo "\n--------Mashing---------------\n"
time mash dist $NP_Fasta.msh "$Gbk_NP_Fasta_base"_trimSpace.fasta.msh >"$NP_Fasta"_vs_"$Gbk_NP_Fasta_base"_Mash.out

echo "\n--------Mash pairing---------------\n"
# Mash Pair for Assigning Mash score for plasmid call
cat "$NP_Fasta"_vs_"$Gbk_NP_Fasta_base"_Mash.out | sed 's/|_/ /g' | awk '{print $1"_Plasmid.fasta#"$3,$4}' >"$NP_Fasta"_vs_"$Gbk_NP_Fasta_base"_Mash_Pair.out

echo "\n--------Top Best hit Assignment---------------\n"
# Nanopore Plasmid Top best Mash score 
for d in $(cut -f1 "$NP_Fasta"_vs_"$Gbk_NP_Fasta_base"_Mash.out | sort -u); do grep "^$d" "$NP_Fasta"_vs_"$Gbk_NP_Fasta_base"_Mash_Pair.out | awk '{ print $1,sprintf("%.9f", $2); }' | sort -gk2,2 | head -1 ; done >"$NP_Fasta"_vs_"$Gbk_NP_Fasta_base"_TopHit_MashScore.out
