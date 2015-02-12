open FH,"est2genome_intmedFile.txt";

while(<FH>)
{
	if($_=~/^>.+(txt|fasta)$/)
	{
	print "\n$_";
	}
	else
	{
	chomp($_);
	$_ =~ s/^\s+//; #remove leading spaces
	$_ =~ s/\s+$//;
	print "$_";
	}
	
}
