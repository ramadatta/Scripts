############################################################################################################################################
#this file checks out the two files file1 fastq, the file2 with fasta headers and returns the sequences which does not have header ID in file 2
#############################################################################################################################################
##Script Author: Prakki Sai Rama Sridatta
##Date: June 17, 2013
##Email: prakkisr@tll.org.sg // ramadatta.88@gmail.com

#use strict;
open FH,"sample_Seabass_fastq";
chomp(@ori_file=<FH>);
#print "@ori_file";
 %ori_hash=();
for($i=0;$i<=$#ori_file;$i=($i+4))
{
#print "$ori_file[$i]\n";
push (@{$ori_hash{$ori_file[$i]}},"$ori_file[$i+1]","$ori_file[$i+2]","$ori_file[$i+3]");
}
#print "$ori_file[2]\n";
open HF,"sample_unique_names.txt";
chomp(@censor_hits=<HF>);
 %hash2=();
foreach $tmp (@censor_hits)
{
$hash2{$tmp}='0';
}
open OUT,">NonBacterial_reads.fastq";
foreach $k2 (keys %ori_hash)
{
#print "$k2\n";
if($k2 =~/(\@HWI\-ST615\:\d+\:D10B5ACXX\:\d\:\d+\:\d+\:\d+) (2)(\:.\:.\:\w+)/)
{
$k1="$1 1$3";
#print "$k1\n$k2\n";
if(exists($hash2{$k1}) && exists($hash2{$k2}))
	{
	next;	
	}
else
	{
	#print "$k1\n$hash2{$k1}\n$k2\n$hash2{$k2}\n";
	print OUT "$k1\n";
	foreach (@{$ori_hash{$k1}})
	{
	print OUT "$_\r\n";
	} 
	print OUT "$k2\n";
	foreach (@{$ori_hash{$k2}})
	{
	print OUT "$_\r\n";
	}
	}
	}
}
close(FH);
close(HF);
