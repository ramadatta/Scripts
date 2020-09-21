#!/bin/bash

# Extract flanking regions from circular sequence

# This script takes the flanking region size from the user and extracts the NDM gene and the flanking regions.
# This script assumes that the fasta sequence given as input is a circular sequence
# The script should be placed in a folder containing fasta sequences and expects the NDM gene database generated from makeblastdb blast. NDM gene used here: KC537739.1

# Usage: bash extractFlanking_fromCircSeq_v3.sh 


for circSeq in $(ls *.fa); do 

basename=$(echo $circSeq | sed -e s/.fa$//)

# BLAST the circular sequence against the NDM gene of 813 bp

blastn -db NDM_Gene_KC537739.1.DB -query <(cat $circSeq | sed 's/ /_/g') -outfmt '6 qseqid sseqid pident nident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen' >"$basename"_vs_NDM_blastresults.txt

# Extract the coordinates of the NDM gene from BLAST results
cat "$basename"_vs_NDM_blastresults.txt | awk '{print($1"\t"$8"\t"$9"\t"$NF"\t"$(NF-1))}' >"$basename"_qcon_qstart_qend_slen_qlen.coords


while read line; do 
x="5000"; # Flanking regions length
echo $line; 
contigName=`echo $line | awk '{print $1}'`; 
qstart=`echo $line | awk '{print $2}'`; # NDM gene start
qend=`echo $line | awk '{print $3}'`; # NDM gene end
slen=`echo $line | awk '{print $4}'`; #NDM gene length
qlen=`echo $line | awk '{print $NF}'`; # Length of the Input fasta sequence

	if [ $qlen -gt $((slen+2*x)) ]; 
		then 
		 echo "qstart=$qstart, qend=$qend, qlen=$qlen, x=$x - Flanking the regions, generating the region coordinates first";
			leftFlank=$((qstart-x)); 
			rightFlank=$((qend+x));

			echo "Left flank has this: $leftFlank"
			echo "Right flank has this: $rightFlank"
			
			if [ $leftFlank -lt 0 ]; #$((num1 + num2)) # (qlen – (x-qstart):qlen, 1:qend +x)
			then
			echo "(qlen - (x-qstart):qlen, 1:qend +x)";
			echo "($qlen-($x-$qstart):$qlen, 1:($qend+$x))"; 
			echo "bedtools format: ($qlen-($x-$qstart)-1:$qlen, 0:($qend+$x))"; #bedtools has 0 coordinate system for the first coordinate, 1 coordinate system for the second
			echo -e "bedtools format: $((qlen-(x-qstart)-1)):$qlen, 0:$((qend+x)))";
			echo -e "$contigName\t$(((qlen-(x-qstart))-1))\t$qlen";
			echo -e "$contigName\t0\t$((qend+x))";

	bedtools getfasta -fi "$basename".fa -bed <(echo -e "$contigName\t$(((qlen-(x-qstart))-1))\t$qlen\t"$contigName"_NDMflanked") -fo "$basename"_Seq1.fa -name
	bedtools getfasta -fi "$basename".fa -bed <(echo -e "$contigName\t0\t$((qend+x))\t"$contigName"_NDMflanked") -fo "$basename"_Seq2.fa -name

	seqkit concat "$basename"_Seq1.fa "$basename"_Seq2.fa >"$basename"_NDM_FlankingRegions.fa

	mkdir "$basename"_FlankSize_"$x";
	mv "$basename".*.fai "$basename"_FlankSize_"$x";
	mv "$basename"_* "$basename"_FlankSize_"$x";

			elif [ $rightFlank -gt $qlen ]; #(qstart-x:qlen),1:((qend+x)-qlen)
			then
			echo "(qstart-x:qlen),1:((qend+x)-qlen)";
			echo "($qstart-$x:$qlen), 1:(($qend+$x)-$qlen)";
			echo "bedtools format: ($qstart-$x-1:$qlen), 0:(($qend+$x)-$qlen)";
			
			echo -e "bedtools format: $(((qstart-x)-1)):$qlen, 0:$(((qend+x)-qlen))";
			echo -e "$contigName\t$$(((qstart-x)-1))\t$qlen";
			echo -e "$contigName\t0\t$(((qend+x)-qlen))";
	
	bedtools getfasta -fi "$basename".fa -bed <(echo -e "$contigName\t$(((qstart-x)-1))\t$qlen\t"$contigName"_NDMflanked") -fo "$basename"_Seq1.fa -name
	bedtools getfasta -fi "$basename".fa -bed <(echo -e "$contigName\t0\t$(((qend+x)-qlen))\t"$contigName"_NDMflanked") -fo "$basename"_Seq2.fa -name

	seqkit concat "$basename"_Seq1.fa "$basename"_Seq2.fa >"$basename"_NDM_FlankingRegions.fa

	mkdir "$basename"_FlankSize_"$x";
	mv "$basename".*.fai "$basename"_FlankSize_"$x";
	mv "$basename"_* "$basename"_FlankSize_"$x";
			else #qstart – x : qend + x
			echo "startNDM – x : endNDM + x";
			echo "qstart-x:qend+x";	
			echo "bedtools format: qstart-x-1:qend+x";	
			echo -e "bedtools format: $(((qstart-x)-1)):$((qend+x))";	
			echo -e "$contigName\t$(((qstart-x)-1))\t$((qend+x))";

	bedtools getfasta -fi "$basename".fa -bed <(echo -e "$contigName\t$(((qstart-x)-1))\t$((qend+x))\t"$contigName"_NDMflanked") -fo "$basename"_NDM_FlankingRegions.fa -name

	mkdir "$basename"_FlankSize_"$x";
	mv "$basename".*.fai "$basename"_FlankSize_"$x";
	mv "$basename"_* "$basename"_FlankSize_"$x";
			fi	
				
		else 
		echo "extract entire fasta, because input fasta length $qlen is less than the flanking region length which is $((813+2*x)) (NDM+2*FlankingRegion)"; 
#		echo "bedtools format: 0:qlen";
#		echo "bedtools format: 0:$qlen";
		echo -e "$contigName\t0\t$qlen";

		mkdir "$basename"_FlankSize_"$x";
		cp "$basename".fa "$basename"_FlankSize_"$x"/"$basename"_NDM_FlankingRegions.fa;
	fi 
done <"$basename"_qcon_qstart_qend_slen_qlen.coords


echo $d; done
