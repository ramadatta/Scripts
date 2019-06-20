#!/usr/bin/bash

Directory=`pwd`
echo "Present working directory: $Directory"

Gubbins_Suffix="CCGroup10_ST131_65_Samples"

Reference=`echo "ENT256_Nanopore.fasta"` ##Must be in the directory
Ref_Suffix=`echo "$Reference" | sed 's/.fasta//g'`

SampleList="Samples2Process.list" ## Must be in the directory

GubbinsSLOTS="48" ##Must provide

#Changed the Reference to one-line fasta file
fasta_formatter -i $Reference -o "$Ref_Suffix".oneline.fasta -w 0

echo "The Reference from now on is: $Ref_Suffix.oneline.fasta"
echo "The Reference Suffix is: $Ref_Suffix"
	echo ""
: <<'END_COMMENT'
END_COMMENT
# Removing unwanted spaces
	sed -i 's/ /_/g' "$Ref_Suffix".oneline.fasta 
	sed -i 's/=/_/g' "$Ref_Suffix".oneline.fasta 
	sed -i 's/,/_/g' "$Ref_Suffix".oneline.fasta 
	echo "-------------------------------->STEP1/31: Removed unwanted spaces from "$Ref_Suffix".oneline.fasta"
	date
	echo ""

# Make BLAST Database for the Reference

	makeblastdb -in "$Ref_Suffix".fasta -dbtype nucl -out "$Ref_Suffix".BLAST.DB -parse_seqids
	date
	echo ""

# To mask the repeat regions do a self-BLAST
	
	blastn -db "$Ref_Suffix".BLAST.DB -query "$Ref_Suffix".oneline.fasta -outfmt '6 qseqid sseqid pident nident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen' -out "$Ref_Suffix"_selfblastresults.txt
	date
	echo ""

# Mask the repeat regions so that while mapping the reads does not map the masked regions

	repeat=`bedtools merge -i <(cat "$Ref_Suffix"_selfblastresults.txt | awk '{print $1"\t"$8-1"\t"$9}' | tail -n+2 | sort -nk2,2) | awk '{print $0,$3-$2}' | awk '{sum+=$NF} END {print sum}'`

	echo "-------------------------------->Note: Your Reference: "$Ref_Suffix".oneline.fasta have $repeat bases of repeats"
	echo ""

	echo "Masking the $repeat bases in your Reference: "$Ref_Suffix".oneline.fasta"
	bedtools merge -i <(cat "$Ref_Suffix"_selfblastresults.txt | awk '{print $1"\t"$8-1"\t"$9}' | tail -n+2 | sort -nk2,2) >"$Ref_Suffix".Repeats.txt
	head "$Ref_Suffix".Repeats.txt #Just for reference, if the bed file is formed
	echo ""

	bedtools maskfasta -fi "$Ref_Suffix".oneline.fasta -bed "$Ref_Suffix".Repeats.txt -fo "$Ref_Suffix"_hard_masked.fasta
	echo "-------------------------------->STEP2/31:Masking Reference Done!! Proceding to Genome Mapping"
	date
	echo ""

# STAMPY Mapping the samples reads to Reference genome - Preparing the index for the Reference

	/storage/apps/stampy-1.0.32/stampy.py -G "$Ref_Suffix"_hard_masked.DB "$Ref_Suffix"_hard_masked.fasta
 	/storage/apps/stampy-1.0.32/stampy.py -g "$Ref_Suffix"_hard_masked.DB -H "$Ref_Suffix"_hard_masked.DB
	echo ""
	echo "-------------------------------->STEP3/31: Created STAMPY index for the Masking Reference for "$Ref_Suffix"_hard_masked.fasta"
	date

	bwa index -p "$Ref_Suffix"_hard_masked_BWA.DB "$Ref_Suffix"_hard_masked.fasta
	echo ""
	echo "-------------------------------->STEP4/31: Created BWA index to speed-up STAMPY for the Masking Reference for "$Ref_Suffix"_hard_masked.fasta"
	date

# Reference Set Sequences

	mkdir Raw_Data
	for d in $(cat $SampleList); do echo $d; cp -R /storage/data/DATA4/analysis/2CPE_Tranmission_Paper/CPE_LocalTranmission_PlasmidSeeker/Reference_Set/$d Raw_Data/; done
	echo ""
	echo "-------------------------------->STEP5/31: Copied samples into the Raw Data folder"
	date	

## Mapping short reads on the Reference Genome - This will run in the background

	for d in $(ls -d Raw_Data/*/ | sed 's/\/$//g'); do echo $d; fq=`ls $d/*fastq* | paste - - | sed 's/\t/ /' `; subdir=`echo "$d" | cut -f2 -d "/"`; echo "$subdir"; time /storage/apps/stampy-1.0.32/stampy.py -g "$Ref_Suffix"_hard_masked.DB -h "$Ref_Suffix"_hard_masked.DB -f sam -o "$subdir"_mapped_"$Ref_Suffix"_stampy_bwa.sam --substitutionrate=0.001 --bwaoptions="-t 48 -q10 "$Ref_Suffix"_hard_masked_BWA.DB" -M $fq & done 
	echo ""
  	echo "-------------------------------->STEP6/31: Mapping is going on"
	date
	wait $(jobs -rp) ## This command will allow the job to finish and after all the jobs are completed, then moves on to next job
	echo "-------------------------------->STEP6/31: Mapping is done! Moving to next step to sorting the create and sort BAM files"
	date
	echo ""
# Create and Sort BAM from SAM files

	for d in $(ls *_bwa.sam | sed 's/.sam//g'); do echo $d; time /storage/apps/samtools-0.1.18/samtools view -bS "$d".sam | /storage/apps/samtools-0.1.18/samtools sort - "$d"_sorted & done 
	wait $(jobs -rp) ## This command will allow the job to finish and after all the jobs are completed, then moves on to next job
	echo "-------------------------------->STEP7/31: Sorting the BAM files is done!!"
	date
	echo ""



# High Quality SNP as mentioned in Stoesser ST131 Paper - Also ignore INDEL calling (takes time)

	for d in $(ls *_sorted.bam | sed 's/_mapped_.*_stampy_bwa_sorted.bam//g'); do echo "$d"; time /storage/apps/samtools-0.1.18/samtools mpileup -I -g -f "$Ref_Suffix"_hard_masked.fasta -E -M0 -Q25 -q30 -m2 -D -S "$d"_mapped_"$Ref_Suffix"_stampy_bwa_sorted.bam | /storage/apps/samtools-0.1.18/bcftools/bcftools view -Nvcg - > "$d"_HQ.vcf; done
	#wait $(jobs -rp) ## This command will allow the job to finish and after all the jobs are completed, then moves on to next job
	echo "-------------------------------->STEP8/31: High Quality VCF files are generated! Next is Low Quality VCF file generation"
	date
	echo ""

# Low Quality SNP as mentioned in Stoesser ST131 Paper - Also ignore INDEL calling (takes time)

	for d in $(ls *_sorted.bam | sed 's/_mapped_.*_stampy_bwa_sorted.bam//g'); do echo "$d"; time /storage/apps/samtools-0.1.18/samtools mpileup -I -g -f "$Ref_Suffix"_hard_masked.fasta -B -M0 -Q0 -q0 -m2 -D -S "$d"_mapped_"$Ref_Suffix"_stampy_bwa_sorted.bam | /storage/apps/samtools-0.1.18/bcftools/bcftools view -Nvcg - > "$d"_LQ.vcf ; done
	#wait $(jobs -rp) ## This command will allow the job to finish and after all the jobs are completed, then moves on to next job
	echo "-------------------------------->STEP9/31: Low Quality VCF files are generated! "
	date
	echo ""

# Ignore INDEL Regions from VCF and also ignore bases with "N" in the reference - Working!!!

	for d in $(ls *_HQ.vcf | sed 's/_HQ.vcf//g'); do echo $d; time /storage/apps/samtools-0.1.18/bcftools/bcftools view -INS "$d"_HQ.vcf >"$d"_HQ_SNP.vcf; done
	echo "-------------------------------->STEP10/31: INDELs are removed from HQ.vcf! "
	date
	echo ""

	for d in $(ls *_LQ.vcf | sed 's/_LQ.vcf//g'); do echo $d; time /storage/apps/samtools-0.1.18/bcftools/bcftools view -INS "$d"_LQ.vcf >"$d"_LQ_SNP.vcf; done
	echo "-------------------------------->STEP11/31: INDELs are removed from LQ.vcf! "
	date
	echo ""

# Parsing VCF for easy processing into a table using GATK - Working!!!

	for d in $(ls *_HQ_SNP.vcf | sed 's/_HQ_SNP.vcf//g'); do echo $d; time gatk VariantsToTable -V "$d"_HQ_SNP.vcf -F CHROM -F POS -F QUAL -F DP4 -F MQ -O "$d"_HQ_SNP_GATK.tabl; done
	echo "-------------------------------->STEP12/31: CHROM,POS,QUAL,DP4,MQ fields are parsed from HQ.vcf! "
	date
	echo ""

	for d in $(ls *_LQ_SNP.vcf | sed 's/_LQ_SNP.vcf//g'); do echo $d; time gatk VariantsToTable -V "$d"_LQ_SNP.vcf -F CHROM -F POS -F DP4 -O "$d"_LQ_SNP_GATK.tabl ; done
	echo "-------------------------------->STEP13/31: CHROM,POS,DP4 fields are parsed from LQ.vcf! "
	date
	echo ""

# From the High Quality SNP GATK table want to extract High Quality BASE and its position with "#" between. So, the output file contains Ref1#1,Ref1#10000 etc.. - Working!!!
	
	for d in $(ls *_HQ_SNP_GATK.tabl| sed 's/_HQ_SNP_GATK.tabl//g'); do awk '{print $1_"#"_$2}' "$d"_HQ_SNP_GATK.tabl | fgrep -v 'CHROM' | awk '{print $1}' >"$d"_HQ_BASE_POSITION.txt & done 
	wait $(jobs -rp)
	echo "-------------------------------->STEP14/31: HQ_BASE_POSITION is created! "
	date
	echo ""

# Combining GATK Tables -Failed!!!

	for d in $(ls *_LQ_SNP_GATK.tabl | sed 's/_LQ_SNP_GATK.tabl//g'); do echo $d; awk '{print $1_"#"_$2,$3}' "$d"_LQ_SNP_GATK.tabl | fgrep -v 'CHROM' >"$d"_LQ_SNP_GATK_ColsCombined.tabl & done
	wait $(jobs -rp)
	for d in $(ls *_HQ_SNP_GATK.tabl | sed 's/_HQ_SNP_GATK.tabl//g'); do echo $d; awk '{print $1_"#"_$2,$3,$4,$5}' "$d"_HQ_SNP_GATK.tabl | fgrep -v 'CHROM' >"$d"_HQ_SNP_GATK_ColsCombined.tabl& done
	wait $(jobs -rp)
	echo "-------------------------------->STEP15/31: Combining GATK tabl is done! "
	date
	echo ""

# Generating VCF Filter Files, This helps to run easily the perl script next step - generates "XXX_VCF2Filter.txt" for each sample

	for d in $(ls *_HQ_BASE_POSITION.txt); do echo $d; prefix=`echo $d | sed 's/_HQ_BASE_POSITION.txt//g'`; for f in $(cat "$prefix"_HQ_BASE_POSITION.txt);  do fgrep -m1 -w "$f" "$prefix"_HQ_SNP_GATK_ColsCombined.tabl | tr '\n' '\t'; fgrep -m1 -w "$f" "$prefix"_LQ_SNP_GATK_ColsCombined.tabl |  tr -d '\n'; echo ""; done >"$prefix"_VCF2Filter.txt & done 
	wait $(jobs -rp) 
	echo "-------------------------------->STEP16/31: Generating VCF Filter Files is done! "
	date
	echo ""

# Filtering SNP's according Stoesser's paper criteria (/*perl script does this*- check if this exists/)
	cp /storage/data/DATA4/analysis/2_CPE_Tranmission_SNP_pipeline/scripts/VCF_Filter_Stoesser.pl .
	for d in $(ls *_VCF2Filter.txt | sed 's/_VCF2Filter.txt//g'); do echo "$d"; head -27 "$d"_LQ_SNP.vcf > "$d"_High_Confidence_SNP.vcf; fgrep -w -f <(perl VCF_Filter_Stoesser.pl "$d"_VCF2Filter.txt | cut -f1 | sed 's/SNP Position://g' | sed 's/#/	/g') "$d"_HQ_SNP.vcf >>"$d"_High_Confidence_SNP.vcf & done 
	wait $(jobs -rp)
	echo "-------------------------------->STEP17/31: Filtering SNPs according to Stoesser's method is done! "
	date
	echo ""

# Tabix
 
	for d in $(ls *_High_Confidence_SNP.vcf); do bgzip $d; tabix -p vcf "$d".gz; done
	echo "-------------------------------->STEP18/31: Tabix done! "
	date
	echo ""

# Generate consensus for all the fasta reference sequences for all the samples. Then,
	for d in $(ls *_High_Confidence_SNP.vcf.gz | sed 's/_High_Confidence_SNP.vcf.gz//g'); do echo "$d"; cat "$Ref_Suffix"_hard_masked.fasta | bcftools consensus "$d"_High_Confidence_SNP.vcf.gz >"$d"_"$Ref_Suffix"_consensus.fasta; done
	echo "-------------------------------->STEP19/31: CONSENSUS sequences for all the samples generated! "
	date
	echo ""

###################---------------------------STOESSER'S METHOD FOR PADDING AND BEAST------------------------##################################

	mkdir StoesserN_Method

##########################################################	

cp /storage/data/DATA4/analysis/2_CPE_Tranmission_SNP_pipeline/scripts/replace_RepeatNs.pl StoesserN_Method/replace_RepeatNs.pl
cp /storage/data/DATA4/analysis/2_CPE_Tranmission_SNP_pipeline/scripts/generateInvariantSites.sh  StoesserN_Method/generateInvariantSites.sh 
cp /storage/data/DATA4/analysis/2_CPE_Tranmission_SNP_pipeline/scripts/AppendInvariantSites.pl StoesserN_Method/AppendInvariantSites.pl
cp /storage/data/DATA4/analysis/2_CPE_Tranmission_SNP_pipeline/scripts/BEAST_DatesHeader.pl StoesserN_Method/BEAST_DatesHeader.pl

#########################################################
	
	cd StoesserN_Method

# Copy the consensus sequences and all the sorted bam files of each sample to the StoesserN_Method directory
	
	ln -sf ../*_consensus.fasta .
	ln -sf ../*_sorted.bam .
	ln -sf ../"$Ref_Suffix".oneline.fasta .

# If there is zero coverage region, generate ZeroCov_interval.bed for each file, then merge all the intervals from all the samples. The intervals are converted to Ns

	for d in $(ls *_"$Ref_Suffix"_consensus.fasta | sed "s/_"$Ref_Suffix"_consensus.fasta//g"); do echo $d; bedtools genomecov -ibam "$d"_mapped_"$Ref_Suffix"_stampy_bwa_sorted.bam -bga | awk '$4==0' | cut -f1,2,3 -d "	"  >"$d"_ZeroCov_interval.bed & done
	wait $(jobs -rp)
	
	bedtools merge -i <(cat *bed | sort -nk2,2) >Bases2RefBase_allSamples_mergedInterval.bed

# All the zero-coverage columns are converted to Ns using bedtools mask fasta. Now both the repeats and zero-coverage bases are hard masked with Ns

	for d in $(ls *_"$Ref_Suffix"_consensus.fasta | sed "s/_"$Ref_Suffix"_consensus.fasta//g"); do echo $d; time bedtools maskfasta -fi "$d"_"$Ref_Suffix"_consensus.fasta -bed Bases2RefBase_allSamples_mergedInterval.bed -fo "$d"_repeatN_ZeroCovCol_N.fasta -mc N & done
	wait $(jobs -rp)
	echo "-------------------------------->STEP20/31: All the zero-coverage columns are converted to Ns using bedtools mask function. Now both the repeats and zero-coverage bases are hard masked with Ns! "
	date
	echo ""

# Formatting isolate's fasta files
	
	for d in $(ls *repeatN_ZeroCovCol_N.fasta | sed 's/.fasta//g');do echo "$d"; fasta_formatter -i $d.fasta -o $d.oneline.fasta -w 0; done
	echo "-------------------------------->STEP21/31: Formatted all the sample fasta to oneline"
	date
	echo ""

# Take XXX_repeatN_ZC_gap.fasta, convert N to reference base for each position. That's what Stoesser did, you need the perl script for this 
	
	for d in $(ls *repeatN_ZeroCovCol_N.oneline.fasta); do echo $d; time perl replace_RepeatNs.pl $d $Ref_Suffix.oneline.fasta; done
	echo "-------------------------------->STEP22/31: Converted N to reference base for each position! "
	date
	echo ""


# Convert the sequence headername according to file name

	for FILE in *_Ns_converted_to_RefBase.fasta; do awk '/^>/ {gsub(/.fa(sta)?$/,"",FILENAME);printf(">%s\n",FILENAME);next;} {print}' $FILE > changed_${FILE}; done
	echo "-------------------------------->STEP23/31: Convert the sequence headername according to file name! "
	date
	echo ""


# Combine all the fasta alignments into one file - Pre-GUBBINS alignment with reference
	
	sed -i 's/ /_/g' ../"$Ref_Suffix".oneline.fasta 
	sed -i 's/=/_/g' ../"$Ref_Suffix".oneline.fasta 
	sed -i 's/,/_/g' ../"$Ref_Suffix".oneline.fasta
	cat ../"$Ref_Suffix".oneline.fasta changed* >"$Gubbins_Suffix"_Stoesser_PreGubbins_withRef.fasta ##need to change
	echo "-------------------------------->STEP24/31: Pre_GUBBINS alignment file is ready! "
	date
	echo ""

# Gubbins - Recombination filtering 

	run_gubbins.py --prefix postGubbins_"$Gubbins_Suffix" --threads $GubbinsSLOTS "$Gubbins_Suffix"_Stoesser_PreGubbins_withRef.fasta --verbose
	echo "-------------------------------->STEP24/31: GUBBINS alignment file is ready! "
	date
	echo ""

# Mask the recombinant regions

	maskrc-svg.py --aln "$Gubbins_Suffix"_Stoesser_PreGubbins_withRef.fasta --out "$Gubbins_Suffix"_Stoesser_PreGubbins_withRef_Recom_masked.fasta --gubbins postGubbins_"$Gubbins_Suffix"
	echo "-------------------------------->STEP25/31: Masked Recombination Regions! "
	date
	echo ""

#--------(*:)*Preparing for the BEAST input---------(*:)*#

# Now to submit the padded alignment to BEAST, remove all the gap "?" cols from the "$Gubbins_Suffix"_Stoesser_PreGubbins_withRef_Recom_masked.fasta

	sed -i 's/?/-/g' "$Gubbins_Suffix"_Stoesser_PreGubbins_withRef_Recom_masked.fasta
	trimal -in "$Gubbins_Suffix"_Stoesser_PreGubbins_withRef_Recom_masked.fasta -out "$Gubbins_Suffix"_Stoesser_PreGubbins_withRef_Recom_masked_trimal.fasta -nogaps
	echo "-------------------------------->STEP26/31: Trimmed Recombination Regions "
	date
	echo ""

 
# Count ATGC in the Pre-Gubbins Reference and Post Gubbins Reference, add that many number of A's, T's, G's, C's into each of the sample file and feed to BEAST

	for i in {1..1}; do faidx -i nucleotide ../$Ref_Suffix.oneline.fasta | tail -n+2; faidx -i nucleotide "$Gubbins_Suffix"_Stoesser_PreGubbins_withRef_Recom_masked_trimal.fasta | head -2 | tail -n+2; done | paste - - | awk '{print "./generateInvariantSites.sh",$4-$12,$5-$13,$6-$14,$7-$15}' >Invariant_Sites_CountATGC.txt

	cmd=`for i in {1..1}; do faidx -i nucleotide ../$Ref_Suffix.oneline.fasta | tail -n+2; faidx -i nucleotide "$Gubbins_Suffix"_Stoesser_PreGubbins_withRef_Recom_masked_trimal.fasta | head -2 | tail -n+2; done | paste - - | awk '{print "./generateInvariantSites.sh",$4-$12,$5-$13,$6-$14,$7-$15}'`
	echo "-------------------------------->STEP27/31: Counting "
	date
	echo ""

# Append the above number of ATGC's for each of the sequence and provide to BEAST. 
	echo "testing-->$cmd"
	`$cmd >invariantSites.txt`
	echo "-------------------------------->STEP28/31: Generated Invariant Sites file!! "
	date
	echo ""

# Removing the reference from the fasta file to input to BEAST #ids2Remove has reference sequence ID

	grep  '>' "$Ref_Suffix".oneline.fasta | tr -d '>' | tr '=' '_' | tr -d ',' >ids2Remove.txt	
	awk 'BEGIN{while((getline<"ids2Remove.txt")>0)l[">"$1]=1}/^>/{f=!l[$1]}f' "$Gubbins_Suffix"_Stoesser_PreGubbins_withRef_Recom_masked_trimal.fasta >"$Gubbins_Suffix"_Stoesser_PreGubbins_withoutRef_Recom_masked_trimal.fasta
	echo "-------------------------------->STEP29/31: Removed Reference Sequence for BEAST ANALYSIS!! "
	date
	echo ""

# Oneline fasta format

	fasta_formatter -i "$Gubbins_Suffix"_Stoesser_PreGubbins_withoutRef_Recom_masked_trimal.fasta -o "$Gubbins_Suffix"_Stoesser_PreGubbins_withoutRef_Recom_masked_trimal.oneline.fasta -w 0

# Append the invariant sites (ARGUMENTS for perl script: ARG1 invariant site, ARG2 fasta to append invariant sites, ARG3 suffix for the output file)

	perl AppendInvariantSites.pl invariantSites.txt "$Gubbins_Suffix"_Stoesser_PreGubbins_withoutRef_Recom_masked_trimal.oneline.fasta "$Gubbins_Suffix"_Stoesser_PreGubbins_withoutRef_Recom_masked_trimal
	#/storage/data/software/standard-RAxML/standard-RAxML-master/fasta2relaxedPhylip.pl -f "$Gubbins_Suffix"_Stoesser_PreGubbins_withoutRef_Recom_masked_trimal_InvarSitesAppend.fasta -o "$Gubbins_Suffix"_Stoesser_PreGubbins_withoutRef_Recom_masked_trimal_InvarSitesAppend.phy
	sed -i 's/_Ns_converted_to_RefBase.*bp//g' "$Gubbins_Suffix"_Stoesser_PreGubbins_withoutRef_Recom_masked_trimal_InvarSitesAppend.fasta
	echo "-------------------------------->STEP30/31: Appended Invariant Sites for BEAST ANALYSIS!! "
	date
	echo ""

# Append BEAST dates 

	perl BEAST_DatesHeader.pl "$Gubbins_Suffix"_Stoesser_PreGubbins_withoutRef_Recom_masked_trimal_InvarSitesAppend.fasta "$Gubbins_Suffix"_Stoesser_PreGubbins_withoutRef_Recom_masked_trimal
	echo "-------------------------------->STEP31/31: Alignment for BEAST tool is generated!! Please Proceed with BEAuti/BEAST "
	date
	echo ""



# BEAST Command line


# time /storage/apps/beast/bin/beast -beagle -beagle_SSE EColi_Stoesser_CCgroup10_BEAST_withDates.xml
