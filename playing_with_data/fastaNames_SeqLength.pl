#This script takes RefSeq fasta and print the length of the sequence with header

##Script Author: Prakki Sai Rama Sridatta
##Date: Sepetember 02, 2013
##Email: prakkisr@tll.org.sg // ramadatta.88@gmail.com



open FH,"No_DUP_NT_ZF.unique.aa.fasta"; ##Input fasta file
chomp(@New=<FH>);
for($i=0;$i<=$#New;$i++)
{
$j=$i+1;
if($New[$i]=~/(\>gi\|.+\|ref\|.+\|)\s*(.+)\s{1,}(\[(Oreochromis niloticus|Danio rerio)\])$/)
{
$len=length($New[$j]);
print "$1\t$2\t$3\t\t$len\n";
}
}

close(FH);
