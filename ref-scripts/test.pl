#!/usr/bin/env perl

use strict;
use warnings;
use PerlIO::gzip;
use Data::Dumper  qw/Dumper/;

use FindBin        qw/$Bin/;
use lib $Bin;
use CIFS;
use Liu;


my $file = "d8|1190301377|753944000||w|f";

if($file =~ /\|\|/){
	print $file;
}

