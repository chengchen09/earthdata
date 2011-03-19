#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long qw(:config gnu_getopt);

my $progname = "master";

main();
# command line arguments
# --hdf52nc4 means hdf5 transform to nc4
sub main {
	
	my $help = -1;	# if 1, print help information
	my $ph52nc4 = -1;	# if 1, launch ph52nc4

	my $nprocs;	# number of processes should be lauched
	my $status;

	if (!(defined @ARGV)) {
		usage();
		exit(0);
	}

	GetOptions("help|h|H" => \$help,
			   "ph52nc4" => \$ph52nc4);

#	printf("%d\n", $#ARGV+1);
#	print("$ARGV[0]\n");
	if (1 == $help) {
		usage();
		exit(0);
	}

	if (1 == $ph52nc4) {
		foreach (@ARGV) {
			$nprocs = get_nprocs($_);
			print("$_\n");
		}
		exit(0);
	}
}

sub usage {
	print("Usage: $progname [OPTION] ... inputfile [outputfile]\n".
	"Example: $progname --ph52nc4 *\n");
}


sub get_nprocs {

	return 1;
}
