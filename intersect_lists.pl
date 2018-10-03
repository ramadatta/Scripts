#/bin/perl

##The script takes two lists and checks the common elements and print them as 3rd column

# Author: Prakki Sai Rama Sridatta
# Date: Oct 3, 2018

open FH,"data.txt";

while(<FH>)
{
chomp($_);
@arr=split(" ",$_); ##3 columns in the original file sepearted by space 

@str1=split(",",$arr[1]); ##want to compare 2nd element(a list seperated by comma) and 3nd element(a list seperated by comma)
@str2=split(",",$arr[2]);

my %counts;
++$counts{$_} for @str1; ##Collecting all the elements from str array and assign a number incrementally

foreach $key (keys %counts)
{
print "variable:$_,key:$key,value:$counts{$key}\n";
}

my @common = grep { --$counts{$_} >= 0 } @str2; ## until the values of all the elements are found to be greater than or equal to zero, the elements in the @str1 are checked in @str2, and common elements are collected in @common array

foreach $tmp (@common) ##reformatting so that the common elements are combined with comma
{
$comb_str="$comb_str,"."$tmp"
}	
print "$_\t$comb_str\n"; 
$comb_str=""; ##Emptying the string otherwise each loop appends to previous variable
}

