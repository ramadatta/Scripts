## This script add 10 files to folder A, then add the same 10 files in other folder + another 10 files to folder B

## folder A contains 10 files
## folder B contains : (folder A 10 files) + new 10 files = 20 files

use File::Copy;

`rm -rf random*`;

@array=`ls *OCoef_W-Score.txt | shuf`;

$j=0;
$k=9;
#print "$#array\n";

for($i=1;$i<=12;$i++)
{
	if($k>=$#array)
	{
	@slice = @array[$j .. $#array];
	print "---------$j .. $#array----------\n";
	#print "@slice\n";
	mkdir random_114;
	`cp *OCoef_W-Score.txt random_114`;
	}
	else
	{
	@slice = @array[$j .. $k];
	print "---------$j .. $k----------\n";
	#print "@slice\n";
	$n=$k+1;
	print "Creating random_$n\n";
	mkdir "random_$n";
	foreach $tmp (@slice)
	{
	chomp($tmp);
	#print "This is : $tmp\n";
	copy("$tmp","random_$n");
	}
		$k=$k+10;
	}
}
	
