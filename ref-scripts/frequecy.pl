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
    my @bin = (1, 10, 100, 1000, 10000, 100000, 1000000, 10000000);
    my $counter = Counter->new(\@bin, 1);

    my $FRH;
    open ($FRH, "<:gzip", $ARGV[0]) or die "failed to open file $ARGV[0]\n";

    while (<$FRH>) {
        chomp;
        my $freq = (split /\|/,$_)[0];
        $counter->add($freq, 1);
    }
    $counter->print_csv($FWH, "\t");
   $counter->print(*STDERR, "  ", "chgs");
}
elsif (defined $opts{c} and $opts{c} eq "cdf") {
    my @bin = (1, 10, 100, 1000, 10000, 100000, 1000000, 10000000);
    my $counter = Histo->new(min=>1, incr=>1, log_incr=>0,integer_vals=>1);

    my $FRH;
    open ($FRH, "<:gzip", $ARGV[0]) or die "failed to open file $ARGV[0]\n";

    while (<$FRH>) {
        chomp;
        my $freq = (split /\|/,$_)[0];
        $counter->add($freq, 1);
    }
    $counter->print_csv($FWH, "\t");
   # $counter->print(*STDERR, "  ", "chgs");
}

