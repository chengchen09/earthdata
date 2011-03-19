#!/usr/bin/env perl

use strict;
use warnings;
use PerlIO::gzip;
use Getopt::Std    qw/getopts /;
use Data::Dumper   qw/Dumper  /;
use File::Basename qw/basename/;
use POSIX          qw/strftime frexp/;
use List::Util     qw/sum max /;

# FindBin is used for determine the abs path of the script.
# Please put our own module into the script directory, so
# so that it can be found by perl.
use FindBin        qw/$Bin/;
use lib $Bin;
use Liu;
use CIFS; 

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
my %dir_hash;
my %cmd_hash;
my @access_count = undef;
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
	open($FWH, ">:gzip", $ARGV[1]) || die ("Couldn't open ARG[1]: $!\n");
}
else{
	die ("wrong command!\n");
}

my @field;
my $cmd;
my $dir_name = undef;
my @dir_list = undef;
my $pos;

printf("%-71s%s", "Running " , " [  0.0%]");
alarm 1;

$progress_finished = 0;
$progress_total = Liu::get_uncompressed_size($ARGV[0]);



while(<$FRH>){
	$progress_finished += length $_;
	
	$cmd = substr($_, 0, 2);
	# print $FWH $_ if $cmdmask[hex $cmd] == 1; 
    if(CIFS::check_modify($_) == 1){
	
		if($cmd ne "a2"){
			chomp;
			printf($FWH "%s|w|f\n", $_);
		}
		else{
			printf($FWH "%s", $_);
		}
	}
}


close($FRH);
close($FWH);

alarm 0; 
print "\b\b\b\b\b\b\b\b[ done ]\n";


