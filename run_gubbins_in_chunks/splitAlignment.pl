#$input="test.fa";
#print "input file is $input\n"; 
use POSIX;
#system "cat test.fa | paste - - | awk 'BEGIN{OFS=FS=" "}{gsub(/.{4}/,"&|",$2)}1' >test2_pipes.fa";
#$size=4;
$filename="seqnew.oneline.fa";
#system "rm test2_pipes.fa_*"; 

open FH,"$filename";
#$chunkSize=500000;

while(<FH>)
{
	$header=$_;
	$seq=<FH>;
	@splitSeq=unpack("(A500000)*", $seq);						#print "$seq\n$#splitSeq\n";
	for($i=0;$i<=$#splitSeq;$i++)
		{
		open FH2,">>$filename\_$i";
		print FH2"$header";
		print FH2"$splitSeq[$i]\n";
		}
}
	


