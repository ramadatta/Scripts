
open FH,"br08901.keg";


open OUT,">Categorised_KEGG.out.txt";

print OUT"Process\tSub-Process\tPathway\tMapid\tQUERY_SEQUENCES_WIT_HIT\tTOTAL_GENES_IN_PATHWAY\tGENES_WITH_HIT\tENZYME_HIT\n";

while(<FH>)
{
	if($_=~/^A\<b\>(.+)\<\/b\>/) ##Heading
		{
			$main_heading=$1;
			print OUT"\n$main_heading\n";
		}
	elsif($_=~/^B\s+(.+)/)
		{
			$sub_heading=$1;
			print OUT"\t$sub_heading\n";
		}
	elsif($_=~/^C\s+map(\d{5})\s+(.+)/)
		{
		$mapid="map$1";
		$koid="ko$1";
		$pathway=$2;
	

		`wget http://rest.kegg.jp/link/ko/$mapid -O $mapid.txt`;
		$TOTAL_GENES_IN_PATHWAY=`wc -l < $mapid.txt`; ##TOTAL_GENES_IN_PATHWAY
		$TOTAL_GENES_IN_PATHWAY =~ s/^\s+|\s+$//g;
#		print "$mapid\t$pathway\t-$TOTAL_GENES_IN_PATHWAY-\n";


		$cmd_str1="fgrep -w -f <(cat $mapid.txt | cut -d \":\" -f3) query.ko | cut -f1 | sort -u | wc -l";
		$QUERY_SEQUENCES_WIT_HIT=qx(bash -c '$cmd_str1'); ## QUERY_SEQUENCES_WIT_HIT
		$QUERY_SEQUENCES_WIT_HIT=~ s/^\s+|\s+$//g;
		chomp($QUERY_SEQUENCES_WIT_HIT);
#		print "$mapid\t$pathway\t$TOTAL_GENES_IN_PATHWAY\t$QUERY_SEQUENCES_WIT_HIT\n";

		$cmd_str2="fgrep -w -f <(cat $mapid.txt | cut -d \":\" -f3) query.ko | cut -f2 | sort -u | wc -l";
		$GENES_WITH_HIT= qx(bash -c '$cmd_str2'); #GENES_WITH_HIT
		$GENES_WITH_HIT=~ s/^\s+|\s+$//g;
		chomp($GENES_WITH_HIT);
#		print "$mapid\t$pathway\t$TOTAL_GENES_IN_PATHWAY\t$QUERY_SEQUENCES_WIT_HIT\t$GENES_WITH_HIT\n";

		$cmd_str3="fgrep \"$koid\" collapsed.txt | grep -Po \"\\(\\d+\\)\" | grep -Po \"\\d+\"";
		$line_num=qx(bash -c '$cmd_str3');
		$line_num=~ s/^\s+|\s+$//g;
		chomp($line_num);
#		print "$mapid\t$pathway\t$TOTAL_GENES_IN_PATHWAY\t$QUERY_SEQUENCES_WIT_HIT\t$GENES_WITH_HIT\t$line_num\n";
		$A="A$line_num";
#		print "$A\n";
		$ENZYME_HIT=`grep -$A "$koid" collapsed.txt | grep -Po \"\\[EC:.+\\]\" | wc -l`; #ENZYME_HIT
		#$ENZYME_HIT=qx(bash -c '$cmd_str4');
		$ENZYME_HIT=~ s/^\s+|\s+$//g;
		chomp($ENZYME_HIT);
		print "\t\t$pathway\t$mapid\t$QUERY_SEQUENCES_WIT_HIT\t$TOTAL_GENES_IN_PATHWAY\t$GENES_WITH_HIT\t$ENZYME_HIT\n";
		print OUT"\t\t$pathway\t$mapid\t$QUERY_SEQUENCES_WIT_HIT\t$TOTAL_GENES_IN_PATHWAY\t$GENES_WITH_HIT\t$ENZYME_HIT\n";
		}
		else
		{
		next;
		}
}
`mkdir files`;
`mv map*.txt files`;
