#!/usr/bin/env perl
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
# print Dumper(\@ARGV);
die ("$progname: wrong number of arguments\n") if (scalar @ARGV) != 1 and (scalar @ARGV) != 2;


my $FWH;
if(defined $ARGV[1]){
	# open($FWH, ">", $ARGV[1]) || die "$!\n";
    print "XXXX\n";
} else {
    $FWH = *STDOUT;
}

my @freqs=Liu::read_into_array($ARGV[0]);
chomp @freqs;
# print Dumper(\@freqs);

my %depth_hash = map {split(/\t/, $_)} @freqs;

# print Dumper(\%depth_hash);

if (defined $opts{c} and $opts{c} eq 'rcdf') {

    my $cdf  = 0;
    my $total = sum(@freqs);

    for (my $i = 0; $i < scalar @freqs; $i++) {
        $cdf += $freqs[$i];
        printf($FWH "%.0f\t%.0f\t%f\t%f\t%f\n", $i, $freqs[$i], 
               Liu::div($i+1, scalar(@freqs)), Liu::div($freqs[$i], $total), 
               Liu::div($cdf, $total)); 
    }

} elsif (defined $opts{c} and $opts{c} eq 'pdf') {

    my $histo = Histo->new(min => 0, incr => 1,  log_incr => 0, integer_vals => 1);

    while (my ($k, $v) = each(%depth_hash)) {
        $histo->add($k, $v);
    }

    $histo->print_csv(*STDOUT, "\t");

    # $histo->print(*STDERR, "  ", "chgs", "chgs" );
}

# # my @depth = map {(split(/\t/, $_))[0]} @freqs;
# # my %depth_hash;
# # @freqs = map {(split(/\t/,$_))[1]} @freqs;

# # for(my $i = 0; $i < scalar @freqs; $i++){
# # 	$depth_hash{$depth[$i]} = $freqs[$i];
# # }

# # my @new_depth = sort {$a <=> $b} keys %depth_hash;



# # if (defined $opts{c} and $opts{c} eq 'rcdf') {

# #     my $cdf  = 0;
# #     my $total = sum(@freqs);

# #     for (my $i = 0; $i < scalar @freqs; $i++) {
# #         $cdf += $freqs[$i];
# #         printf($FWH "%.0f\t%.0f\t%f\t%f\t%f\n", $depth[$i], $freqs[$i], Liu::div($i+1, scalar(@freqs)), Liu::div($freqs[$i], $total), Liu::div($cdf, $total)); 
# #     }

# # } elsif (defined $opts{c} and $opts{c} eq 'pdf') {

# #     my $cdf  = 0;
# #     my $total = sum(@freqs);

# #     for (my $i = 0; $i < scalar @new_depth; $i++) {
# #         $cdf += $depth_hash{$new_depth[$i]};
# #         printf($FWH "%.0f\t%.0f\t%f\t%f\t%f\n", $new_depth[$i], $depth_hash{$new_depth[$i]}, Liu::div($i+1, scalar(@new_depth)), Liu::div($depth_hash{$new_depth[$i]}, $total), Liu::div($cdf, $total)); 
# #     }
#  my $histo = Histo->new(min => 0, incr => 1,  log_incr => 0, integer_vals => 1);

# while (my ($k, $v) = each %depth_hash) {
#     $histo->add($k, $v);
# }
#  foreach my $freq (@freqs) {
#      $histo->add($freq, 1);
#  }

#  $histo->print_csv(*STDOUT, "\t");

#  $histo->print(*STDERR, "  ", "chgs", "chgs" );
# # }

