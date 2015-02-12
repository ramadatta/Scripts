#This script takes blastx/blastn results and print the top best hits

##Script Author: Prakki Sai Rama Sridatta
##Date: October 14, 2013
##Email: prakkisr@tll.org.sg // ramadatta.88@gmail.com

open FH,"Seabass_YG_Silok_Ttome_271703.blastx.txt"; ##input
%Hash=();
open OUT,">Seabass_YG_Silok_Ttome_271703.blastx.TopHits.txt"; ##output
while(<FH>)
{
	#print "$_\n";
	@ar=split("\t",$_);
	if(!exists($Hash{$ar[0]}))
	{
	$Hash{$ar[0]}="$ar[2]";
	print OUT"$_";
	}
	
}
close(FH);
close(OUT);

