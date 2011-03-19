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
die ("$progname: wrong number of arguments\n") if (scalar @ARGV) != 2 and (scalar @ARGV) != 3;

my $FWH ;
if(defined $ARGV[2]){
	open($FWH, ">", $ARGV[2]) || die "$!\n";
} else {
    $FWH = *STDOUT;
}

my @ext_freqs=Liu::read_into_array($ARGV[0]);
my @keys = map {(split(/\t/,$_))[0]} @ext_freqs;
my %suffix_hash;
# load state from checkpoint file
if (-x "/usr/bin/gzcat" ) {
    my $ret = eval `gzcat $ARGV[1]`;
    if(!$ret) {
        die "couldn't parse $ARGV[1]: $@" if $@;
        die "couldn't do $ARGV[1]: $!" unless defined $ret;
        die "couldn't run $ARGV[1]" unless $ret;
    }
} 
else {
    my $ret = eval `zcat $ARGV[1]`;
    if(!$ret) {
        die "couldn't parse $ARGV[1]: $@" if $@;
        die "couldn't do $ARGV[1]: $!" unless defined $ret;
        die "couldn't run $ARGV[1]" unless $ret;
    }
}

# print Dumper(\%suffix_hash);

# my @ext_dir_freqs=Liu::read_into_array($ARGV[1]);
# chomp @ext_dir_freqs;
# my %ext_dir_hash = map {split /\t/, $_} @ext_dir_freqs;


# # print Dumper(\%ext_dir_hash);
# # print Dumper(\@keys);
if (defined $opts{c} and $opts{c} eq 'pdf') {
    # Counter::print_csv($FWH, "\t", \%ext_dir_hash, \@keys);
    my %dir_hash; 
    foreach my $v (values %suffix_hash) {
        foreach (keys %{$v}) {
            $dir_hash{$_} = 1;
        }
    }

    my $total_dir = scalar keys %dir_hash;
    my ($e,$c) = (0, 0);
    %dir_hash = ();
    my $delim = "\t";
    my $i = 0;
    foreach my $k (@keys) {
        next if $k eq "none";
        ++$i;
        if (defined $suffix_hash{$k}) {
            $e = scalar keys %{$suffix_hash{$k}};
            map { $dir_hash{$_} = 1; } keys %{$suffix_hash{$k}};
            $c = scalar keys %dir_hash;
        }
        else {
            $e = 0;
        }
        printf $FWH "%s$delim%.0f$delim%f$delim%.0f$delim%.0f$delim%f$delim%f\n", 
            $k, $i, Liu::div($i, scalar @keys), $e, $c, Liu::div($e, $total_dir), Liu::div($c, $total_dir); 
    }

    ++$i;
    if (defined $suffix_hash{"none"}) {
        $e = scalar keys %{$suffix_hash{"none"}};
        map { $dir_hash{$_} = 1; } keys %{$suffix_hash{"none"}};
        $c = scalar keys %dir_hash;
    }
    else {
        $e = 0;
    }
    printf $FWH "%s$delim%.0f$delim%f$delim%.0f$delim%.0f$delim%f$delim%f\n", 
            "none", $i, Liu::div($i, scalar @keys), $e, $c, Liu::div($e, $total_dir), Liu::div($c, $total_dir); 
    # printf $FWH "%s$delim%.0f$delim%.0f$delim%f$delim%f\n", 
    #     "none", $e, $c, Liu::div($e, $total_dir), Liu::div($c, $total_dir); 
    
}
