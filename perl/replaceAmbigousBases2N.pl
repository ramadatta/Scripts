#Biostar forum: https://www.biostars.org/p/385839/#386131


open FH,"alignment_file.fasta"; ##single-line fasta file

##Take all the vcf files with SNP positions and replace them with N

@GapstoN=`cat *.vcf | grep -v "#" | sort -nk2,2 | sed "/^\$/d" | awk '{print \$2}' | uniq`; ## The SNP positions from all vcf are collected in this array 

##Storing all the vcf SNP position in a hash for later reference
%ConvrtGap2N=();
for($i=0;$i<=$#GapstoN; $i++)
{
	chomp($GapstoN[$i]);
	#print "$i: -$GapstoN[$i]-\n";
	$ConvrtGap2N{$GapstoN[$i]}="N";
}

#printing the hash
=a
foreach $k (sort keys %ConvrtGap2N) 
{
 #  print "$k => $ConvrtGap2N{$k}\n";
}
=cut

open OUT,">Gaps_converted_to_N.fasta";

## If each sequence a gap is found and also that position has a SNP, convert that gap to "N"

while(<FH>)
{
$Header=$_;
$Seq=<FH>;
chomp($Seq);
#print "$Header$Seq";
print OUT"$Header";

@Sequence=split(//,$Seq);
#print $Sequence[1];

for($j=0;$j<=$#Sequence;$j++)
	{
	$vcfPos=$j+1;	
#print "$j\t$vcfPos\t$Sequence[$j]\t$ConvrtGap2N{$j}\n";
		if($Sequence[$j] =~ m/\-/ && exists($ConvrtGap2N{$vcfPos}))
		{
		print OUT"$ConvrtGap2N{$vcfPos}";
		}
		else
		{
		print OUT"$Sequence[$j]";
		}
	}
	print OUT"\n";
}

close(FH);
close(OUT);

# Now, left with the other case if there is no SNP but a gap, replace with the reference base


open REF,"ref.fasta"; # store reference sequence in hash

%RefHash=();
while(<REF>)
{
$header=$_;
$seq=<REF>;
chomp($seq);
@seqArr=split("",$seq);
for($i=0;$i<=$#seqArr; $i++)
	{
	#print "$seqArr[$i]";
	$RefHash{$i}="$seqArr[$i]";
     #  print "$i\t$RefHash{$i}\n";

	}

}

open CON,"Gaps_converted_to_N.fasta";


open OUT2,">Gaps_converted_to_N_and_RefBase.fasta";

while(<CON>)
{
$Header=$_;
$Seq=<CON>;
chomp($Seq);
#print "$Header$Seq";
print OUT2"$Header";

@Sequence=split(//,$Seq);
#print $Sequence[1];

for($j=0;$j<=$#Sequence;$j++)
	{

		if($Sequence[$j] =~ m/\-/) 
		{
		print OUT2"$RefHash{$j}";
		}
		else
		{
		print OUT2"$Sequence[$j]";
		}
	}
	print OUT2"\n";
}

close(CON);
close(OUT2);
close(REF);

