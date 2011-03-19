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
my $FWH2 = undef;
my %path_hash;
my %file_hash;
my %cmd_hash;
my @access_count = undef;
my @cmds = undef;
my @diff_array;

#my %dir_diff = ("1ms"=>0,
#				"1s"=>0,
#				"1m"=>0,
#				"1h"=>0,
#				"2h"=>0,
#				"4h"=>0,
#				"8h"=>0,
#				"16h"=>0,
#				"2day"=>0,
#				"1week"=>0,
#				"1month"=>0,
#				"other"=>0);
#
#my %file_diff = ("1ms"=>0,
#				"1s"=>0,
#				"1m"=>0,
#				"1h"=>0,
#				"2h"=>0,
#				"4h"=>0,
#				"8h"=>0,
#				"16h"=>0,
#				"2day"=>0,
#				"1week"=>0,
#				"1month"=>0,
#				"other"=>0);

my @dir_diff;
my @file_diff;
my @time_diff;

$dir_diff[0] = 0;
$dir_diff[1] = 0;
$dir_diff[2] = 0;
$dir_diff[3] = 0;
$dir_diff[4] = 0;
$dir_diff[5] = 0;
$dir_diff[6] = 0;
$dir_diff[7] = 0;
$dir_diff[8] = 0;
$dir_diff[9] = 0;
$dir_diff[10] = 0;
$dir_diff[11] = 0;

$file_diff[0] = 0;
$file_diff[1] = 0;
$file_diff[2] = 0;
$file_diff[3] = 0;
$file_diff[4] = 0;
$file_diff[5] = 0;
$file_diff[6] = 0;
$file_diff[7] = 0;
$file_diff[8] = 0;
$file_diff[9] = 0;
$file_diff[10] = 0;
$file_diff[11] = 0;

$time_diff[0] = "1ms";
$time_diff[1] = "1sec";
$time_diff[2] = "1min";
$time_diff[3] = "1h";
$time_diff[4] = "2h";
$time_diff[5] = "4h";
$time_diff[6] = "8h";
$time_diff[7] = "16h";
$time_diff[8] = "2day";
$time_diff[9] = "1week";
$time_diff[10] = "1month";
$time_diff[11] = "other";

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

# output file
if(defined $ARGV[2]){
	open($FWH2, ">", $ARGV[2]) || die ("Couldn't open ARG[1]: $!\n");
}
else{
	die ("wrong command!\n");
}

my @field;
my $cmd;
my $timestamp;
my $path;
my $filename;
my $dirname = undef;
my $pos;
my $diff;
my $range;

printf("%-71s%s", "Running " , " [   0.0%]");
alarm 1;

$progress_finished = 0;
$progress_total = FileAccess::get_uncompressed_size($ARGV[0]);

while(<$FRH>){

	chomp;

	@field = split /\|/, $_;
	$progress_finished += length $_;
	
	$cmd = $field[0];
	$timestamp = $field[1] + $field[2]/1000000000;
	$path = $field[3];
	
#	if(CIFS::getflag($cmd) == 0){
#		next;
#	}

	if(!(defined $path)){
		next;
	}

	$pos = rindex($path, "\\");

	if($pos > 0){
		$dirname = substr($path, 0, $pos);
		$filename = substr($path, $pos+1);
	}
	elsif($pos == 0) {
		$dirname = "\\";
		$filename = substr($path, 1);
	}
	else {
		$dirname = "\\";
		$filename = $path;
	}

	if(exists $path_hash{$dirname}){
		$diff = $timestamp - $path_hash{$dirname};
		$path_hash{$dirname} = $timestamp;
		$range = get_range($diff);
		$dir_diff[$range]++;
	}
	else{
		$path_hash{$dirname} = $timestamp;
	}

	if(defined $filename){
		if(exists $path_hash{$filename}){
			$diff = $timestamp - $path_hash{$filename};
			$path_hash{$filename} = $timestamp;
			$range = get_range($diff);
			$file_diff[$range]++;
		}
		else{
			$path_hash{$filename} = $timestamp;
		}
	}
}

for(my $i = 0; $i < 12; $i++){
	print $FWH "$time_diff[$i]\t$dir_diff[$i]\n";
}

for(my $i = 0; $i < 12; $i++){
	print $FWH2 "$time_diff[$i]\t$file_diff[$i]\n";
}

#@access_count = map {$_,"\n"} @dir_diff;
#print @access_count;
#print $FWH @access_count;
#
#@access_count = map {$_,"\n"} @file_diff;
#print @access_count;
#print $FWH2 @access_count;

#my $key;
#my $value;
#while(($key, $value) = each %dir_diff){
#	print $FWH "$key\t$value\n";
#}
#
#while(($key, $value) = each %file_diff){
#	print $FWH2 "$key\t$value\n";
#}

close($FRH);
close($FWH);
close($FWH2);

alarm 0; 
print "\b\b\b\b\b\b\b\b[ done ]\n";

sub get_range{
	my ($diff) = @_;

	my $ret = undef;

	if($diff <= 0.001){			# 1ms
		$ret = 0;
	}
	elsif($diff <= 1){			# 1s
		$ret = 1;
	}
	elsif($diff <= 60){			# 1m
		$ret = 2;
	}
	elsif($diff <= 3600){		# 1h
		$ret = 3;
	}
	elsif($diff <= 7200){		# 2h
		$ret = 4;
	}
	elsif($diff <= 14400){		# 4h
		$ret = 5;
	}
	elsif($diff <= 28800){		# 8h
		$ret = 6;
	}
	elsif($diff <= 57600){		# 16h
		$ret = 7;
	}
	elsif($diff <= 172800){		# 2day
		$ret = 8;
	}
	elsif($diff <= 604800){		# 1week
		$ret = 9;
	}
	elsif($diff <= 259200){		# 1month
		$ret = 10;
	}
	else {						# large than 2d
		$ret = 11;				
	}

	return $ret;
}

sub add_diff{
	my ($diff) = @_;


	if($diff <= 1){
		$diff_array[0]++;
	}
	elsif($diff <= 60){
		$diff_array[1]++;
	}
	elsif($diff <= 3600){
		$diff_array[2]++;
	}
	elsif($diff <= 86400){
		$diff_array[3]++;
	}
	elsif($diff <= 172800){
		$diff_array[4]++;
	}
	else {
		$diff_array[5]++;
	}
}

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

