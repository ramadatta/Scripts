#This script takes fasta file and prints only header or only sequence or both if it finds the duplicate sequences.

##Script Author: Prakki Sai Rama Sridatta
##Date: June 17, 2013
##Email: prakkisr@tll.org.sg // ramadatta.88@gmail.com


open FH,"OL_Seabass_YG_Silok_Ttome_271703_good_267783_manualSelect_267781_replacedctrlM.fsa"; #Oneline.fasta
@fasta=<FH>;
%Hash=();
for($i=0;$i<=$#fasta;$i++)
{
$j=$i+1;
if(!(exists($Hash{$fasta[$j]})))
{
$Hash{$fasta[$j]}="$fasta[$i]";
#print "$fasta[$i] new header\n";
#print "$fasta[$j] sequence does not exists\n";
}
else
{
#$k=$i+2;
print "$fasta[$i] sequence exists\n"; #To print only header 
#print "$fasta[$j]\n"; #Remove hash to print sequence along with the header
}
}


