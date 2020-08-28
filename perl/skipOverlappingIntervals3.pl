#!/home/prakki/anaconda3/bin/perl

use Number::Range;


#This command was run to generate blast results and sorted the output accordingly. The output of below line is passed as an input  for this perlm script


#for d in $(ls *.fasta);  do blastn -db /home/prakki/sw/CPgeneProfiler/CPGP_17092020/CPgeneProfiler/testData/db/NCBI_BARRGD_CPG.DB -query <(sed 's/ /_/g' $d)  -outfmt '6 qseqid sseqid pident nident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen'  | awk '{print $0,($5*100)/$NF}'  |awk '$3>99.5 && $NF>99.5' | awk '{print $0"\t"$3*$NF}' | sort -grk17,17 >"$d"_vs_NCBI_BARRGD_CPG_DB_BlastResults_min99.5_pident_cov.txt & done



$blastResults_file=$ARGV[0];
#print "$blastResults_file\n";

(my $temp_merged_intervals = $blastResults_file) =~ s/\.txt//g;
#print "$blastResults_file\n$temp_merged_intervals\n";

system('./bedtools.sh', $ARGV[0]);

open FH,"$temp_merged_intervals\_bedtools_merge.txt";
my @merged_intervals=<FH>;

open HF,"$blastResults_file";


while(<HF>)
	{
	chomp($_);
	my @line1=split("\t",$_);
	my $intA1=$line1[7];
	my $intA2=$line1[8];
	#print "$intA1,$intA2\n";
	#calling subroutine

		foreach $tmp (@merged_intervals)
		{
			chomp($tmp);
			#print "$tmp\n";
			my @mergedline1=split("\t",$tmp);
			my $mergedintA1=$mergedline1[1];
			my $mergedintA2=$mergedline1[2];

			my $Combined_int="$mergedintA1\t$mergedintA2";

			#print "$intA1,$intA2,$mergedintA1,$mergedintA2\n";
		
			my $overlay=cmpInt($intA1,$intA2,$mergedintA1,$mergedintA2);
			#print"overlap is $overlay\n";
			if($overlay!=0)
			{
				print "$_\n";
				@merged_intervals = grep {!/$Combined_int/} @merged_intervals;
				last;
			}
			else
			{
			#print "$_\n";
			next;
			}

		}
	}

#######################This portion compares the overlap between two intervals############## 
sub cmpInt
{

# get total number of arguments passed.
   my ($intA1,$intA2,$mergedintA1,$mergedintA2) = @_;

#print "This is inside the subroutine: $intA1,$intA2,$mergedintA1,$mergedintA2\t";

my $seq1 = Number::Range->new($intA1..$intA2); #Start and stop for gene1
my $seq2 = Number::Range->new($mergedintA1..$mergedintA2); #Start and stop for gene2
 
my $overlap = 0;
my $total = $seq1->size + $seq2->size;
 
foreach my $int ($seq2->range) {
    if ( $seq1->inrange($int) ) {
	  $overlap++;
    }
    else {
	next;
    }
}
 if($overlap==0)
	{
	#print "$intA1,$intA2,$mergedintA1,$mergedintA2\n";
	return $overlap;
	}
	else
	{	
#	print "Out of a total size of $total, $overlap bases overlap\n";	
	return $overlap;
	}
}	

