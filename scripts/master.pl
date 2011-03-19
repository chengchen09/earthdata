#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long;

my $progname = "master";

main();
# command line arguments
# --hdf52nc4 means hdf5 transform to nc4
sub main {
	
	my $nprocs;

	if (!(defined @ARGV)) {
		usage();
	}
	else {
		printf("%d\n", $#ARGV+1);
	}

	$nprocs = get_nprocs();
}

sub usage {
	print("Usage: $progname [OPTION] ... inputfile [outputfile]\n");
}


sub get_nprocs {

	return 1;
}
