#This script takes headers of the sequences and extract the co-ordinates of the each contig from gff file,
#if the contig exists in gff files, then any of the co-ordinates are falling in the ranges that the contig header contains.
#for exampple, contigxxx_150_200 is checked whether contigxxx is present in gff file.
#if exists, then check there is cordinates which are present between 100-250. if present in that region then print those contig names.

#Use at your own risk!!!

##Script Author: Prakki Sai Rama Sridatta
##Date: December 15,2015
##Email: prakkisr@tll.org.sg // ramadatta.88@gmail.com

use Set::IntSpan;

open FH,"SB6_10000_header.txt";
print "ContigName_withCoordinates\tContigName\tStart_in_GFF_file\tEnd_in_GFF_file\tGeneName\tGeneDescription\n";
while(<FH>)
{
	$ILine=$_;
	$ILine =~ s/^\s+|\s+$//g;
	#print "$ILine--\n";
if($ILine=~/(.+)\_(\d+)\_(\d+)/)
	{
	$IContig=$1;
	$IStart=$2;
	$IStop=$3;
	#print "$IContig\t$IStart\t$IStop\n";
	$var=`LC_ALL=C fgrep "$IContig" all.augustus.both.gff3 | fgrep "gene"`;
	#print "$var";
	open OUT,">$IContig\_gene.gff3";
	print OUT"$var";
	close(OUT);
	
	$r1 = Set::IntSpan->new([ $IStart .. $IStop ]);	
	
	open TEMP,"$IContig\_gene.gff3";
	
	while(<TEMP>)
	{
	$Gffline=$_;
	#print "$Gffline";
	if($Gffline=~/(.+)\tAUGUSTUS\tgene\t(\d+)\t(\d+).+ID=(.+)\;/ && $IContig eq $1)
	{
	$ContigName=$1;
	$Start=$2;
	$Stop=$3;
	$gene=$4;
	#print "$ContigName\t$Start\t$Stop\t$gene\n";	
	$r2 = Set::IntSpan->new([ $Start .. $Stop ]);

 	$i = $r1->intersect($r2);

	if ( !$i->empty and ( $i->max - $i->min ) >= 50 ) # criteria
	{
	#chomp($ILine);   
	$Desc=`LC_ALL=C fgrep -w "$gene" seabass_genes.description.unique_withoutN.txt | cut -d "	" -f 2 | tr '\n' '\t'`;
	print "$ILine\t$ContigName\t$Start\t$Stop\t$gene\t$Desc\n";
	}
	
	}
	}
 }
close(TEMP);
}
close(FH);
