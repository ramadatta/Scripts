#Biostar forum: https://www.biostars.org/p/385839/#386131


open FH,"alignment_file.fasta";

@GapstoN=`cat *.vcf | grep -v "#" | sort -nk2,2 | sed "/^\$/d" | awk '{print \$2}'`;

%ConvrtGap2N=();
for($i=0;$i<=$#GapstoN; $i++)
{
	chomp($GapstoN[$i]);
	#print "$i: -$GapstoN[$i]-\n";
	$ConvrtGap2N{$GapstoN[$i]}="N";
}

foreach $k (sort keys %ConvrtGap2N) 
{
 #  print "$k => $ConvrtGap2N{$k}\n";
}


open OUT,">Gaps_converted_to_N.fasta";

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


open REF,"ref.fasta";

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


#open OUT,">Gaps_converted_to_N_and_RefBase.fasta";

while(<CON>)
{
$Header=$_;
$Seq=<CON>;
chomp($Seq);
#print "$Header$Seq";
print "$Header";

@Sequence=split(//,$Seq);
#print $Sequence[1];

for($j=0;$j<=$#Sequence;$j++)
	{

		if($Sequence[$j] =~ m/\-/) 
		{
		print "$RefHash{$j}";
		}
		else
		{
		print "$Sequence[$j]";
		}
	}
	print "\n";
}


