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
die ("$progname: wrong number of arguments\n") if (scalar @ARGV) != 1 and (scalar @ARGV) != 2;


my $FWH = *STDOUT;
if(defined $ARGV[1]){
	open($FWH, ">", $ARGV[1]) || die "$!\n";
}

my @ext_freqs=Liu::read_into_array($ARGV[0]);
chomp @ext_freqs;
my @keys  = map {(split(/\t/,$_))[0]} @ext_freqs;
my %ext_hash = map {split(/\t/,$_)} @ext_freqs;


if (defined $opts{c} and $opts{c} eq 'rcdf') {

    my $cdf  = 0;
    my $total = sum(values %ext_hash);

    my $i = 0;
    foreach (@keys) {
        next if $_ eq "none";
        $cdf += $ext_hash{$_};
        ++$i;
        printf($FWH "%.0f\t%.0f\t%f\t%f\t%f\n", $i, 
               $ext_hash{$_}, Liu::div($i, scalar(@keys)), 
               Liu::div($ext_hash{$_}, $total), Liu::div($cdf, $total)); 
 
    }
    ++$i;
    $cdf += $ext_hash{none};
    printf($FWH "%.0f\t%.0f\t%f\t%f\t%f\n", $i, 
           $ext_hash{none}, Liu::div($i, scalar(@keys)), 
           Liu::div($ext_hash{none}, $total), Liu::div($cdf, $total)); 

    # for (my $i = 0; $i < scalar @freqs; $i++) {
    #     $cdf += $freqs[$i];
    #     printf($FWH "%.0f\t%.0f\t%f\t%f\t%f\n", $i, 
    #            $freqs[$i], Liu::div($i+1, scalar(@freqs)), 
    #            Liu::div($freqs[$i], $total), Liu::div($cdf, $total)); 
    # }

} 
elsif (defined $opts{c} and $opts{c} eq 'pdf') {

    my $cdf  = 0;
    my $total = sum(values %ext_hash);

    my $i = 0;
    foreach (@keys) {
        next if $_ eq "none";
        $cdf += $ext_hash{$_};
        ++$i;
        printf($FWH "%.0f\t%.0f\t%f\t%f\t%f\n", $i, 
               $ext_hash{$_}, Liu::div($i, scalar(@keys)), 
               Liu::div($ext_hash{$_}, $total), Liu::div($cdf, $total)); 
 
    }
    ++$i;
    $cdf += $ext_hash{none};
    printf($FWH "%.0f\t%.0f\t%f\t%f\t%f\n", $i, 
           $ext_hash{none}, Liu::div($i, scalar(@keys)), 
           Liu::div($ext_hash{none}, $total), Liu::div($cdf, $total)); 


    # my $cdf  = 0;
    # my $total = sum(@freqs);

    # for (my $i = 0; $i < scalar @freqs; $i++) {
    #     $cdf += $freqs[$i];
    #     printf($FWH "%.0f\t%.0f\t%f\t%f\t%f\n", $i, 
    #            $freqs[$i], Liu::div($i+1, scalar(@freqs)), 
    #            Liu::div($freqs[$i], $total), Liu::div($cdf, $total)); 
    # }
}
