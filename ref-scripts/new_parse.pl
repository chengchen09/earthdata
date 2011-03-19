#!/usr/bin/env perl

use strict;
use warnings;
use PerlIO::gzip;
# use DateTime;
use Time::Piece;
use List::Util qw(sum);

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

my @ft;
$ft[0] = "f";
$ft[1] = "d";
$ft[2] = "p";

my $file_dir	= undef;
my @file_list	= undef;
my $FWH			= undef;
my $file		= undef;
#my %frame_hash;

# input directory
if(defined $ARGV[0]){
	$file_dir = $ARGV[0];
}
else{
	$file_dir = '.';
}

# output file
if(defined $ARGV[1]){
	open($FWH, ">:gzip", $ARGV[1]) || die ("Couldn't open ARG[1]: $!\n");
}
else{
	die ("Wrong Command!\n");
}

# add sort so that we can process the file in a predetermined order.
@file_list = map {"$file_dir/$_" } sort grep {/.*\.gz/ } FileAccess::listfiles($file_dir); 

printf("%-71s%s", "Running " , " [  0.0%]");
alarm 1;

$progress_finished = 0;
$progress_total = sum (map {FileAccess::get_uncompressed_size($_)} @file_list);


foreach (@file_list){

    my $cmd_hex = undef;
    my $path    = undef;
	my $local_time = undef;
	my $epoch_str = undef;
    my $epoch_time = undef;
	my $nanosecond = undef;
	my $response = undef;
	my $res_frame_no = undef;
	my $frame_no = undef;
	my $res_a2 = undef;
	my $pos;
	my $pos2;

	my $create_action = undef;
	my $file_type = undef;
	my $is_directory = undef;

	my %frame_hash;

	# open file
	my $FRH;
	open($FRH, "<:gzip", $_) || die ("Could not open file: $!\n");

	print "start reading $_\n";

	while(<$FRH>){
		
        $progress_finished += length $_;

		if (($pos = index($_, "Frame ")) >= 0) {

            if ((!(defined $response)) && (defined $path)) {
                $epoch_time = Time::Piece->strptime($epoch_str, "%b %d, %Y %H:%M:%S");
				if($cmd_hex ne "a2"){
					printf($FWH "%s|%s|%s|%s\n", $cmd_hex, $epoch_time->epoch, $nanosecond, $path);
				}
				else{
					$frame_hash{$frame_no} = sprintf("%s|%s|%s|%s", 
								$cmd_hex, $epoch_time->epoch, $nanosecond, $path);

				}
            }
			# response to a 0xa2 frame
			elsif((defined $response) && (defined $res_a2)){
				if(defined $frame_hash{$res_frame_no}){
					if(defined $create_action && defined $file_type){
						printf($FWH "%s|%s|%s\n", $frame_hash{$res_frame_no}, $create_action, $file_type);
					}
					$frame_hash{$res_frame_no} = undef;
				}
			}

			chomp;

			$frame_no = substr($_, $pos + 6);
            $path = undef;
			$response = undef;
			$res_a2 = undef;
			$create_action = undef;
			$file_type = undef;
			$res_frame_no = undef;
			next;
		}
		
		if(($pos = index($_, "Arrival Time:")) >= 0){
            $epoch_str = substr($_, $pos+14, 21);
            $nanosecond = substr($_, $pos+36, 9);
			next;
		}

		# check for response frame
		if(($pos = index($_, "[Response to:")) >= 0){
			$response = 1;
			$pos2 = index($_, "]");
			$res_frame_no = substr($_, $pos+14, $pos2-$pos-14);
			next;
		}
		
		if(($pos = index($_, "SMB Command:")) >= 0){
			$pos = index($_, "(");
			$cmd_hex = substr($_, $pos + 3, 2);
			next;
		}

		# parse response frame
		if(defined $response){
			if($cmd_hex ne "a2"){
				next;
			}

			$res_a2 = 1;

			if(($pos = index($_, "Create action:")) >= 0){
				if(($pos = index($_, "(")) >= 0){
					$create_action = substr($_, $pos + 1, 1);
					if($create_action eq "1"){
						$create_action = "r";
					}
					elsif($create_action eq "2" || $create_action eq "3"){
						$create_action = "w";
					}
				}
			}
			elsif(($pos = index($_, "File Type:")) >= 0){
				if(($pos = index($_, "(")) >= 0){
					$file_type = substr($_, $pos + 1, 1);
				}
			}
			elsif(($pos = index($_, "Is Directory:")) >= 0){
				if(($pos = index($_, "(")) >= 0){
					$is_directory = substr($_, $pos + 1, 1);
					$file_type = $is_directory + $file_type;
					$file_type = $ft[$file_type];	
				}
			}

			next;
		}

		# parse request frame
		else{
			# d0 - e1: 0x32 subcommand
			if(($pos = index($_, "Subcommand:")) >= 0){
				my $subcmd;
				$pos = index($_, "(");
				$subcmd = substr($_, $pos + 5, 2);
				if(($pos >= 0) && ($cmd_hex eq "32")){
					$subcmd = 0xd0 + hex($subcmd);
					$cmd_hex = sprintf "%x", $subcmd;
				}
			}
			
			# e2 - e5: 0xa2 NT_CREATE_ANDX
			# e2: Open
			# e3: Create
			# e4: Open If
			# e5: Overwrite If
#			if(($pos = index($_, "Disposition")) >= 0){
#				if(($pos = index($_, "Disposition: Open (")) >= 0){
#					$cmd_hex = "e2";
#				}
#				elsif(($pos = index($_, "Disposition: Create (")) >= 0){
#					$cmd_hex = "e3";
#				}
#				elsif(($pos = index($_, "Disposition: Open If")) >= 0){
#					$cmd_hex = "e4";
#				}
#				elsif(($pos = index($_, "Disposition: Overwrite If")) >= 0){
#					$cmd_hex = "e5";
#				}
#
#				next;
#			}

			# f1 - f6: 0xa0 subcommand
			if(($pos = index($_, "Function: NT")) >= 0){
				my $subcmd;
				$pos = index($_, "(");
				$subcmd = substr($_, $pos + 1, 1);
				if($cmd_hex eq "a0"){
					$subcmd = 0xf0 + $subcmd;
					$cmd_hex = sprintf "%x", $subcmd;
				}
			}

			if(($pos = index($_, "File Name:")) >= 0){
        	    # print $_, "\n";
				chomp;
        	    $path = substr($_, $pos + 11);
        	    if (substr($path, (length($path) - 1), 1) eq ']') {
        	        $path = substr($path, 0, length($path) - 1);
        	    } 

				next;
			}
		}
	}#end while

	close($FRH);
}# end foreach

close($FWH);

alarm 0; 
print "\b\b\b\b\b\b\b\b[ done ]\n";


package FileAccess;

sub listfiles {
	my ($dir, $die) = @_;
	my ($DIR, @files);
	
	# Don't not mixed use bare word directory handle and threads
	# there is a latentbug. So we change DIR to $DIR.
	if (!opendir($DIR, $dir)) {
		if (defined $die) {
			die "$!\n";
		} else {
			warn "$!\n";
			return undef;
		} 
	}
	
	@files = readdir $DIR;
	close $DIR;
	
	return @files;
}

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
