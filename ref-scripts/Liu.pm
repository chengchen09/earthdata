package Liu;
#
# list files of a directory
#
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


sub read_into_array {
    my ($path) = @_;
    
    open(FH, "<", $path) or die $!;
    my @array=<FH>;
    close(FH);
    return @array;
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

#
# Do div with default if divisor is 0.
# 
sub div {
	my ($a, $b, $d) = @_;
	if ($b != 0) {
		return $a / $b;
	} 
	return defined $d ? $d : 0;
}

#
# Get the basename of  a file
#
sub basename {
    my ($path) = @_;

    if ($path eq "\\") {
        return $path;
    }
    while (substr($path, -1) eq "\\" ) {
        $path = substr($path, 0, (length $path) - 1);
    }
	# get file name
	$pos = rindex($path, "\\");

	if($pos > 0){
        return substr($path, $pos + 1);
	} elsif ($pos == 0) {
        return "\\";
    }
	else {
		return $path;
	}
}

#
# Get the dirname of  a file
#
sub dirname {
    my ($path) = @_;

    if ($path eq "\\") {
        return $path;
    }

    while (substr($path, -1) eq "\\" ) {
        $path = substr($path, 0, (length $path) - 1);
    }
	# get file name
	$pos = rindex($path, "\\");

	if($pos > 0){
        return substr($path, 0, $pos);
	} elsif ($pos == 0) {
        return "\\";
    }
	else {
		return "";
	}
}

#
# Get the extension of a file
#
sub extension {
    my ($path) = @_;
    my ($suffix_name, $file_name, $pos);
    # get file name
    $file_name = basename($path);

	# get suffix
	$pos = rindex($file_name, "\.");
	if($pos > 0) {
		$suffix_name = substr($file_name, $pos + 1);
		if((length $suffix_name) > 5){
			$suffix_name = "none";
		}
	} 
	else {
		$suffix_name = "none";
	}
    return $suffix_name;
}

# $| = 1; # turn on the auto flush.
our $progress_desc;
our $progress_estr;
our $progress_total    = 100;
our $progress_finished = 0;

# to generate progress report.
# local $SIG{ALRM} = sub { 
# 	printf STDERR "\b\b\b\b\b\b\b\b[%5.1f%%]", 
# 		Liu::div($progress_finished, $progress_total)*100; 
# 	alarm 1; 
# };

sub show_progress { 
	# printf STDERR "\b\b\b\b\b\b\b\b[%5.1f%%]", 
	# 	Liu::div($progress_finished, $progress_total)*100; 
    printf STDERR "\r%-72s[%5.1f%%]", (defined $progress_desc?$progress_desc:"Running ") , 
        Liu::div($progress_finished, $progress_total)*100;
	alarm 1; 
}

sub set_progress_total {
    $progress_total = $_[0];
}

sub set_progress_finished {
    $progress_finished = $_[0];
}

sub make_progress {
    $progress_finished += $_[0];
    $progress_desc = $_[1] if defined $_[1];
}

sub run_with_progress {
    my $run_proc = shift;
    my %params = @_;

    Liu::set_progress_total(defined $params{total}?$params{total}:100);
    $progress_desc = $params{desc} if defined $params{desc};
    printf STDERR "%-71s%s", (defined $progress_desc?$progress_desc:"Running ") , " [  0.0%]";
    local $SIG{ALRM} = 'Liu::show_progress';
    alarm 1;

    $run_proc->(@_);

    alarm 0; 
    print STDERR "\b\b\b\b\b\b\b\b[ done ]\n";
}

1;

