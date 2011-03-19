#!/usr/bin/env perl

use strict;
use warnings;
use PerlIO::gzip;
#use List::Util qw(sum);

use Time::Piece;
use FindBin        qw/$Bin/;
use lib $Bin;
use Liu;
use CIFS;

$| = 1; # turn on the auto flush.
my $progress_desc;
my $progress_estr;
our $progress_total    = 100;
our $progress_finished = 0;

local $SIG{ALRM} = sub { 
	printf("\b\b\b\b\b\b\b\b[%5.1f%%]", 
		Liu::div($progress_finished, $progress_total)*100); 
	alarm 1; 
};

my $FRH	= undef;
my $FWH = undef;

my $date;
my $ts;
my $tp;
my $day;
my $hour;
my %day_hash;
my @hours_cnt = (0) x 24;

# input directory
if(defined $ARGV[0]){
	open($FRH, "<:gzip", $ARGV[0]) || die ("Could not open file: $!\n");
}
else{
	die ("wrong command!\n");
}

# output file
if(defined $ARGV[1]){
	open($FWH, ">", $ARGV[1]) || die "$!\n";
} else {
    $FWH = *STDOUT;
}

$progress_finished = 0;
$progress_total = FileAccess::get_uncompressed_size($ARGV[0]);

printf("%-71s%s", "Running " , " [  0.0%]");
alarm 1;

while(<$FRH>){
			
	$progress_finished += length $_;
	($ts) = (split /\|/, $_)[1];
	
	$tp = gmtime $ts;
	$date = sprintf("%s\t%s", $tp->ymd, $tp->day);
	$hour = $tp->hour;


	if(defined $day_hash{$date}){
		$hours_cnt[$hour]++;	
	}
	else{
		if((scalar keys %day_hash)){
			for(my $i = 0; $i < 24; $i++){
				printf($FWH "%s\t%s\n", $i + 1, $hours_cnt[$i]);
			}
		}
		$day_hash{$date} = 1;
		printf($FWH "%s\n", $date);
		@hours_cnt[0..23] = (0) x 24;
	}

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
