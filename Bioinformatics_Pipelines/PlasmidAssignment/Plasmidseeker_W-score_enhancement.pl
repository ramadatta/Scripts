

##This script will check from Top_plasmid_W-score.txt and more stringent in assigning plasmids than simple W_score. 

# A plasmid is assigned only if:

#1) the top hit has kcov>95 and qcov > 0.95 
#2) if the criteria 1, does not satisfy then again check if there is any top hit has kcov>90 and qcov > 0.9
#3) if the criteria 2, does not satisfy then again check if there is any tophit with qcov > 0.9
#4) if the criteria 3, does not satisfy then again check if there is any tophit with qcov > 0.8 and kcov>90

open HF,"Top_plasmid_W-Score.txt";

#open HF,"test";
#@Wcore_plasmids=<HF>;
#print "@Wcore_plasmids";
$Assigned=0;

while(<HF>)
{
$line=$_;
#print "$line";

if($line=~/(NODE_.+)\s+(.+)\s+(\d+)\s+(\d+)\s+(.+)\s+(\d+)\s+(\d+)\s+(.+)\s+(.+)/) #NODE_95_length_3417_cov_21.6754 DU_DU000000.2_ENT1250_pNDMFII_1250SG 3240 3417 0.9482 70441 84665 83.20 5557108.42
	{
	#print "$line";

	$contigName=$1;
	$plasmidName=$2;
	$AlignmentLen=$3;
	$ContigLen=$4;
	$qcov=$5;
	$kmersFound=$6;
	$totalkmers=$7;
	$kcov=$8;
	$wscore=$9;

	#print "contigName: $contigName\tplasmidName:$plasmidName\tAlignmentLen:$AlignmentLen\tContigLen:$ContigLen\tqcov:$qcov\tkmersfound:$kmersFound\ttotalkmers:$totalkmers\tkcov:$kcov\twscore:$wscore\n";

	# calling function 
	$threshold1_status = threshold1($kcov,$qcov); 
	if($threshold1_status eq "Y") 
	{ 
		print "$line"; 
		$Assigned=1;
		last; 
	} 
	else 
	{
	next;
	}
}
}
#print "$Assigned ";
close(HF);

if($Assigned==0)
	{
	open HF,"test";
	while(<HF>)
	{
	$line=$_;
	#print "$line";

	if($line=~/(NODE_.+)\s+(.+)\s+(\d+)\s+(\d+)\s+(.+)\s+(\d+)\s+(\d+)\s+(.+)\s+(.+)/) #NODE_95_length_3417_cov_21.6754 DU_DU000000.2_ENT1250_pNDMFII_1250SG 3240 3417 0.9482 70441 84665 83.20 5557108.42
		{
		#print "$line";

		$contigName=$1;
		$plasmidName=$2;
		$AlignmentLen=$3;
		$ContigLen=$4;
		$qcov=$5;
		$kmersFound=$6;
		$totalkmers=$7;
		$kcov=$8;
		$wscore=$9;

	#print "contigName: $contigName\tplasmidName:$plasmidName\tAlignmentLen:$AlignmentLen\tContigLen:$ContigLen\tqcov:$qcov\tkmersfound:$kmersFound\ttotalkmers:$totalkmers\tkcov:$kcov\twscore:$wscore\n";

		# calling function 
		$threshold2_status = threshold2($kcov,$qcov); 
		if($threshold2_status eq "Y") 
		{ 
			print $line; 
			$Assigned=2;
			last; 
		} 
		else 
		{
		next;
		}
		}
	}
	}	
#print "$Assigned ";

close(HF);

if($Assigned==0)
	{
	open HF,"test";
	while(<HF>)
	{
	$line=$_;
	#print "$line";

	if($line=~/(NODE_.+)\s+(.+)\s+(\d+)\s+(\d+)\s+(.+)\s+(\d+)\s+(\d+)\s+(.+)\s+(.+)/) #NODE_95_length_3417_cov_21.6754 DU_DU000000.2_ENT1250_pNDMFII_1250SG 3240 3417 0.9482 70441 84665 83.20 5557108.42
		{
		#print "$line";

		$contigName=$1;
		$plasmidName=$2;
		$AlignmentLen=$3;
		$ContigLen=$4;
		$qcov=$5;
		$kmersFound=$6;
		$totalkmers=$7;
		$kcov=$8;
		$wscore=$9;

	#print "contigName: $contigName\tplasmidName:$plasmidName\tAlignmentLen:$AlignmentLen\tContigLen:$ContigLen\tqcov:$qcov\tkmersfound:$kmersFound\ttotalkmers:$totalkmers\tkcov:$kcov\twscore:$wscore\n";

		# calling function 
		$threshold3_status = threshold3($kcov,$qcov); 
		if($threshold3_status eq "Y") 
		{ 
			print $line; 
			$Assigned=3;
			last; 
		} 
		else 
		{
		next;
		}
	}
	}
	}
#print "$Assigned ";
close(HF);

if($Assigned==0)
	{
	open HF,"test";
	while(<HF>)
	{
	$line=$_;
	#print "$line";

	if($line=~/(NODE_.+)\s+(.+)\s+(\d+)\s+(\d+)\s+(.+)\s+(\d+)\s+(\d+)\s+(.+)\s+(.+)/) #NODE_95_length_3417_cov_21.6754 DU_DU000000.2_ENT1250_pNDMFII_1250SG 3240 3417 0.9482 70441 84665 83.20 5557108.42
		{
		#print "$line";

		$contigName=$1;
		$plasmidName=$2;
		$AlignmentLen=$3;
		$ContigLen=$4;
		$qcov=$5;
		$kmersFound=$6;
		$totalkmers=$7;
		$kcov=$8;
		$wscore=$9;

	#print "contigName: $contigName\tplasmidName:$plasmidName\tAlignmentLen:$AlignmentLen\tContigLen:$ContigLen\tqcov:$qcov\tkmersfound:$kmersFound\ttotalkmers:$totalkmers\tkcov:$kcov\twscore:$wscore\n";

		# calling function 
		$threshold4_status = threshold4($kcov,$qcov); 
		if($threshold4_status eq "Y") 
		{ 
			print $line; 
			$Assigned=4;
			last; 
		} 
		else 
		{
		next;
		}
	}
	}
	}
#print "$Assigned ";


# defining subroutine for kcov and qcov thresholds
sub threshold1  
{ 
    # passing argument     
	$subkcov = $_[0]; 
 	$subqcov = $_[1]; 
      
	if($subkcov>=95 && $subqcov>=0.95)
	{
		#print "$_";
		return ("Y");
		last;
	}
	else
	{
		next;
	}
} 
sub threshold2  
{ 
    # passing argument     
	$subkcov = $_[0]; 
 	$subqcov = $_[1]; 
      
	if($subkcov>=90 && $subqcov>=0.90)
	{
		#print "$_";
		return ("Y");
		last;
	}
	else
	{
		next;
	}
} 
sub threshold3  
{ 
    # passing argument     
	$subkcov = $_[0]; 
 	$subqcov = $_[1]; 
      
	if($subkcov>=80 && $subqcov>=0.90)
	{
		#print "$_";
		return ("Y");
		last;
	}
	else
	{
		next;
	}
} 
sub threshold4  
{ 
    # passing argument     
	$subkcov = $_[0]; 
 	$subqcov = $_[1]; 
      
	if($subkcov>=90 && $subqcov>=0.80)
	{
		#print "$_";
		return ("Y");
		last;
	}
	else
	{
		next;
	}
} 

close(HF);
