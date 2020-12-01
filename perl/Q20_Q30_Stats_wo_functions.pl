#!/home/prakki/anaconda3/bin/perl

# This script finds total bases in fastq file, counts bases with Q20,  counts bases with Q30, Average Read Length for fastq file

$fastq_file   = $ARGV[0];
#$genomeSize = $ARGV[1];

open FH,"$fastq_file";

while(<FH>)
{

  $header1=$_;
  
  $read=<FH>; 
  #chomp($read);	
  
  $header3=<FH>;
  
  $read_qual=<FH>; 
  #print "$read_qual\n";
  chomp($read_qual);

	

	$Total_Bases=$Total_Bases+length($read_qual);


	$Q30_count = () = $read_qual =~ m/[\?\@ABCDEFGHIJ]/g;
	#print "$Q30_count\n";
	$Total_Q30_Bases=$Total_Q30_Bases+$Q30_count;
	#print "---->$Total_Q30_Bases\n";

	$Q20_count = () = $read_qual =~ m/[56789\:\;\<\=\>\?\@ABCDEFGHIJ]/g;
	$Total_Q20_Bases=$Total_Q20_Bases+$Q20_count;

$lines=$lines+4;

}

#print "Total Lines:$lines\n";
$Total_Reads=$lines/4;

$Mean_ReadLen=$Total_Bases/$Total_Reads;
=a
print "Total Reads      : $Total_Reads\n";
print "Total Base Count : $Total_Bases\n";
print "Total Q20 Bases  : $Total_Q20_Bases\n";
print "Total Q30 Bases  : $Total_Q30_Bases\n";
print "Mean Read Length : $Mean_readLen\n";
=cut

open OUT,">>Q30_Q20_readstats.txt";
#print OUT"fastq_file\tTotal_Reads\tTotal_Bases\tTotal_Q20_Bases\tTotal_Q30_Bases\tMean_ReadLen\n";
print OUT"$fastq_file\t$Total_Reads\t$Total_Bases\t$Total_Q20_Bases\t$Total_Q30_Bases\t$Mean_ReadLen\n";
close(OUT);
close(FH);

