#!/bin/perl

		$GenPept_filename=$ARGV[0];
		#print "$GenPept_filename\t";
		#@NameSplit=split(/\./,$GenPept_filename);
		#print "$NameSplit[0]\n";

	`egrep 'LOCUS|gene=' $GenPept_filename >$GenPept_filename\.processed\.txt`;

	$parsedFile="$GenPept_filename\.processed\.txt";
	open FH,"$parsedFile";
	#open OUT,">$NameSplit[0]\_RefSeq_longestProt_headers_from_GenPeptFile.txt";
	@array=<FH>;
	for($i=0;$i<=$#array;$i++)
	{
	#print "$array[$i]\n";
	if($array[$i]=~/^LOCUS\s+(.\w+)\s+(\d+)\s*aa\s*.+\s*.+/)
		{
		$j=$i+1;
		$Accession=$1;
		$Length=$2;
			#print "$Accession,$Length\n";
		if($array[$j]=~/\s*\/gene\="(.+)"\s*/)
		{
		$Gene=$1;
		print "$Accession\t$Gene\t$Length\n";
		}
		else
		{
		next;
		}
		}
	}

=a
$var=`fgrep -A 1 -f <(cut -d "	" -f 1 $NameSplit[0]\_RefSeq_longestProt_headers_from_GenPeptFile.txt) $NameSplit[0]\_RefSeq_oneline_NODUP.fasta`;

open OUT2,"> >$NameSplit[0]\_RefSeq_longestProt.fasta";
print "$var";
=cut
	close(FH);
	close(OUT);
#	close(OUT2);
