############################################################################################################################################
# Abacas takes one sequence in sepearate file and does an alignment. but this can be run multifasta file
#############################################################################################################################################

##Script Author: Prakki Sai Rama Sridatta
##Date: Unknown date, 2013
##Email: prakkisr@tll.org.sg // ramadatta.88@gmail.com


open FH,"OL_Oreochromis_niloticus0.69.cdna.all.fa"; # Oneline multi fasta file
%Seq=();
while(<FH>)
{
	$line1=$_;
#print "$line1";
	$line2=<FH>;
#print "$line2";
open TEMP,">TEMP_FILE.fasta";
	print TEMP "$line1"."$line2";
close(TEMP);

`perl abacas.1.3.1.pl -r TEMP_FILE.fasta -q ~/Tilapia_decontaminated/Merged_Tilapia_contigs/OL_Merged_Tilapia5_6.fasta -p nucmer`;

`cat OL_Merged_Tilapia5_6.fasta_TEMP_FILE.fasta.fasta >>Abacas.output.scaffold`;

`rm OL_Merged_Tilapia5_6.fasta_TEMP_FILE.fasta.*`; 
}
