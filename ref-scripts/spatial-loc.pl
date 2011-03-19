#!/usr/bin/env perl

use strict;
use warnings;


use strict;
use warnings;
use PerlIO::gzip;
use Getopt::Std    qw/getopts/;
use Data::Dumper   qw/Dumper/;
use File::Basename qw/basename/;
use POSIX          qw/strftime frexp/;
use List::Util     qw/sum max/;

use Liu;
use Histo;

my $progname = File::Basename::basename($0);
my %opts;

Getopt::Std::getopts( "hc:", \%opts );
if ( $opts{h} ) {
	usage();
    exit 0;
}


die ("$progname: wrong number of arguments\n") if (scalar @ARGV) != 1;

my @freqs=Liu::read_into_array($ARGV[0]);

if (defined $opts{c} and $opts{c} eq 'rcdf') {

    my $cdf  = 0;
    my $total = sum(@freqs);

    for (my $i = 0; $i < scalar @freqs; $i++) {
        $cdf += $freqs[$i];
        printf("%.0f\t%.0f\t%f\t%f\t%f\n", $i, $freqs[$i], Liu::div($i+1, scalar(@freqs)), Liu::div($freqs[$i], $total), Liu::div($cdf, $total)); 
    }

} elsif (defined $opts{c} and $opts{c} eq 'cdf') {

    my $histo = Histo->new(min => 0, incr => 1,  log_incr => 0, integer_vals => 1);

    foreach my $freq (@freqs) {
        $histo->add($freq, 1);
    }

    $histo->print_csv(*STDOUT, "\t");

    # $histo->print(*STDERR, "  ", "chgs", "chgs" );
}

sub read_into_array {
    my ($path) = @_;
    
    open(FH, "<", $path) or die $!;
    my @array=<FH>;
    close(FH);
    return @array;
}

