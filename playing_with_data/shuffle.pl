use List::Util qw(shuffle);
my $start_run = time();
@array=(1..60000000);
fisher_yates_shuffle( \@array );
#my @data = (1..15);
print  "yates: @array\n";
my @cards = shuffle @array;
print "perl shuffle: @cards\n";
sub fisher_yates_shuffle
{
    my $array = shift;
    my $i = @$array;
    while ( --$i )
    {
        my $j = int rand( $i+1 );
        @$array[$i,$j] = @$array[$j,$i];
    }
}
my $end_run = time();
my $run_time = $end_run - $start_run;
print "Job took $run_time seconds\n";
#print  "yates: @array\n";

