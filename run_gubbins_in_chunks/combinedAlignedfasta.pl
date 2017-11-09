use POSIX;

@arr=`ls -1v *fastx`; ##chunk files in order
print @arr;

%Hash=();
foreach $tmp (@arr)
{
$filename="$tmp";
open FH,"$filename";

	while(<FH>)
	{
		$header=$_;
		$seq=<FH>;
		chomp($header);
		chomp($seq);

			if(!(exists($Hash{$header})))
			{
			$Hash{$header}="$seq";
			}
			else
			{
			$Hash{$header}="$Hash{$header}"."$seq"; ##concatenating all the smaller chunks into bigger file
			}

	}
}
close(FH);

open FH2,">postGubbins_seqnew_ecloacae.filtered_polymorphic_sites.fasta";
foreach $k (sort keys %Hash)
	{
	print FH2"$k\n$Hash{$k}\n";
	}
	
close(FH2);

