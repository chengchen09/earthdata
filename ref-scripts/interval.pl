#!/usr/bin/env perl
use strict;
use warnings;
use PerlIO::gzip;
use Getopt::Std    qw/getopts/;
use Data::Dumper   qw/Dumper/;
use File::Basename qw/basename/;
use POSIX          qw/strftime frexp/;
use List::Util     qw/sum max/;

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
if(defined $ARGV[1]){
	open($FWH, ">", $ARGV[1]) || die "$!\n";
} else {
    $FWH = *STDOUT;
}

if (defined $opts{c} and $opts{c} eq "pdf") {
#    my @bin = (0.0001, 0.001, 0.01, 0.1, 1, 30, 60, 300, 3600, 7200, 14400, 28800,  86400, 172800, 604800, 1209600);
    my @bin = (0.0001, 0.001, 0.01, 0.1, 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000);
    my $counter = Counter->new(\@bin, 1);

    my $FRH;
    open ($FRH, "<:gzip", $ARGV[0]) or die "failed to open file $ARGV[0]\n";

    while (<$FRH>) {
        chomp;
        my $interval = (split /\|/,$_)[0];
        $counter->add($interval, 1);
    }
    $counter->print_csv(*STDOUT, "\t");
   $counter->print(*STDERR, "  ", "chgs");
}

