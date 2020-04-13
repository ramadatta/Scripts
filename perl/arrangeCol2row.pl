# This perl script takes a single column and converts that to multiple rows
# Default: it converts the a single column with first 48 elements into 48 columns and then 49th element will start in the second row
 again
`grep -v '[a-zA-Z]' 2-tier_prelim_output.txt >2-tier_prelim_output_corrected_filt.txt`;

open FH,"2-tier_prelim_output_corrected_filt.txt";

$i=1;
while(<FH>)
{
	chomp($_);
	if($i<=48)
	{
	print "$_,";
	$i++;
	}
	else
	{
	$i=1;
	print "\n";
	print "$_,";
	$i++;
	}
	
}
print "\n";
