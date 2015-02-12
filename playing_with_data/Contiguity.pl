#This script takes blastx/blastn results and checks how much contiguous the database protein is 

##Script Author: Prakki Sai Rama Sridatta
##Date: October 21, 2013
##Email: prakkisr@tll.org.sg // ramadatta.88@gmail.com


open FH,"Multi.196871_VS_NT26675.blatx.output";
#open FH,"sample.txt";
%Hash=();
while(<FH>)
{
chomp($_);
@rec=split(/\t/,$_);
if($rec[0] >= 65)
{
$match=$rec[0];
$mismatch=$rec[1];
$blocksize=($rec[0]+$rec[1]);
$protein=$rec[9];
$protein_length=$rec[10];
chomp($bs_percentage=($blocksize*100/$protein_length));
	
	if(!(exists($Hash{$protein})))
	{
	$Hash{$protein}="$bs_percentage";
	}
	elsif(exists($Hash{$protein}) && $bs_percentage>$Hash{$protein})
	{
	$Hash{$protein}="$bs_percentage";
	}
}
}

@thres=(50,60,70,80,90,95,99,100);
foreach $thr (@thres)
{
	open OUTFILE,">65AA_Multi.196871.ContiguityBS_GTeq$thr.txt";
	foreach $key (keys %Hash)
	{
		if($Hash{$key} >=$thr)
		{
		print OUTFILE"$key $Hash{$key}\n";
		}
	}	
}

