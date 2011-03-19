#!/usr/bin/env perl

use strict;
use warnings;
use PerlIO::gzip;
use Data::Dumper  qw/Dumper/;

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
my %dir_hash = ();
my @cmds = undef;

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
	open($FWH, ">", "dirlist.txt" ) || die ("Couldn't open ARG[1]: $!\n");
}

my @field;
my $cmd;
my $path = undef;
my $file_name = undef;
my $suffix_name;
my $pos;


printf("%-71s%s", "Running " , " [  0.0%]");
alarm 1;

$progress_finished = 0;
$progress_total = Liu::get_uncompressed_size($ARGV[0]);


while(<$FRH>){
		
	$progress_finished += length $_;

	$path = (split /\|/, $_)[3];

    chomp $path;

    my $dir = Liu::dirname($path);

    # print "Path:$path\next:$suffix_name\ndir:$dir\n";
    if (!defined $dir_hash{$dir}) {
        $dir_hash{$dir} = 1;
    }
}

foreach (keys %dir_hash) {
    if ($_) {
        printf $FWH "%s\n", $_;
    }
}

close($FRH);
close($FWH);

alarm 0; 
print "\b\b\b\b\b\b\b\b[ done ]\n";
