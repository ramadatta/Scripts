
$src = $ARGV[0];

if($src=~/(.*)\.fastq/)
{
	$basename=$1;
	print "$basename\n";
}
else
{
print "Name should end with fastq\n";
}
#print "$src\n";	

open FH,"$src";

	open READ1,">$basename.Read1.fastq";
	open READ2,">$basename.Read2.fastq";

while(<FH>)
{
	#print "$_";
	$line1=$_;
	if($line1=~/\@ESB3\:.+\/1/)
	{
	$line2=<FH>;
	$line3=<FH>;
	$line4=<FH>;
	print READ1 "$line1$line2$line3$line4";
	}
	elsif($line1=~/\@ESB3\:.+\/2/)
	{
	$line2=<FH>;
	$line3=<FH>;
	$line4=<FH>;
	print READ2 "$line1$line2$line3$line4";
	}
}
close(FH);
close(READ1);
close(READ2);
