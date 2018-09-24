## This v7 script is latest plasmidseeker script. To run just type: time perl PlasmidAssignment_Pipeline_v5.pl 

## Prior to running the script, the working directory should contain a seperate folder for each sample with fastq files (fastq.gz or fastq) files, fasta file, contigSeq file (cp gene containing contig)

## The number of directories represent number of samples

$Final_Directory="/storage/data/DATA4/analysis/2CPE_Tranmission_Paper/CPE_LocalTranmission_PlasmidSeeker/1251_PS_using_db6";

@list_of_dirs=`ls -d */`; ##List all the directories which contains 2 fastq files and 1 fasta file and 1 cpgene containing contig file

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

$cmd="time perl /storage/apps/PlasmidSeeker/plasmidseeker.pl -d /storage/apps/PlasmidSeeker/db6_cdc_wx_pipeline_plasmidSeq -i $tmp.unzipped.fastq -b $fasta -o $tmp\_plasmidseeker_results.txt -t 48 -f 80"; 

		print "running this command:\n$cmd\n";
		system($cmd); ##running plasmid seeker

		print "Plasmidseeker is done!\n";

##once plasmid seeker is done
open FH,"$tmp\_plasmidseeker_results.txt";

@plasmidseeker_file=<FH>;
#print @plasmidseeker_file;
##extract the "comma" seperated accession list from the results
for($i=0;$i<=$#plasmidseeker_file;$i++)
	{
		if ($plasmidseeker_file[$i] =~ m/PLASMID CLUSTER/) 
		{
			#print "$plasmidseeker_file[$i]\n";
        	    	$a = $plasmidseeker_file[$i+1];
#	  	        push (@array, $a);
			#print "$a\n";
			($plasmid_file_number) = $a =~ m/\/storage\/apps\/PlasmidSeeker\/db6_cdc_wx_pipeline_plasmidSeq\/(plasmid_.*.fna)_20.list/g;
			#print "this is plasmid number $plasmid_file_number\n";
			#$q_plasmid_file_number=quotemeta($plasmid_file_number);
			$grepp=qx(grep "$plasmid_file_number" /storage/apps/PlasmidSeeker/db6_cdc_wx_pipeline_plasmidSeq/names.txt);
			#system($grepp);
			#print $grepp;
			if ($grepp =~ m/\|(.*)\|/)
			{
				$accn=$1;
				#print "$accn\n";
				$concat="$concat".","."$accn";
				print "$concat\n";
			}
		}
		elsif($plasmidseeker_file[$i] =~ m/HIGH P-VALUE PLASMIDS/) 
		{
			print "HIGH P_VALUE MATCHED";
				$j=$i+1;		
			for($k=$j;$k<=$#plasmidseeker_file;$k++)
				{
					print "inside HPvalue ==> $plasmidseeker_file[$k]\n";
					$hpvalue = $plasmidseeker_file[$k];
					($plasmid_file_number_hp) = $hpvalue =~ m/\/storage\/apps\/PlasmidSeeker\/db6_cdc_wx_pipeline_plasmidSeq\/(plasmid_.*.fna)_20.list/g;
					#	print "plasmidnumber is this: $plasmid_file_number_hp\t";
					$grepp_hp=qx(grep "$plasmid_file_number_hp" /storage/apps/PlasmidSeeker/db6_cdc_wx_pipeline_plasmidSeq/names.txt);
						print "grepp_hp is this: $grepp_hp\t";
						if ($grepp_hp =~ m/\|(.*)\|/)
						{
							$accn=$1;
							#print "$accn\n";
							$concat="$concat".","."$accn";
							print "$concat\n";
						}					

			$plasmid_file_number_hp="";
				}
	
		}
	}
 close(FH);

			$concat =~ s/^,//g;
			open NCBIID,">NCBI_ID.list";
			print NCBIID"Final list of IDs to grab from NCBI is : $concat\n";
			close(NCBIID);
			print "Final list of IDs to grab from NCBI is : $concat\n";
			$curl = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=sequences&id="."$concat"."&rettype=fasta&retmode=text"; ##use eutils to download the accession from NCBI	
			`curl "$curl" >$tmp\_PlasmidCluster_TophitsSeqs.fasta`;
			`sed -i -e 's/ /_/g' ENT1437_S8_PlasmidCluster_TophitsSeqs.fasta -e 's/;.*//g'` ##long header names will cause segmentation fault

`rm tmp_*`;

##Now blast the cpgene containing contig against the downloaded NCBI plasmid list using blast

$CP_containing_Contig_file=`ls *.contigSeq`;
chomp($CP_containing_Contig_file);

##LOCAL BLAST
	`makeblastdb -in $tmp\_PlasmidCluster_TophitsSeqs.fasta -dbtype nucl -out $tmp\_PlasmidCluster_TophitsSeqs.fasta.DB -parse_seqids -logfile $tmp.log`;

	`blastn -db $tmp\_PlasmidCluster_TophitsSeqs.fasta.DB -query $CP_containing_Contig_file -outfmt '6 qseqid sseqid pident nident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen' -out $tmp\_cpContigs_vs_PlasmidseekerPlasmids_blastresults.txt`;

$qlen=`tail -1 $tmp\_cpContigs_vs_PlasmidseekerPlasmids_blastresults.txt | cut -f14 -d "\t"`;
print "$qlen\n";

##LOCAL BLAST DONE
system( q@awk 'BEGIN{OFS="\t"}{print $1"_vs_"$2, $8, $9}' *cpContigs_vs_PlasmidseekerPlasmids_blastresults.txt | sort -k1,1 -k2,2n | mergeBed | awk '{print $0 "\t" $3-$2+1}'| /storage/apps/bedtools2/bin/groupBy -g 1 -c 4 -o sum | awk 'sub("_vs_", "\t", $1)' | sort -k1,1 -k3,3nr | awk '$1 != x {print $0} {x = $1}' >merged_Query_AlignedLengths_fromBLAST.txt @);

##Check if the query coverage is >=80%, if yes write to a file
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
	elsif( grep -f, glob '*.fastq' ) ##cases without gz files, everything from above is same except that here files are already unzipped
	{

		`cat *.fastq >$tmp.unzipped.fastq`;
		$fasta=`ls *.fasta`;
		chomp($fasta);
		print "the input file name is $tmp.unzipped.fastq and fasta file is $fasta\n";

$cmd="time perl /storage/apps/PlasmidSeeker/plasmidseeker.pl -d /storage/apps/PlasmidSeeker/db6_cdc_wx_pipeline_plasmidSeq -i $tmp.unzipped.fastq -b $fasta -o $tmp\_plasmidseeker_results.txt -t 48 -f 80";
print "running this command:\n$cmd\n";
system($cmd);

		print "Plasmidseeker is done!\n";

open FH2,"$tmp\_plasmidseeker_results.txt";

@plasmidseeker_file=<FH2>;
#print @plasmidseeker_file;
for($i=0;$i<=$#plasmidseeker_file;$i++)
	{
		if ($plasmidseeker_file[$i] =~ m/PLASMID CLUSTER/) 
		{
			#print "$plasmidseeker_file[$i]\n";
        	    	$a = $plasmidseeker_file[$i+1];
#	  	        push (@array, $a);
			#print "$a\n";
			($plasmid_file_number) = $a =~ m/\/storage\/apps\/PlasmidSeeker\/db6_cdc_wx_pipeline_plasmidSeq\/(plasmid_.*.fna)_20.list/g;
			#print "this is plasmid number $plasmid_file_number\n";
			#$q_plasmid_file_number=quotemeta($plasmid_file_number);
			$grepp=qx(grep "$plasmid_file_number" /storage/apps/PlasmidSeeker/db6_cdc_wx_pipeline_plasmidSeq/names.txt);
			#system($grepp);
			#print $grepp;
			if ($grepp =~ m/\|(.*)\|/)
			{
				$accn=$1;
				#print "$accn\n";
				$concat="$concat".","."$accn";
				print "$concat\n";
			}	
		}
				elsif($plasmidseeker_file[$i] =~ m/HIGH P-VALUE PLASMIDS/) 
		{
			print "HIGH P_VALUE MATCHED";
				$j=$i+1;		
			for($k=$j;$k<=$#plasmidseeker_file;$k++)
				{
					print "inside HPvalue ==> $plasmidseeker_file[$k]\n";
					$hpvalue = $plasmidseeker_file[$k];
					($plasmid_file_number_hp) = $hpvalue =~ m/\/storage\/apps\/PlasmidSeeker\/db6_cdc_wx_pipeline_plasmidSeq\/(plasmid_.*.fna)_20.list/g;
					#	print "plasmidnumber is this: $plasmid_file_number_hp\t";
					$grepp_hp=qx(grep "$plasmid_file_number_hp" /storage/apps/PlasmidSeeker/db6_cdc_wx_pipeline_plasmidSeq/names.txt);
						print "grepp_hp is this: $grepp_hp\t";
						if ($grepp_hp =~ m/\|(.*)\|/)
						{
							$accn=$1;
							#print "$accn\n";
							$concat="$concat".","."$accn";
							print "$concat\n";
						}					

			$plasmid_file_number_hp="";
				}
	
		}



	}
	 close(FH2);

			$concat =~ s/^,//g;
			open NCBIID,">NCBI_ID.list";
			print NCBIID"Final list of IDs to grab from NCBI is : $concat\n";
			close(NCBIID);

			print "Final list of IDs to grab from NCBI is : $concat\n";
			$curl = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=sequences&id="."$concat"."&rettype=fasta&retmode=text";
			`curl "$curl" >$tmp\_PlasmidCluster_TophitsSeqs.fasta`;
			`sed -i 's/ /_/g' $tmp\_PlasmidCluster_TophitsSeqs.fasta`;
			`rm tmp_*`;
$CP_containing_Contig_file=`ls *.contigSeq`;
chomp($CP_containing_Contig_file);
	`makeblastdb -in $tmp\_PlasmidCluster_TophitsSeqs.fasta -dbtype nucl -out $tmp\_PlasmidCluster_TophitsSeqs.fasta.DB -parse_seqids -logfile $tmp.log`;
`blastn -db $tmp\_PlasmidCluster_TophitsSeqs.fasta.DB -query $CP_containing_Contig_file -outfmt '6 qseqid sseqid pident nident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen' -out $tmp\_cpContigs_vs_PlasmidseekerPlasmids_blastresults.txt`;
$qlen=`tail -1 $tmp\_cpContigs_vs_PlasmidseekerPlasmids_blastresults.txt | cut -f14 -d "\t"`;


##LOCAL BLAST DONE
system( q@awk 'BEGIN{OFS="\t"}{print $1"_vs_"$2, $8, $9}' *cpContigs_vs_PlasmidseekerPlasmids_blastresults.txt | sort -k1,1 -k2,2n | mergeBed | awk '{print $0 "\t" $3-$2+1}'| /storage/apps/bedtools2/bin/groupBy -g 1 -c 4 -o sum | awk 'sub("_vs_", "\t", $1)' | sort -k1,1 -k3,3nr | awk '$1 != x {print $0} {x = $1}' >merged_Query_AlignedLengths_fromBLAST.txt @);

##Check if the query coverage is >=80%, if yes write to a file
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


system( q@for d in $(ls *_cpContigs_vs_PlasmidseekerPlasmids_blastresults.txt | grep -v 'test'); do echo -n "$d       "; sampName=`echo "$d" |sed 's/_cpContigs_vs_PlasmidseekerPlasmids_blastresults.txt//g'`;  accn=`head $d | cut -f2 | head -1 | grep -Po ".*\.._" | sed 's/_$//g'`; echo -n "$accn      "; if [ -n "$accn" ]; then plasmid_num=`grep "$accn" /storage/apps/PlasmidSeeker/db6_cdc_wx_pipeline_plasmidSeq/names.txt | cut -f1`; echo -n "$plasmid_num    "; partd=`echo $d | cut -f1,2 -d "/"`; grep "$plasmid_num" *_plasmidseeker_results.txt; fi; echo -n " "; cat *_cpContigs_vs_PlasmidseekerPlasmids_blastresults_no_qcov_cutoff.txt; done | paste  - - | sed 's/ \+ /\t/g' | sed 's/ /_/g' | awk '{print $12,$2,$4,$5,$6,$9,$13,$14,$15,$16}' >Final_blast_kmer_cov.txt@);

`mv Final_blast_kmer_cov.txt $tmp\_Final_blast_kmer_cov.txt`;

chdir "$Final_Directory";


		$var2=`pwd`;
		print "came back to $var2";



}

