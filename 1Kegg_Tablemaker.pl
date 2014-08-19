###########################################################################################################################
##Descrption: This script makes a table taking collapsed file, query.ko files as the inputs after Kegg-KAAS run	and generates a table	
##Dependencies: The folder running this script should also have the sister files GeneCount_Pathway_Table_KeggTM_2.txt,General_KeggTM_1.txt				
##Script Author: Prakki Sai Rama Sridatta
##Date: December 13,2013
##Email: prakkisr@tll.org.sg // ramadatta.88@gmail.com
## Usage: #perl 1Kegg_Tablemaker.pl <collapsed.txt> <query.ko>
###########################################################################################################################

#############################################
#collapsed.txt Input should look like this  #
#############################################
=a+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Pathway Search Result
Sort by the number of hits          

Hide all objects
ko01100 Metabolic pathways (10)

ko:K00411 UQCRFS1; ubiquinol-cytochrome c reductase iron-sulfur subunit [EC:1.10.2.2]
ko:K00600 glyA; glycine hydroxymethyltransferase [EC:2.1.2.1]
ko:K00803 E2.5.1.26; alkyldihydroxyacetonephosphate synthase [EC:2.5.1.26]
ko:K00901 E2.7.1.107; diacylglycerol kinase (ATP dependent) [EC:2.7.1.107]
ko:K01132 GALNS; N-acetylgalactosamine-6-sulfatase [EC:3.1.6.4]
ko:K01597 MVD; diphosphomevalonate decarboxylase [EC:4.1.1.33]
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#########################################
#query.ko should look like this  	#
#########################################
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
SBRGG_02149	K07750
SBRGG_02263	K04515
SBRGG_02901	K14078
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
=cut

#use strict;
#use warnings;

my $collapsed = $ARGV[0];
my $Kid = $ARGV[1];

print "~~deleting previous directories if present!!\n";

	`rm Final_*.txt`;
	`rm -R inter_files`;
	`rm inter_files/*Kegg_pathway`;
	`mkdir inter_files`;
	`mv Process_Transcript_Enzyme_Kegg_pathway.txt inter_files`;

print "~~deleting previous directories is done!!\n";

open FH, '<', "$collapsed";
#open FH,"$collapsed";
chomp(@collapsed_array=<FH>);

	for($i=0;$i<=$#collapsed_array;$i++)
	{
				
				
				if($collapsed_array[$i] !~ /^ko.+/)
				{
				next;
				}
	
				elsif($collapsed_array[$i]=~m/(ko\d{5})\s+(.+)\s+\(\d+\)/)
				{
				$2 =~ s/^\s+//; #remove leading spaces
				$2 =~ s/\s+$//; #remove trailing spaces				
				$fileName=$2;
				$fileName =~ s/[\s\t\/\(\)]/_/g;
				$fileName =~ s/[']//g;
				@b='';
				$str='';
				print "Going thru the $fileName pathway\n";
				}

				elsif($collapsed_array[$i]=~m/ko\:(K\d{5}) .+/)
				{
				#print "$1";
				push(@b,$1);
				}
				 #my @b = split //;
				#print "first element:$b[0]\n";
				#shift(@b);
				#print "first element:$b[0]\n";
		$str=join("|",@b);
		$str =~ s/^.//s;

		`egrep "$str" $Kid >$fileName\_Kegg_pathway`;
	}

print "Finished writing Transcripts and Ko:id's to the concerned pathway, STEP1 OUT OF STEP6\n";

	%EnzymeKO={};
	

	foreach $tmp (@collapsed_array)
	{
	
		if($tmp=~/ko\:(K\d{5}).+\[(EC\:.+)\]/) #ko:K02677 CPKC; classical protein kinase C [EC:2.7.11.13]
		{
		#print "$tmp exists\n";
		my $key=$1;
		#print "$key\n";
		$key =~ s/^\s+//; 
		$key =~ s/\s+$//; 
		$EnzymeKO{$key}="$2";
		}
	}

	close(FH);
	chomp($PWD=`pwd`);

print "Finished parsing collapsed file, assigned enzyme to each Ko:ID, STEP2 OUT OF STEP6\n";

	open OUT,">>$PWD/Process_Transcript_Enzyme_Kegg_pathway.txt";
	print OUT "Process\tNumber_of_TranscriptS\tGenesFoundinPathway\tNumber_of_Enzymes\n";
	chomp(@files=`ls *_Kegg_pathway`);
		
		foreach $fil (@files)
		{
			$fil =~ s/^\s+//; 
			$fil =~ s/\s+$//; 
			#print "$fil\n";
			$numTranscripts=`wc -l "$fil" | cut -d " " -f 1`; 
			chomp($numTranscripts);
			$numGenesBlasted=`cat "$fil" | cut -d "	" -f 2 | sort -u | wc -l`; 
			chomp($numGenesBlasted);
			%Proc_hash=();


				open HF,"$fil";
				chomp(@b=<HF>);
				 @b;

				foreach $tmp2 (@b)
				{
					@splitted=split("\t",$tmp2);
					$splitted[1] =~ s/^\s+//; 
					$splitted[1] =~ s/\s+$//; 
	
					if(exists($EnzymeKO{$splitted[1]}))
					{
					$Proc_hash{$splitted[1]}="$EnzymeKO{$splitted[1]}";
					}	
				}

			$numEnzymes=keys(%Proc_hash);
			print OUT "$fil\t$numTranscripts\t$numGenesBlasted\t$numEnzymes\n";
		}

	close(OUT);

print "Finished generating Process_Transcript_Enzyme_Kegg_pathway.txt file1, STEP3 OUT OF STEP6\n";

		open GenCount,"$PWD/GeneCount_Pathway_Table_KeggTM_2.txt";
		%GeneCountHash=();

			while(<GenCount>)
			{
			#print "$_\n";
				if($_=~/^\s+(\d+)\s+(map\d+)\_(\w+)\.txt$/)
				{
				$MAPID_NO_TRAN="$2\t$1";
				$GeneCountHash{$3}="$MAPID_NO_TRAN";
				}
			}

print "Finished parsing GeneCount file, STEP4 OUT OF STEP6\n";

		open Pro_Tra_Enz,"Process_Transcript_Enzyme_Kegg_pathway.txt";
		open Pathway_TGC_GC_EN,">>Final_Specific_Table.txt";
		print Pathway_TGC_GC_EN "PATHWAY\tQUERY_SEQUENCES_WIT_HIT\tMAPID\tTOTAL_GENES_IN_PATHWAY\tGENES_WITH_HIT\tENZYME_HIT\n";

			while(<Pro_Tra_Enz>)
			{
					#print "$_";
			if($_=~/(\w+)_Kegg\_pathway\t(\d+)\t(\d+)\t(\d+)/) #African_trypanosomiasis_Kegg_pathway	7	6	2
				{
					#print "$_";
					if(exists ($GeneCountHash{$1}))
					{
					print Pathway_TGC_GC_EN "$1\t$2\t$GeneCountHash{$1}\t$3\t$4\n";
					}
				}
			}

			close(Pathway_TGC_GC_EN);

print "Finished generating Final_Specific_Table.txt file, STEP5 OUT OF STEP6\n";

		open FILE1,">>Final_General_Table.txt";
		open GEN,"$PWD/General_KeggTM_1.txt";
		chomp(@gen=<GEN>);

		print FILE1 "PATHWAY\tQUERY_SEQUENCES_WIT_HIT\tMAPID\tTOTAL_GENES_IN_PATHWAY\tGENES_WITH_HIT\tENZYME_HIT\n";
		
		foreach $tmp3 (@gen)
		{
			
			if($tmp3=~m /^(\d+\.?\d*)\s(.+)/) #1. Metabolism #1.0 Global map	
			{
			print FILE1"\n$tmp3\n";##General Metabolism
			}
			else
			{
			$tmp3 =~ s/^\s+//; 
			$tmp3 =~ s/\s+$//; 
			##Specific metabolism
			$tmp3 =~ s/[\s\t\/\(\)]/_/g;
			$tmp3 =~ s/[']//g;
			#print "$tmp3\n";
			$specific_met=`grep -w "$tmp3" Final_Specific_Table.txt`;
				if($specific_met=~/^\s*$/)
				{
				next;
				}
				else
				{
				print FILE1 "$specific_met";
				}
			}
		}
	
	`mv *_Kegg_pathway* $PWD/inter_files`;

print "Finished generating Final_General_Table.txt file, STEP6 OUT OF STEP6\n";


close(FILE1);
close(GEN);


