#!/usr/bin/env perl

use strict;
use warnings;
use PerlIO::gzip;
use File::Basename;
#use List::Util qw(sum);


#my $progdir = dirname($0);
#print "$progdir\n";
#my $stop = <STDIN>;

#BEGIN{
#	push @INC, $progdir;
#}
use FindBin        qw/$Bin/;
use lib $Bin;
use CIFS;        
use Liu;
use Counter;
          
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
my $FWH2 = undef;


# my @bin = (0.0001, 0.001, 0.01, 0.1, 1, 30, 60, 300, 3600, 7200, 14400, 28800,  86400, 172800, 604800, 1209600);
# my $fcnt = Counter->new(\@bin, 1);
# my $dcnt = Counter->new(\@bin, 1);

# input directory
if(defined $ARGV[0]){
	open($FRH, "<:gzip", $ARGV[0]) || die ("Could not open file: $!\n");
}
else{
	die ("wrong command!\n");
}

# input file
if(defined $ARGV[1]){
	open($FWH, ">:gzip", $ARGV[1]) || die ("Couldn't open ARG[1]: $!\n");
}
else{
	die ("wrong command!\n");
}

# output file
if(defined $ARGV[2]){
	open($FWH2, ">:gzip", $ARGV[2]) || die ("Couldn't open ARG[1]: $!\n");
}
else{
	die ("wrong command!\n");
}

my $dir = undef;
my $finterval;
my $dinterval;
my $range;
my $filetype;
my %path_hash;
my %dir_hash;



printf("%-71s%s", "Running " , " [   0.0%]");
alarm 1;

$progress_finished = 0;
$progress_total = Liu::get_uncompressed_size($ARGV[0]);

while(<$FRH>){

	$progress_finished += length $_;
	chomp;

	my ($cmd, $ts1, $ts2, $path, $type) = (split /\|/, $_)[0..3,5];
	my $ts = $ts1+ $ts2 / 1000000000;

	if(!(defined $path)){
		next;
	}

    $dir = Liu::dirname($path);
    if ($type eq 'f' and defined $path_hash{$path}) {
        $finterval = abs ($ts - $path_hash{$path});
        printf $FWH "%f|%s\n", $finterval, $path;
    }
    if (defined $dir_hash{$dir}) {
        $dinterval = abs ($ts - $dir_hash{$dir});
        printf $FWH2 "%f|%s\n", $dinterval, $dir;
    }

    $path_hash{$path} = $ts;
    $dir_hash{$dir} = $ts;

}


close($FRH);
close($FWH);
close($FWH2);

alarm 0; 
print "\b\b\b\b\b\b\b\b[ done ]\n";


