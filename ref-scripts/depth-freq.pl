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
die ("$progname: wrong number of arguments\n") if (scalar @ARGV) != 1 and (scalar @ARGV) != 2;


my $FWH;
if (defined $ARGV[2]) {
	open($FWH, ">:gzip", $ARGV[2]) || die "$!\n";
} else {
    $FWH = *STDOUT;
}

my %hash;

my ($x, $y, $FH, $FH2);
if (defined $opts{c} and $opts{c} eq "xy") {
    

    # read the frequency into array
    open($FH, "<:gzip", $ARGV[0]) or die $!;
    my @tmp_array=<$FH>;
    close($FH);

    chomp @tmp_array;
    foreach (@tmp_array) {

        my ($freq, $dir_name) = split(/\|/,$_);

        my @dir_list = split /\\/, $dir_name;
        my $depth = $#dir_list;
        my $key = "$depth\t$freq";
        if ($depth == 21 and $freq == 32) {
            print $dir_name;
        }
        # printf $FWH "%.0f\t%.0f\n", $depth, $freq;
        if (defined $hash{$key}) {
            $hash{$key} += 1;
        } else {
            $hash{$key} = 1;
        }

    }
}

while (my ($k, $v) = each %hash) {
    printf $FWH "%s\t%.0f\n", $k, $v;
}

close($FWH);
