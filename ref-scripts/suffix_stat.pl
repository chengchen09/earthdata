#!/usr/bin/env perl

use strict;
use warnings;
use PerlIO::gzip;
use Getopt::Std    qw/getopts/;
use Data::Dumper   qw/Dumper/;

use FindBin        qw/$Bin/;
use lib $Bin;
use CIFS;
use Liu;

$| = 1; # turn on the auto flush.
my $progress_desc;
my $progress_estr;
our $progress_total    = 100;
our $progress_finished = 0;

#
# Do div with default if divisor is 0.
# 
sub do_div {
	my ($a, $b, $d) = @_;
	if ($b != 0) {
		return $a / $b;
	} 
	return defined $d ? $d : 0;
}

# to generate progress report.
local $SIG{ALRM} = sub { 
	printf("\b\b\b\b\b\b\b\b[%5.1f%%]", 
		do_div($progress_finished, $progress_total)*100); 
	alarm 1; 
};

my $FRH	= undef;
my $FWH = undef;
my %suffix_hash;
my @suffix_sort = undef;
my @cmds = undef;

my %opts;
Getopt::Std::getopts( "hd:", \%opts );
if ( $opts{h} ) {
	usage();
    exit 0;
}

# input directory
if(defined $ARGV[0]){
	open($FRH, "<:gzip", $ARGV[0]) || die ("Could not open file: $!\n");
}
else{
	die ("wrong command!\n");
}

# output file
if(defined $ARGV[1]){
	open($FWH, ">", $ARGV[1]) || die ("Couldn't open ARG[1]: $!\n");
}
else{
	die ("wrong command!\n");
}

my @field;
my $cmd;
my $dir_name = undef;
my $file_name = undef;
my $suffix_name;
my $pos;
my $ftype;

my %dir_hash;
# load dir_hash if specified
if (defined $opts{d}) {
    my @lines = Liu::read_into_array($opts{d});
    chomp @lines;
    %dir_hash = map {$_ => 1} @lines; 
}

# print Dumper(\%dir_hash);

printf("%-71s%s", "Running " , " [  0.0%]");
alarm 1;

$progress_finished = 0;
$progress_total = FileAccess::get_uncompressed_size($ARGV[0]);


while(<$FRH>){
		
	$progress_finished += length $_;

	($cmd, $dir_name, $ftype) = (split /\|/, $_)[0,3,5];

    # ignore read command
#next if CIFS::getflag($cmd) == 0;

    chomp $dir_name;

    # ignore empty path and directory
    if ($dir_name eq "" or $ftype eq "d" or defined $dir_hash{$dir_name}) {
        # print "skip $dir_name \n";
        next;
    }

    $suffix_name = Liu::extension($dir_name);

    # print $suffix_name, "\n";

	# @field = split /\|/, $_;
	
	# $cmd = $field[0];
	# $dir_name = $field[3];

	# if(CIFS::getflag($cmd) == 0){
	# 	next;
	# }

	# # get file name
	# $pos = rindex($dir_name, "\\");

	# if($pos > 0){
	# 	$file_name = substr($dir_name, $pos);
	# }
	# else {
	# 	$file_name = $dir_name;
	# }

	# # get suffix
	# $pos = rindex($file_name, "\.");
	# if($pos > 0) {
	# 	chomp $file_name;
	# 	$suffix_name = substr($file_name, $pos + 1);
	# 	if((length $suffix_name) > 5){
	# 		$suffix_name = "none";
	# 	}
	# }
	# else {
	# 	$suffix_name = "none";
	# }
#	if ($suffix_name eq "none") {
#		print "$dir_name\n";
#	}

	if(exists $suffix_hash{$suffix_name}){
		$suffix_hash{$suffix_name}++;
	}
	else{
		$suffix_hash{$suffix_name} = 1;
	}
}

@suffix_sort = sort {$suffix_hash{$b} <=> $suffix_hash{$a}} keys %suffix_hash;

foreach(@suffix_sort){
	print $FWH "$_\t$suffix_hash{$_}\n";
}

close($FRH);
close($FWH);

alarm 0; 
print "\b\b\b\b\b\b\b\b[ done ]\n";

package FileAccess;

sub get_uncompressed_size {
    my ($path) = @_;

    # open(GZINFO, 'gzip -l /media/data/ss223meta/20100901-0000.meta.gz |');
    open (GZINFO, "gzip -l $path |");
    my @gzinfo = <GZINFO>; 
    close(GZINFO);
    # my @fs =  split(/[ 	]+/,$gzinfo[1]);
    # return $fs[2];
    return (split(/[ 	]+/,$gzinfo[1]))[2];
}
