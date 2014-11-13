#Author: Prakki Sai Rama Sridatta
##Plotting Bins, Counts (number of sliding windows), Proportion
# Should be placed in the same folder where knowGC-contentrun1.sh is run.
# 

$filename="$ARGV[0]";
$min="$ARGV[1]";
$max="$ARGV[2]";
$int="$ARGV[3]";

	for($i=$min;$i<=($max+0.01);$i+=$int)
	{
	#print "$i\n";
	push(@Intervals,$i);
	}

#print "Intervals to be used for Binning: @Intervals\n";
#print "$#Intervals\n";
$TotalNumber=`grep -c "." $filename`;
print "BINS\tCOUNTS\tProportion\n";
for($k=$min;$k<=($#Intervals-1);$k++)
{
	$knext=$k+1;
	$cnt=0;
		$lowerBound=$Intervals[$k];	
		$upperBound=$Intervals[$knext];
		#print "Lower Bound:$lowerBound,$upperBound\n";
	open FH,"$filename";
	while(<FH>)
	{
		$num=$_;
		if(($num>$lowerBound) && ($num<=$upperBound)) 
		{ 
			#print "$counting\n";
			$cnt++;
		}
		
	}
	close(FH);
	$proportion=($cnt/$TotalNumber);
	print "$Intervals[$k]-$Intervals[$knext]\t";
	printf("%f\t", $cnt);
	printf("%f\n",$proportion);
	$proportion=0;
}
		
