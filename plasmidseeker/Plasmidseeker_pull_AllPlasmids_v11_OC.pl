## This Plasmidseeker_pull_AllPlasmids_v9.pl script is latest plasmidseeker script. To run just type: time perl Plasmidseeker_pull_AllPlasmids_v9.pl 

## Prior to running the script, the working directory should contain a seperate folder for each sample with fastq files (fastq.gz or fastq) files, fasta file, contigSeq file (cp gene containing contig)

## The number of directories represent number of samples

$Final_Directory="/storage/data/DATA4/analysis/7iNDM_PlasmidSeeker/Species/iNDM_PlasmidSeeker_dated26092019/Plasmidseeker_with_Overlapping_coefficient";

#$Final_Directory=`echo $PWD`;

@list_of_dirs=`ls -d */`; ##List all the directories which contains 2 fastq files and 1 fasta file and 1 cpgene containing contig file

$Plasmidseeker_DB="/storage/apps/PlasmidSeeker/db14_iNDM_dedup_v1";

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
	

	if ( grep -f, glob '*.gz' ) ##cases with gz files
 	{

		`cat *.gz >$tmp.unzipped.fastq.gz`; ##combine gz files
		`gunzip $tmp.unzipped.fastq.gz`;  ##unzip them
		$fasta=`ls *.fasta`;
		chomp($fasta);
		print "the input file name is $tmp.unzipped.fastq and fasta file is $fasta\n";
	#	print "plasmidseeker output is here: $tmp\_plasmidseeker_results.txt\n";
$cmd="time perl /storage/apps/PlasmidSeeker/plasmidseeker.pl -d $Plasmidseeker_DB -i $tmp.unzipped.fastq -b $fasta -o $tmp\_plasmidseeker_results.txt -t 48 -f 80"; 
		print "plasmidseeker output will be found here: $tmp\_plasmidseeker_results.txt\n";
		print "running this command:\n$cmd\n";
		system($cmd); ##running plasmid seeker

		print "Plasmidseeker is done!\n";

##once plasmid seeker is done
open FH,"$tmp\_plasmidseeker_results.txt";

@plasmidseeker_file=<FH>;
#print @plasmidseeker_file;
##extract the "comma" seperated accession list from the results

foreach $a (@plasmidseeker_file)
{
		chomp($a);
		print "This is \$a: $a\n";

		if($a=~/.*\/.*/)
		{
		($plasmid_file_number) = $a =~ m/\/storage\/apps\/PlasmidSeeker\/db14_iNDM_dedup_v1\/(plasmid_.*.fna)_20.list/g;
			print "this is plasmid number ---$plasmid_file_number\n";

			$grepp=qx(grep "$plasmid_file_number" /storage/apps/PlasmidSeeker/db14_iNDM_dedup_v1/names.txt);
			if ($grepp =~ m/\|(.*)\|/)
			{
				$accn=$1;
				#print "$accn\n";
				$concat="$concat".","."$accn";
				print "$concat\n";
			}
		}
		else { next; }
}
 close(FH);

			$concat =~ s/^,//g;
			open NCBIID,">NCBI_ID.list";
			print NCBIID"Final list of IDs to grab from NCBI is : $concat\n";
			close(NCBIID);

			print "Final list of IDs to grab from NCBI is : $concat\n";
			`blastdbcmd -db /storage/apps/PlasmidSeeker/db14_iNDM_dedup_v1_BLAST_DB/iNDMv4db_deduplicated_circ_plasmids.fasta.DB -entry $concat -outfmt %f >$tmp\_PlasmidCluster_TophitsSeqs.fasta`;
			system( q@ cat *_PlasmidCluster_TophitsSeqs.fasta | awk '/^>/ {if(N>0) printf("\n"); printf("%s\n",$0);++N;next;} { printf("%s",$0);} END {printf("\n");}' | split -l 2 - blastdbcmd_seq @); ## Break the single fasta to multiple small fasta files

			`sed -i -e 's/ /_/g' $tmp\_PlasmidCluster_TophitsSeqs.fasta -e 's/;.*//g'`; ##long header names will cause segmentation fault
			`rm tmp_*`;

$CP_containing_Contig_file=`ls *.contigSeq`;
chomp($CP_containing_Contig_file);
	
$qlen=`fgrep -v '>' *contigSeq | tr -d "\n" | wc -c`; #CPGene Contig Length
chomp($qlen);
print "$qlen";

@Putative_Plasmids=`ls blastdbcmd_seq*`;
#print @Putative_Plasmids;
`rm Overlapping_Coeff.txt`;
`rm *_clustering_commands.sh`;

open PARALLEL,">>$tmp\_clustering_commands.sh"; # Understand cannot run the overlap coefficient script in parallel
foreach $putative (@Putative_Plasmids)
{
chomp($putative);
$putative_len=`fgrep -v '>' $putative | wc -c`;
chomp($putative_len);
#print "------> $putative####$putative_len\n";

	if($qlen<=$putative_len)
	{
	print "$qlen<=$putative_len\n";
	#system("perl /storage/apps/PlasmidSeeker/clustering_script.pl $CP_containing_Contig_file $putative >>Overlapping_Coeff.txt");
	print PARALLEL"perl /storage/apps/PlasmidSeeker/clustering_script.pl $CP_containing_Contig_file $putative >>Overlapping_Coeff.txt\n";
	}
	else
	{
		next;
	}
}

close(PARALLEL);

print "Checking Overlap Coefficient between Plasmids using GNU-Parallel\n";
$parallel_cmds=`ls *_clustering_commands.sh`;
chomp($parallel_cmds);
system("time parallel -j 48 < $parallel_cmds");

`sed 's/ /_/g' *_plasmidseeker_results.txt >tmp_ps_results.txt`;
system( q@for d in $(cat Overlapping_Coeff.txt | awk '{print $3}' | sed 's/gbk://g' | sed 's/[A-Z]*_*[A-Z]*\([0-9]\{6,8\}\.[0-9]\{1,\}\_\)//g'); do grep -m1 "$d" Overlapping_Coeff.txt; grep -m1 "$d" tmp_ps_results.txt; echo ""; done | sed -e '/^$/d' -e 's/%//g' | paste - - | awk '{print $1,$2,$3,$5,$6,$7,$4}' | sort -nrk7,7 -nrk6,6 -nrk5,5  >CPContig_Plasmid_KCov_OCoef.txt @);

system( q@for d in $(cat Overlapping_Coeff.txt | awk '{print $3}' | sed 's/gbk://g' | sed 's/[A-Z]*_*[A-Z]*\([0-9]\{6,8\}\.[0-9]\{1,\}\_\)//g'); do grep -m1 "$d" Overlapping_Coeff.txt; grep -m1 "$d" tmp_ps_results.txt; echo ""; done | sed -e '/^$/d' -e 's/%//g' | paste - - | awk '{print $1,$2,$3,$5,$6,$7,$4}' | sort -nrk7,7 -nrk6,6 -nrk5,5 | head -1 >Tophit_CPContig_Plasmid_KCov_OCoef.txt @);
				close(PLASMID_BLAST);
				close(FINAL_PLASMID);
				close(FINAL_PLASMID2);
$concat="";

	}
	elsif( grep -f, glob '*.fastq' ) ##cases without gz files, everything from above is same except that here files are already unzipped
	{

		`cat *.fastq >$tmp.unzipped.fastq`;
		$fasta=`ls *.fasta`;
		chomp($fasta);
		print "the input file name is $tmp.unzipped.fastq and fasta file is $fasta\n";

$cmd="time perl /storage/apps/PlasmidSeeker/plasmidseeker.pl -d $Plasmidseeker_DB -i $tmp.unzipped.fastq -b $fasta -o $tmp\_plasmidseeker_results.txt -t 48 -f 80";
print "running this command:\n$cmd\n";

		print "plasmidseeker output is here: $tmp\_plasmidseeker_results.txt\n";

system($cmd);

		print "Plasmidseeker is done!\n";

open FH2,"$tmp\_plasmidseeker_results.txt";

@plasmidseeker_file=<FH2>;
#print @plasmidseeker_file;
foreach $b (@plasmidseeker_file)
{
		chomp($b);
		print "This is \$b: $b\n";

		if($b=~/.*\/.*/)
		{
		($plasmid_file_number) = $b =~ m/\/storage\/apps\/PlasmidSeeker\/db14_iNDM_dedup_v1\/(plasmid_.*.fna)_20.list/g;
			print "this is plasmid number ---$plasmid_file_number\n";

			$grepp=qx(grep "$plasmid_file_number" /storage/apps/PlasmidSeeker/db14_iNDM_dedup_v1/names.txt);
			if ($grepp =~ m/\|(.*)\|/)
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
			open NCBIID,">NCBI_ID.list";
			print NCBIID"Final list of IDs to grab from NCBI is : $concat\n";
			close(NCBIID);

			print "Final list of IDs to grab from NCBI is : $concat\n";
			`blastdbcmd -db /storage/apps/PlasmidSeeker/db14_iNDM_dedup_v1_BLAST_DB/iNDMv4db_deduplicated_circ_plasmids.fasta.DB -entry $concat -outfmt %f >$tmp\_PlasmidCluster_TophitsSeqs.fasta`;
			system( q@ cat *_PlasmidCluster_TophitsSeqs.fasta | awk '/^>/ {if(N>0) printf("\n"); printf("%s\n",$0);++N;next;} { printf("%s",$0);} END {printf("\n");}' | split -l 2 - blastdbcmd_seq @); ## Break the single fasta to multiple small fasta files

			`sed -i -e 's/ /_/g' $tmp\_PlasmidCluster_TophitsSeqs.fasta -e 's/;.*//g'`; ##long header names will cause segmentation fault
			`rm tmp_*`;

$CP_containing_Contig_file=`ls *.contigSeq`;
chomp($CP_containing_Contig_file);
	
$qlen=`fgrep -v '>' *contigSeq | tr -d "\n" | wc -c`; #CPGene Contig Length
chomp($qlen);
print "$qlen";

@Putative_Plasmids=`ls blastdbcmd_seq*`;
#print @Putative_Plasmids;
`rm Overlapping_Coeff.txt`;
`rm *_clustering_commands.sh`;

open PARALLEL,">>$tmp\_clustering_commands.sh"; # Running overlap coefficient in parallel
foreach $putative (@Putative_Plasmids)
{
chomp($putative);
$putative_len=`fgrep -v '>' $putative | wc -c`;
chomp($putative_len);
#print "------> $putative####$putative_len\n";

	if($qlen<=$putative_len)
	{
	print "$qlen<=$putative_len\n";
	#system("perl /storage/apps/PlasmidSeeker/clustering_script.pl $CP_containing_Contig_file $putative >>Overlapping_Coeff.txt");
	print PARALLEL"perl /storage/apps/PlasmidSeeker/clustering_script.pl $CP_containing_Contig_file $putative >>Overlapping_Coeff.txt\n";
	}
	else
	{
		next;
	}
}

close(PARALLEL);
print "Checking Overlap Coefficient between Plasmids using GNU-Parallel\n";
$parallel_cmds=`ls *_clustering_commands.sh`;
chomp($parallel_cmds);
system("time parallel -j 48 < $parallel_cmds");

`sed 's/ /_/g' *_plasmidseeker_results.txt >tmp_ps_results.txt`;
system( q@for d in $(cat Overlapping_Coeff.txt | awk '{print $3}' | sed 's/gbk://g' | sed 's/[A-Z]*_*[A-Z]*\([0-9]\{6,8\}\.[0-9]\{1,\}\_\)//g'); do grep -m1 "$d" Overlapping_Coeff.txt; grep -m1 "$d" tmp_ps_results.txt; echo ""; done | sed -e '/^$/d' -e 's/%//g' | paste - - | awk '{print $1,$2,$3,$5,$6,$7,$4}' | sort -nrk7,7 -nrk6,6 -nrk5,5  >CPContig_Plasmid_KCov_OCoef.txt @);

system( q@for d in $(cat Overlapping_Coeff.txt | awk '{print $3}' | sed 's/gbk://g' | sed 's/[A-Z]*_*[A-Z]*\([0-9]\{6,8\}\.[0-9]\{1,\}\_\)//g'); do grep -m1 "$d" Overlapping_Coeff.txt; grep -m1 "$d" tmp_ps_results.txt; echo ""; done | sed -e '/^$/d' -e 's/%//g' | paste - - | awk '{print $1,$2,$3,$5,$6,$7,$4}' | sort -nrk7,7 -nrk6,6 -nrk5,5 | head -1 >Tophit_CPContig_Plasmid_KCov_OCoef.txt @);

				close(PLASMID_BLAST);
				close(FINAL_PLASMID);
				close(FINAL_PLASMID2);
$concat="";


chdir "$Final_Directory";


		$var2=`pwd`;
		print "came back to $var2";



}
}
