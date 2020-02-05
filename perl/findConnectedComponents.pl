# Author: Prakki Sai Rama Sridatta

# Date: February 05, 2020

# A perl script to find the connected components. Data Should look like and should be delimted by tab and passed from a file:
=a
A B
B C
C D
E F
=cut

# Usage: perl ClustrPairs.pl <pairsFile.list>

#!/usr/bin/perl

use Graph::Undirected;
use File::Slurp;
use List::MoreUtils qw(uniq);
use List::Util qw/first/;

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
	#print "V1 is $v1, V2 is $v2\n";
	push(@temp,"$v1","$v2");
	}

@key_array = uniq(@temp); #Unique elements

=aprint "@key_array\n";
print "setarray-->@set_array\n";
print "$set_array[0][0]---$set_array[0][1]\n";
=cut

$g->add_vertex( $_ ) for @key_array;
$g->add_edge( $_->[0], $_->[1] ) for @set_array;

$i=1; ##For counting purposes

# Simple sort of the sequence header in each cluster

print "-----Cluster:".$i++."-------\n$_\n" for 
    sort { length($b) <=> length($a) || $a cmp $b }
    map {join( "\n", (@$_) )}  
    $g->connected_components;

