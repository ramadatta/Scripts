
# This Script takes the SRST2 sorted BAM file and extracts properly paired mapped reads and improperly paired mapped reads

# Then using the reads mapped to specific region, it generates a denovo spades assembly

# Then the denovo contigs are ordered by reference region using abacus tool

for d in $(ls -d */ | tr -d "/"); do 

	echo $d; 

cd $d; 

	echo "For Sample "$d" generating R1 & R2 mapped BAM ... STEP1/STEP10 "
	# R1 & R2 mapped
	samtools view -u -f 1 -F 12 test_srst2__"$d".ICETn43716385.sorted.bam > Sample__"$d".ICETn43716385_R1_R2_properlymapped.bam

	echo "For Sample "$d" generating R1 unmapped, R2 mapped BAM ... STEP2/STEP10"
	# R1 unmapped, R2 mapped

	samtools view -u -f 4 -F 264 test_srst2__"$d".ICETn43716385.sorted.bam > Sample__"$d".ICETn43716385_R1_unmapped_R2_mapped.bam

	echo "For Sample "$d" generating R1 mapped, R2 unmapped BAM ... STEP3/STEP10"
	# R1 mapped, R2 unmapped
	samtools view -u -f 8 -F 260 test_srst2__"$d".ICETn43716385.sorted.bam > Sample__"$d".ICETn43716385_R1_mapped_R2_unmapped.bam

	echo "For Sample "$d" merging proper and improper reads BAM files ... STEP4/STEP10"
	samtools merge -u Sample__"$d".ICETn43716385_R1_R2_improperlymapped.bam Sample__"$d".ICETn43716385_R1_unmapped_R2_mapped.bam Sample__"$d".ICETn43716385_R1_mapped_R2_unmapped.bam 

	echo "For Sample "$d" sorting proper and improper reads BAM files ... STEP5/STEP10"
	/storage/apps/samtools-0.1.18/samtools sort -n Sample__"$d".ICETn43716385_R1_R2_properlymapped.bam Sample__"$d".ICETn43716385_R1_R2_properlymapped.sorted
	/storage/apps/samtools-0.1.18/samtools sort -n Sample__"$d".ICETn43716385_R1_R2_improperlymapped.bam Sample__"$d".ICETn43716385_R1_R2_improperlymapped.sorted

	echo "For Sample "$d" extracting proper and improper reads BAM files ... STEP6/STEP10"
	bamToFastq -i Sample__"$d".ICETn43716385_R1_R2_properlymapped.sorted.bam -fq Sample__"$d".ICETn43716385_mapped.1.fastq -fq2 Sample__"$d".ICETn43716385_mapped.2.fastq 
	bamToFastq -i Sample__"$d".ICETn43716385_R1_R2_improperlymapped.bam -fq Sample__"$d".ICETn43716385_unmapped.1.fastq -fq2 Sample__"$d".ICETn43716385_unmapped.2.fastq 

	echo "For Sample "$d" combining unmapped reads fastq files ... STEP7/STEP10"
	cat Sample__"$d".ICETn43716385_unmapped.1.fastq Sample__"$d".ICETn43716385_unmapped.2.fastq >Sample__"$d".ICETn43716385_unmapped.fastq

	echo "For Sample "$d" repairing mapped reads ... STEP8/STEP10"
	repair.sh in=Sample__"$d".ICETn43716385_mapped.1.fastq in2=Sample__"$d".ICETn43716385_mapped.2.fastq out=Sample__"$d".ICETn43716385_mapped.1.fastq.gz out2=Sample__"$d".ICETn43716385_mapped.2.fastq.gz repair

	echo "For Sample "$d" spades assembly of mapped & unmapped reads ... STEP9/STEP10"
	time spades.py --pe1-1 Sample__"$d".ICETn43716385_mapped.1.fastq.gz --pe1-2 Sample__"$d".ICETn43716385_mapped.2.fastq.gz -s Sample__"$d".ICETn43716385_unmapped.fastq -o Sample__"$d"_spades --careful -t 48 >>Sample__"$d".log_spades

	echo "Stitching the denovo assembled contigs ... STEP10/STEP10"
	perl /storage/apps/src/Bacterial-Genomics-master/abacas.1.3.1.pl -r /storage/data/DATA4/analysis/27_Paeruginosa_183_samples_Shawn/16_Check_presence_of_ICETn43716385/ICETn43716385.fasta -q Sample__"$d"_spades/contigs.fasta -p nucmer -o Sample__"$d"_abacus

cd ..;

#break;

done
