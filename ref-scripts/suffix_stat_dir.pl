#!/usr/bin/env perl

use strict;
use warnings;
use PerlIO::gzip;
use Data::Dumper  qw/Dumper/;
use Getopt::Std    qw/getopts/;

use FindBin        qw/$Bin/;
use lib $Bin;
use CIFS;
use Liu;

$| = 1; # turn on the auto flush.
my $progress_desc;
my $progress_estr;
our $progress_total    = 100;
our $progress_finished = 0;

# to generate progress report.
local $SIG{ALRM} = sub { 
	printf("\b\b\b\b\b\b\b\b[%5.1f%%]", 
		Liu::div($progress_finished, $progress_total)*100); 
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
	open($FWH, ">:gzip", $ARGV[1]) || die ("Couldn't open ARG[1]: $!\n");
}
else{
	die ("wrong command!\n");
}

my @field;
my $cmd;
my $path = undef;
my $file_name = undef;
my $suffix_name;
my $pos;

my %dir_hash;
# load dir_hash if specified
if (defined $opts{d}) {
    my @lines = Liu::read_into_array($opts{d});
    chomp @lines;
    %dir_hash = map {$_ => 1} @lines; 
}


printf("%-71s%s", "Running " , " [  0.0%]");
alarm 1;

$progress_finished = 0;
$progress_total = Liu::get_uncompressed_size($ARGV[0]);


while(<$FRH>){
		
	$progress_finished += length $_;

	($cmd, $path) = (split /\|/, $_)[0,3];

    # ignore read command
	next if CIFS::getflag($cmd) == 0;

    chomp $path;

    # ignore empty path and directory
    next if $path eq "" or defined $dir_hash{$path};

    $suffix_name = Liu::extension($path);
    my $dir = Liu::dirname($path);

    # print "Path:$path\next:$suffix_name\ndir:$dir\n";
	if(exists $suffix_hash{$suffix_name}){
		$suffix_hash{$suffix_name}->{$dir} = 1;
	}
	else{
		$suffix_hash{$suffix_name} = {$dir => 1};
	}
}


my $d = Data::Dumper->new([\%suffix_hash], [qw(*suffix_hash)]);
print $FWH $d->Purity(1)->Indent(1)->Dump . "\n";
print $FWH "1;\n";

close($FRH);
close($FWH);

alarm 0; 
print "\b\b\b\b\b\b\b\b[ done ]\n";
