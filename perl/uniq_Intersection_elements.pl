##The script takes two lists and checks the common elements and print them as 3rd column, unique elements in the first list in the 4th column and unique elements in the second list in the 5 column

# Author: Prakki Sai Rama Sridatta
# Date: Oct 4, 2018

##_______________________SAMPLE_DATA______________________________
#file1	blaNDM-5,	blaNDM-5,
#file2	aac(3)-IId,armA,blaDHA-1,blaNDM-1,blaTEM-1B,mph(E),msr(E),sul1,	aac(3)-IId,armA,blaCMY-4,blaDHA-1,blaMAL-1,blaNDM-1,blaTEM-1B,mph(E),msr(E),sul1,
#file3	aac(3)-IId,armA,blaDHA-1,blaNDM-1,blaTEM-1B,mph(E),msr(E),sul1,	aac(3)-IId,armA,blaDHA-1,blaNDM-1,blaOXY-2-2,blaTEM-1B,mph(E),msr(E),sul1,

#/bin/perl
use Array::Utils qw(:all);  ## To install package: sudo cpan install Array::Utils

open FH,"data.txt";

while(<FH>)
{
chomp($_);
@arr=split(" ",$_); ##3 columns in the original file sepearted by space 

@str1=split(",",$arr[1]); ##want to compare 2nd element( a list seperated by comma) and 3nd element( a list seperated by comma)
@str2=split(",",$arr[2]);

# intersection
my @common = intersect(@str1, @str2);

	foreach $tmp (@common) ##reformatting so that the common elements are combined with comma
	{
	$comb_str="$comb_str,"."$tmp";
	}	
	print "$_\t$comb_str\t"; 
	$comb_str=""; ##Emptying the string otherwise each loop appends to previous variable

# get items from array @a that are not in array @b
my @uniq_str1 = array_minus( @str1, @str2 );
my @uniq_str2 = array_minus( @str2, @str1 );

	foreach $tmp1 (@uniq_str1) ##reformatting so that the common elements are combined with comma
	{
	$comb_str1="$comb_str1,"."$tmp1";
	}

	foreach $tmp2 (@uniq_str2) ##reformatting so that the common elements are combined with comma
	{
	$comb_str2="$comb_str2,"."$tmp2";
	}

print "$comb_str1\t$comb_str2\n";
$comb_str1=""; ##Emptying the string otherwise each loop appends to previous variable
$comb_str2=""; ##Emptying the string otherwise each loop appends to previous variable

}

