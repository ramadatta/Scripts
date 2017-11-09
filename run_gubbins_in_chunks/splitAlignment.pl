#Author: Prakki Sai Rama Sridatat
#Date: 08/11/2017
##Script: Breaks the aligned fasta file into smaller chunks from position1 to position2 (1 to 100, 100 to 200,...etc). The default used chunk size to break is 500KB.
## syntax : perl splitAlignment.pl
use POSIX;
$filename="seqnew.oneline.fa"; ##Input Aligned fasta file (after alignment)

open FH,"$filename";

while(<FH>)
{
	$header=$_;
	$seq=<FH>;
	@splitSeq=unpack("(A500000)*", $seq); ##Breaks into 500 KB sequence length
	for($i=0;$i<=$#splitSeq;$i++)
		{
		open FH2,">>$filename\_$i";
		print FH2"$header";
		print FH2"$splitSeq[$i]\n";
		}
}
	


