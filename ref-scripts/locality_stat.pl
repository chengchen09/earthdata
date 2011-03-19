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
	open($FWH, ">", $ARGV[1]) || die ("Couldn't open ARG[1]: $!\n");
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
$progress_total = FileAccess::get_uncompressed_size($ARGV[0]);


while(<$FRH>){
	
		
	@field = split /\|/, $_;
	$progress_finished += length $_;
	
	$cmd = $field[0];
	$dir_name = $field[3];
	
#if(CIFS::getflag($cmd) == 0){
#		next;
#	}

	$pos = rindex($dir_name, "\\");

	if($pos >0){
		$dir_name = substr($dir_name, 0, $pos);
	}
	else {
		$dir_name = "\\";
	}

	if(exists $dir_hash{$dir_name}){
		$dir_hash{$dir_name}++;
	}
	else{
		$dir_hash{$dir_name} = 1;
	}
}

@access_count = sort {$b <=> $a} values %dir_hash;

foreach(@access_count){
	print $FWH $_,"\n";
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
