##this script finds the possible Full-length transcripts based on the blatp results
## the folder should have augustus.codinseq, augustus.aa sequence and the inout fasta file used for the augustus in oneline format
##Script Author: Prakki Sai Rama Sridatta
##Date: February 18, 2014
##Email: prakkisr@tll.org.sg // ramadatta.88@gmail.com

	$FASTA_FILE=`ls *.fasta`;
	chomp($FASTA_FILE);
	chomp($TotalInputSeq=`grep -c '>' $FASTA_FILE`);
@c=(10,20,30,40,50,60,70,80,90,95,99);
foreach $cv (@c)
{
$chunkh="Unnormalised.Covgteq$cv.ID.gteq50";
open FH1,"Unnormalised.126377.fasta_VS_RefSeq_NT_proteins_26675.blatp.out.txt";
open FL,">$chunkh.FL_similarity.txt";
#print FL"match\tQname\tQsize\tTname\tTsize\tCoverage_of_DBprotein\tIdentity\n";
while(<FH1>)
{
chomp($_);
if($_=~/^\d+/) 
{
@rec=split(/\t/,$_);
$match=$rec[0];
$mismatch=$rec[1];
$Qname=$rec[9];##reference protein name
$Qsize=$rec[10];
$Tname=$rec[13];
$Tsize=$rec[14];
	
	$Coverage=(($match+$mismatch)*100/$Qsize);
	$identity=($match*100/($match+$mismatch));
	if( $Coverage >= $cv && $identity >= 50) ## coverage(contigblocksize/proteinsize && Identity(match/contig)
	{
	print FL"$_\t$Coverage\t$identity\n";
	}
	else
	{
	next;
	}
}
}

print "....blatp verfied, creating gFile\n";
`cat $chunkh.FL_similarity.txt | cut -d "	" -f 14 | sort -u >gFile.$chunkh.txt`;
print "...verfying gFile, extracting FULL-LENGTH SEQUENCES\n";
@var=`grep ">" "$FASTA_FILE".augustusPrediction.codingseq`;
%gHash=();
foreach $tmp (@var)
{
	#print "$tmp\n";
if($tmp=~/\>(.+)\.(g\d+\.t\d+)/)
	{
	$2 =~ s/^\s+//; #remove leading spaces
	$2 =~ s/\s+$//; #remove trailing spaces
	$gHash{$2}="$1";
	}
}
print "gHash is completed step1 out of 3 steps\n";
open HF,"$FASTA_FILE";
%seqHash=();
while(<HF>)
{
	$Header=$_;
	@HeaderArray=split(/\s/,$Header);
	$Seq=<HF>;
	$HeaderArray[0] =~ s/^\s+//; #remove leading spaces
	$HeaderArray[0] =~ s/\s+$//; #remove trailing spaces
	#print "$HeaderArray[0]\n$Seq";
	$seqHash{$HeaderArray[0]}="$Seq";
}	
#print "$seqHash{'>R2_1_comp267722_c0_seq1'}";
print "seqHash is completed step2 out of 3 steps\n";

open FH,"gFile.$chunkh.txt";

#open FH,"samplegFile.txt";
open FL_OUT,">$FASTA_FILE.$chunkh.FLenSeq.fa";
while(<FH>)
{
	my $gid1=$_;

	$gid1 =~ s/^\s+//; #remove leading spaces
	$gid1 =~ s/\s+$//; #remove trailing spaces
	#print "$gid1\n";
	#print "$gHash{$_}\n";	
	$SeqID="\>$gHash{$gid1}"; #$_ is gid, $gHash{$_} is SeqID
	#print "$gHash{$gid1}\n";
	$SeqID =~ s/^\s+//; #remove leading spaces
	$SeqID =~ s/\s+$//; #remove trailing spaces			
	print FL_OUT"$SeqID\n$seqHash{$SeqID}";
}
	chomp($FLSNumber=`grep -c '>' $FASTA_FILE.$chunkh.FLenSeq.fa`);
print "Out of $TotalInputSeq input sequences $FLSNumber full-length ORF sequences Done!\n";
}
