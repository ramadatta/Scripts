## Author: Prakki Sai Rama Sridatta
##Date: OCtober 05, 2014

=a
Utility: This script take the parsed xml file obtained from the interproscan, and output a two files with protein, family name, family ID.

  1) Before running this script, you have to run the interproscan like this
 ./interproscan.sh -goterms -i test_NT.fasta -iprlookup -f xml -o test_NT.ipr.xml 

  2) Then do a simple egrep to make life easy as in the following command.
  egrep "\<xref id\=|type\=\"FAMILY\"" test_NT.ipr.xml | uniq >modified_test_NT.ipr.xml

And that it!! Use the modified xml as the input here to generate the tables.:-)
=cut

open FH,"modified_test_NT.ipr.xml"; ## Change the name

open OUT1,">proteins_with_ipr_id.txt";
open OUT2,">proteins_with_family_name.txt";

print OUT1"Protein\tFamily_Interpro_ID";
print OUT2"Protein\tFamily_Name";

while(<FH>)
{
	$_ =~ s/^\s+//; #remove leading spaces
	$_ =~ s/\s+$//; #remove trailing spaces
	#print "$_\n";
	if($_=~/\<xref id="(.+)"\/\>/)
	{
	$my_protein_id=$1;
	print OUT1"\n$my_protein_id";
	print OUT2"\n$my_protein_id";
	}
	elsif($_=~/\<entry ac="(.+)" desc="(.+)" name=.+\>/)
	{
	$ipr_id=$1;
	$family_name=$2;
	print OUT1"\t$ipr_id";
	print OUT2"\t$family_name";
	}	
}

close(FH);
close(OUT1);
close(OUT2);
