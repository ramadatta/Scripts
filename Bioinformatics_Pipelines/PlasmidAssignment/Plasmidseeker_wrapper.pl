# Date: October 14, 2019

## Prior to running the script, the working directory should contain
##  1) a seperate folder for each sample with fastq files (fastq.gz or fastq) files, 
##  2) an assembly in fasta file format
##  3) a contigSeq file (a cp gene containing contig from the assembly with the filename extension ".contigSeq")
## The number of directories represent number of samples

## To run just type: time perl Plasmidseeker_wrapper.pl 

$Final_Directory="/storage/data/DATA4/analysis/5Glorijoy/2019/Plasmidseeker/Split_Samples_CPGenes/NDM"; #Change Location Here

#$Final_Directory=`echo $PWD`;

@list_of_dirs=`ls -d */`; ##List all the directories which contains 2 fastq files and 1 fasta file and 1 cpgene containing contig file

$Plasmidseeker_DB="/storage/apps/PlasmidSeeker/db4_cdc_NDM_only_v2_CPE_Transmission"; ##Change Location Here

# Looking in the directories

foreach $tmp (@list_of_dirs )
{

chomp($tmp);
$tmp =~ s/\///g;
	#print "$tmp\n"; 

chdir "$tmp";
	$var=`pwd`;
#	print $var;
$qlen="";

print "looking in the directory $tmp and the current path is $var\n";

if( grep -f, glob '*_cutadapt.fastq' ) ## cases without gz files, assuming all the fastq files have an extension "cutadapt.fastq" - Else Change
	{
	
	`cat *.fastq >$tmp.unzipped.fastq`; ## Combine both Read1 and Read2 to single unzipped fastq file
	$fasta=`ls *.fasta`;
	chomp($fasta);
	
	print "the input file name is $tmp.unzipped.fastq and fasta file is $fasta\n";

# Run Plasmidseeker

$cmd="time perl /storage/apps/PlasmidSeeker/plasmidseeker.pl -d $Plasmidseeker_DB -i $tmp.unzipped.fastq -b $fasta -o $tmp\_plasmidseeker_results.txt -t 48 -f 80";
print "running this command:\n$cmd\n";

		print "plasmidseeker output is here: $tmp\_plasmidseeker_results.txt\n";
		system($cmd);
		print "Plasmidseeker is done!\n";

# Processing Plasmidseeker Results

open FH2,"$tmp\_plasmidseeker_results.txt";

@plasmidseeker_file=<FH2>;
#print @plasmidseeker_file;
foreach $b (@plasmidseeker_file)
{
		chomp($b);
		print "This is \$b: $b\n";

		if($b=~/.*\/.*/)
		{
		($plasmid_file_number) = $b =~ m/\/storage\/apps\/PlasmidSeeker\/db4_cdc_NDM_only_v2_CPE_Transmission\/(plasmid_.*.fna)_20.list/g; ##Change Location Here
			print "this is plasmid number ---$plasmid_file_number\n";

			$grepp=qx(grep "$plasmid_file_number" /storage/apps/PlasmidSeeker/db4_cdc_NDM_only_v2_CPE_Transmission/names.txt); ##Change Location Here
			
			if ($grepp =~ m/\|(.*)\|/) ##Accession number -header Processing
			{
				$accn=$1;
				#print "$accn\n";
				$concat="$concat".","."$accn";
				print "$concat\n";
			}
		}
		else { next; }
}
	 close(FH2);

			$concat =~ s/^,//g;
			open NCBIID,">NCBI_ID.list"; ## Generate a list of NCBI IDs
			print NCBIID"Final list of IDs to grab from NCBI is : $concat\n";
			close(NCBIID);

			print "Final list of IDs to grab from NCBI is : $concat\n";

# So far, we generated a list of Plasmid Accessions that a sample can possibly contain
# Now taking those plasmids and matching against the CP gene containing contig using local blast 
# If you want to use online download of sequences then need to unhash curl command (in such case cannot assign local plasmids)

`blastdbcmd -db /storage/apps/PlasmidSeeker/db4_cdc_NDM_only_v2_CPE_Transmission_BLAST_DB/db4_cdc_NDM_only_v2_CPE_Transmission.DB -entry $concat -outfmt %f >$tmp\_PlasmidCluster_TophitsSeqs.fasta`;
# $curl = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=sequences&id="."$concat"."&rettype=fasta&retmode=text"; ##Download online NCBI sequence
# `curl "$curl" >$tmp\_PlasmidCluster_TophitsSeqs.fasta`;
`sed -i -e 's/ /_/g' $tmp\_PlasmidCluster_TophitsSeqs.fasta -e 's/;.*//g'`; ##long header names will cause segmentation fault
`rm tmp_*`;

$CP_containing_Contig_file=`ls *.contigSeq`;
chomp($CP_containing_Contig_file);

	`makeblastdb -in $tmp\_PlasmidCluster_TophitsSeqs.fasta -dbtype nucl -out $tmp\_PlasmidCluster_TophitsSeqs.fasta.DB  -logfile $tmp.log`; ##removed -parse_seqids
`blastn -db $tmp\_PlasmidCluster_TophitsSeqs.fasta.DB -query $CP_containing_Contig_file -outfmt '6 qseqid sseqid pident nident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen' -out $tmp\_cpContigs_vs_PlasmidseekerPlasmids_blastresults.txt`;
$qlen=`tail -1 $tmp\_cpContigs_vs_PlasmidseekerPlasmids_blastresults.txt | cut -f14 -d "\t"`;

##LOCAL BLAST DONE

system( q@awk 'BEGIN{OFS="\t"}{print $1"_vs_"$2, $8, $9}' *cpContigs_vs_PlasmidseekerPlasmids_blastresults.txt | sort -k1,1 -k2,2n | mergeBed | awk '{print $0 "\t" $3-$2+1}'| /storage/apps/bedtools2/bin/groupBy -g 1 -c 4 -o sum | awk 'sub("_vs_", "\t", $1)' | sort -k1,1 -k3,3nr | awk '{print $0"\t"$1}' | awk '{sub(/NODE.*_length_/,"",$4)}1' | awk '{sub(/_cov_.*/,"",$4)}1' | awk '{print $0"\t"$3/$4}' >Plasmid_list_for_QueryContigs_withAlignment_prcnt.txt @); ##gives all plasmids with query alignment percent

system( q@awk 'BEGIN{OFS="\t"}{print $1"_vs_"$2, $8, $9}' *cpContigs_vs_PlasmidseekerPlasmids_blastresults.txt | sort -k1,1 -k2,2n | mergeBed | awk '{print $0 "\t" $3-$2+1}'| /storage/apps/bedtools2/bin/groupBy -g 1 -c 4 -o sum | awk 'sub("_vs_", "\t", $1)' | sort -k1,1 -k3,3nr | awk '{print $0"\t"$1}' | awk '{sub(/NODE.*_length_/,"",$4)}1' | awk '{sub(/_cov_.*/,"",$4)}1' | awk '{print $0"\t"$3/$4}' | awk '$5 >= 0.8' | cut -f2,5 -d " " | tr '\n' '\t' >Plasmid_list_for_QueryContigs_withAlignmentGtEq80_prcnt.txt @); ##gives best hit plasmids with query alingment gteq 80% 

system( q@awk 'BEGIN{OFS="\t"}{print $1"_vs_"$2, $8, $9}' *cpContigs_vs_PlasmidseekerPlasmids_blastresults.txt | sort -k1,1 -k2,2n | mergeBed | awk '{print $0 "\t" $3-$2+1}'| /storage/apps/bedtools2/bin/groupBy -g 1 -c 4 -o sum | awk 'sub("_vs_", "\t", $1)' | sort -k1,1 -k3,3nr | awk '$1 != x {print $0} {x = $1}' >merged_Query_AlignedLengths_fromBLAST.txt @);

##Check if the query coverage of CP gene Contig is >=80%, if yes write to a file
				open PLASMID_BLAST,"merged_Query_AlignedLengths_fromBLAST.txt";
				open FINAL_PLASMID,">$tmp\_cpContigs_vs_PlasmidseekerPlasmids_blastresults_TopHit.txt";
				open FINAL_PLASMID2,">$tmp\_cpContigs_vs_PlasmidseekerPlasmids_blastresults_no_qcov_cutoff.txt";
				while(<PLASMID_BLAST>)
				{
					@arr=split(" ",$_);
					#print "@arr\n";
					$qcov=$arr[2]/$qlen;
					#print "$qcov\n";
					chomp($qlen);
					chomp(@arr);
					print FINAL_PLASMID2"$tmp\t@arr\t$arr[2]\t$qlen\t$qcov\n";
							if($qcov >= 0.8)
							{
							print FINAL_PLASMID"$tmp\t@arr\n";
							}
				}
				close(PLASMID_BLAST);
				close(FINAL_PLASMID);
				close(FINAL_PLASMID2);
$concat="";
	}

chdir "$Final_Directory";


		$var2=`pwd`;
		print "came back to $var2";
}
