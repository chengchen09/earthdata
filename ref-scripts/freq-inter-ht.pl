#!/usr/bin/env perl
use strict;
use warnings;
use PerlIO::gzip;
use Getopt::Std    qw/getopts/;
use Data::Dumper   qw/Dumper/;
use File::Basename qw/basename/;
use POSIX          qw/strftime frexp/;
use List::Util     qw/sum max first/;

use FindBin        qw/$Bin/;
use lib $Bin;
use Liu;
use Histo;
use Counter;

my $progname = File::Basename::basename($0);
my %opts;

Getopt::Std::getopts( "hc:", \%opts );
if ( $opts{h} ) {
	usage();
    exit 0;
}
# print Dumper(\@ARGV);
die ("$progname: wrong number of arguments\n") if (scalar @ARGV) != 2 and (scalar @ARGV) != 3;


my $FWH;
if(defined $ARGV[2]){
	open($FWH, ">", $ARGV[2]) || die "$!\n";
} else {
    $FWH = *STDOUT;
}

my ($x, $y, $FH, $FH2);
if (defined $opts{c} and $opts{c} eq "ht") {
    
    my %freq_hash;

    # read the frequency into array
    open($FH, "<:gzip", $ARGV[0]) or die $!;
    my @tmp_array=<$FH>;
    close($FH);

    chomp @tmp_array;
    %freq_hash = map { (split /\|/,$_) [1,0] } @tmp_array;

    # my @xbound = (1, 10, 100, 1000, 10000, 100000, 1000000, 10000000); # freq
    # my @ybound = (0.1, 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000); # interval
    
    my @xbound = map {2**$_} 0..14; # freq
    my @ybound = map {10**$_} -3 .. 7; # interval
    my @xindex = (0..$#xbound);
    my @yindex = (0..$#ybound);

    my @map = map { [map {0} @ybound] } @xbound;

    # print Dumper(\@map);

    open($FH2, "<:gzip", $ARGV[1]) or die $!;
    while (<$FH2>) {

        chomp;
        my ($interval, $path) = split(/\|/,$_);
        $y = first { $interval <= $ybound[$_] } @yindex;

        my $freq = $freq_hash{$path};
        $x = first { $freq <= $xbound[$_] } @xindex;

        $map[$x]->[$y] += 1;
    }
    close($FH2);

    foreach  $x (@xindex) {
        foreach  $y (@yindex) {
            printf $FWH "%.0f\t%.0f\t%.0f\n", $x, $y, $map[$x]->[$y];
        }
    }
}

