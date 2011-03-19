##### Counter.pm #####

#
# Counter.pm
#
# Histogram module for Perl.
#
# Author: Likun Liu    <liulikun@gmail.com>
#
# Copyright (c) 2010 Likun Liu.
#


package Counter;

use strict;
use warnings;
use POSIX;
use List::Util qw/sum first max/;

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

#
# print histogram contents to a CSV-format file.
#
# @arg  $fh
#   filehandle to print to
# @arg  $ht
#   data to print
# @arg  $keys 
#   according to which order to accumulate the key.
#
sub print_ht_csv {
    my ($fh, $delim, $ht, $keys,$float_value) = @_;

    my $total = sum map{ (defined $ht->{$_})? $ht->{$_}:0 } @{$keys};
    my ($e,$c) = (0, 0);

    foreach my $k (@{$keys}) {
        $e = (defined $ht->{$k})? $ht->{$k}:0;
        $c += $e;
        if (defined $float_value) {
            printf $fh "%s$delim%f$delim%f$delim%f$delim%f\n", 
                $k, $e, $c, do_div($e, $total), do_div($c, $total); 
        }
        else {
            printf $fh "%s$delim%.0f$delim%.0f$delim%f$delim%f\n", 
                $k, $e, $c, do_div($e, $total), do_div($c, $total); 
        }
    }
}

#
# Constructor for a new Counter object.  The arguments are a hash
# of parameter/value pairs.  The "histo_nr" are optional which specify
# how many kinds bins.
#
sub new {
    my ($type, $bin, $float_value) = @_;
    my $this  = {};

    $this->{bin} = $bin;
    $this->{idx} = [(0..(scalar @{$bin} - 1))];
    $this->{bucket} =  [(0) x (scalar @{$bin} + 1)];
    $this->{bucket_val} = [(0) x (scalar  @{$bin} + 1)];
    $this->{float_val}  = $float_value;

    bless $this, $type;
}

#
# Add a new data point to the histogram.
#
# @arg  $val
#   Value to add to the histogram
# @arg  $count
#   Optional; if specified, the weight of the item being added.
#   Calling add($x, 3) is the same as calling add($x) three times.
# @arg $histo_index
#   add to which histogram.
#
sub add ($$$;$) {
    my ($this, $val, $count) = @_;
    my ($index, $bin);
    
    $bin = $this->{bin};
    $index = first { $val <= $bin->[$_] } @{$this->{idx}};
	$index = scalar @{$bin} if !defined $index;
    
    $this->{bucket}->[$index] += $count;
    $this->{bucket_val}->[$index] += $val * $count;
}


#
# Get total count of the specified bin histogram.
#
# @arg  $b
#   bin histogram number
#
sub get_count ($) {
    my ($this) = @_;
    return sum @{$this->{bucket}};
}

#
# print histogram contents to a CSV-format file.
#
# @arg  $fh
#   filehandle to print to
# @arg  $ht
#   data to print
# @arg  $keys 
#   according to which order to accumulate the key.
#
sub print_csv {
    my ($this, $fh, $delim) = @_;

    my @keys = @{$this->{idx}} ;
	push @keys, scalar @keys if $this->{bucket}->[scalar @keys] > 0;

    my $total = sum map { $this->{bucket}->[$_] } @keys;
    my $total_val = sum map {$this->{bucket_val}->[$_] } @keys;
    my ($e,$c, $v, $d) = (0, 0, 0, 0);

    my $i = 0;
	foreach my $k (@keys) {
		my $key = defined $this->{bin}->[$k]?$this->{bin}->[$k]:">".$this->{bin}->[$k-1];
        $e = (defined $this->{bucket}->[$k])? $this->{bucket}->[$k]:0;
        $c += $e;
        $v = (defined $this->{bucket_val}->[$k])? $this->{bucket_val}->[$k]:0;
        $d += $v;
        if (defined $this->{float_value}) {
            printf $fh "%.0f$delim%s$delim%.0f$delim%.0f$delim%f$delim%f$delim%f$delim%f$delim%f$delim%f\n", 
                $i++, $key, $e, $c, do_div($e, $total), do_div($c, $total),
                    $v, $d, do_div($v, $total_val), do_div($d, $total_val); 
        }
        else {
            printf $fh "%.0f$delim%s$delim%.0f$delim%.0f$delim%f$delim%f$delim%.0f$delim%.0f$delim%f$delim%f\n", 
                $i++, $key, $e, $c, do_div($e, $total), do_div($c, $total),
                    $v, $d, do_div($v, $total_val), do_div($d, $total_val); 
        }
    }

}

#
# Print the histogram contents to STDOUT.
#
# @arg  $prefix
#   String to prefix each output line with.
# @arg  $unit_str
#   String that describes the units of the histogram items.
#
sub print($$$) {
    my ($this, $fh, $prefix, $unit_str) = @_;
    my @keys = @{$this->{idx}};

    my $width =  @keys ? length sprintf("%.2f", max(map { $this->{bin}->[$_] } @keys)) + 1:1;
    my $bwidth = @keys ? length sprintf("%.2f", max(map { $this->{bucket}->[$_]} @keys)):1;
    my $vwidth = @keys ? length sprintf("%.2f", max(map { $this->{bucket_val}->[$_]} @keys)):1;
	
	push @keys, scalar @keys if $this->{bucket}->[scalar @keys] > 0;

    my $total = sum map { $this->{bucket}->[$_] } @keys;
    my $total_val = sum map {$this->{bucket_val}->[$_] } @keys;
   	my $b2width = length sprintf("%.2f", $total);
	my $v2width = length sprintf("%.2f", $total_val);

	my ($e,$c, $v, $d) = (0, 0, 0, 0);

    foreach my $k (@keys) {
		my $key = defined $this->{bin}->[$k]?$this->{bin}->[$k]:">".$this->{bin}->[$k-1];
        $e = (defined $this->{bucket}->[$k])? $this->{bucket}->[$k]:0;
        $c += $e;
        $v = (defined $this->{bucket_val}->[$k])? $this->{bucket_val}->[$k]:0;
        $d += $v;
        if (defined $this->{float_value}) {
            printf $fh "%s%${width}s %${bwidth}.0f (%5.2f%%) %${b2width}.0f (%6.2f%%) %${vwidth}.2f (%5.2f%%) %{v2width}.2f (%6.2f%%)\n", 
                $prefix, $key, $e, do_div($e, $total)*100, $c, do_div($c, $total)*100,
                    $v, do_div($v, $total_val)*100, $d, do_div($d, $total_val)*100; 
        }
        else {
            printf $fh "%s%${width}s %${bwidth}.0f (%5.2f%%) %${b2width}.0f (%6.2f%%) %${vwidth}.0f (%5.2f%%) %${v2width}.0f (%6.2f%%)\n", 
                $prefix, $key, $e, do_div($e, $total)*100, $c, do_div($c, $total)*100,
                    $v, do_div($v, $total_val)*100, $d, do_div($d, $total_val)*100; 
        }
    }
}

1;
