# Author: Prakki Sai Rama Sridatta

# Date: January 28, 2020

# A perl script to find the connected components from the list of pairs

# Usage: perl ClustrPairs.pl pairs_tab_delim.list

=a
% cat pairs.list

Jan<TABSPACE>Feb
Jan<TABSPACE>Mar
Jan<TABSPACE>Apr
Jun<TABSPACE>Dec
Jul<TABSPACE>Aug
=cut


#!/usr/bin/perl

use Graph::Undirected;
use File::Slurp;
use List::MoreUtils qw(uniq);

$g = Graph::Undirected->new;

#use strict; 
#use warnings;

$filename="$ARGV[0]";

open FH,"$filename";

@set_array = map { chomp; [split /\t/] } <FH>;

	foreach $tmp(@set_array)
	{
	#print "$tmp";
	chomp($tmp);
	($v1,$v2)=(@{$tmp}[0],@{$tmp}[1]);
	push(@temp,"$v1","$v2");
	}

@key_array = uniq(@temp); #Unique elements

=aprint "@key_array\n";
print "setarray-->@set_array\n";
print "$set_array[0][0]---$set_array[0][1]\n";
=cut

$g->add_vertex( $_ ) for @key_array;
$g->add_edge( $_->[0], $_->[1] ) for @set_array;

$i=1;

print "-----Cluster:".$i++."-------\n$_\n" for 
    sort { length($b) <=> length($a) || $a cmp $b }
    map {join( "\n",  sort(@$_) )}  
    $g->connected_components;
	
	


