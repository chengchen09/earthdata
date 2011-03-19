##### Histo.pm #####

#
# Histo.pm
#
# Histogram module for Perl.
#
# Author: Marc Unangst <munangst@panasas.com>
#         Likun Liu    <liulikun@gmail.com>
#
# Copyright (c) 2005 Panasas, Inc.  All rights reserved.
#


package Histo;

use strict;
use warnings;
use POSIX;

use constant {
    MIN                  => 0,
    MAX                  => 1,
    INCR                 => 2,
    INTEGER_VALS         => 3,
    COUNT                => 4,
    TOTAL_VAL            => 5,
    LOG_INCR             => 6,
    MIN_USE              => 7,
    MAX_USE              => 8,
    BUCKETS              => 9,
    BUCKETS_VAL          => 10,
    OVER_MAX             => 11,
    OVER_MAX_BUCKETS_VAL => 12,
    UNDER_MIN            => 13,
    UNDER_MIN_BUCKETS_VAL=> 14,
    MIN_VAL              => 15,
    MAX_VAL              => 16
};

#
# Constructor for a new Histo object.  The arguments are a hash
# of parameter/value pairs.  The "min" and "incr" parameters
# must be supplied.  "max" and "log_incr" are optional.
#
sub new {
    my $type = shift;
    my %params = @_;
    my $self  = [];

    die "Histo->new: required parameters not set\n"
        unless (defined $params{min} && defined $params{incr});

    $self->[MIN] = $params{min};
    $self->[MAX] = $params{max} if defined $params{max};
    $self->[INCR] = $params{incr};
    if(defined $params{integer_vals}) {
        $self->[INTEGER_VALS] = $params{integer_vals};
    }
    else {
        $self->[INTEGER_VALS] = 1;
    }

    $self->[COUNT] = 0;
    $self->[TOTAL_VAL] = 0;


    if($params{log_incr}) {
        $self->[LOG_INCR] = $params{log_incr};
        $self->[MIN_USE] = 2**$params{min};
        $self->[MAX_USE] = 2**$params{max} if defined $params{max};
    }
    else {
        $self->[LOG_INCR] = 0;
        $self->[MIN_USE] = $params{min};
        $self->[MAX_USE] = $params{max} if defined $params{max};

    }

    $self->[BUCKETS] = [];
    $self->[BUCKETS_VAL] = [];

    $self->[OVER_MAX] = 0;
    $self->[OVER_MAX_BUCKETS_VAL] = 0;
    $self->[UNDER_MIN] = 0;
    $self->[UNDER_MIN_BUCKETS_VAL] = 0;

    bless $self, $type;
}

#
# Add a new data point to the histogram.
#
# @arg  $val
#   Value to add to the histogram
# @arg  $count
#   Optional; if specified, the weight of the item being added.
#   Calling add($x, 3) is the same as calling add($x) three times.
#
# NOTE: This is the crictical function. 90% of our cost are on this function.
#
sub add ($$$;$) {
    my ($self, $val, $count, $size1) = @_;

    # user must provide $count explicitly. for performance issue.
    #    if(!defined $count) {
    #        $count = 1;
    #    }

    if( !defined ($self->[MIN_VAL]) || $val < ($self->[MIN_VAL])) {
        $self->[MIN_VAL] = $val;
    }
    if( !defined $self->[MAX_VAL] || $val > $self->[MAX_VAL]) {
        $self->[MAX_VAL] = $val;
    }

    $self->[COUNT] += $count;
    $self->[TOTAL_VAL] += ($val*$count);


    my $val_to_use = defined($size1) ? $size1 : $val;

    if(defined $self->[MAX_USE] && $val_to_use > $self->[MAX_USE]) {
        $self->[OVER_MAX] += $count;
        $self->[OVER_MAX_BUCKETS_VAL] += $val*$count;
    }
    elsif($val_to_use < $self->[MIN_USE]) {
        $self->[UNDER_MIN] += $count;
        $self->[UNDER_MIN_BUCKETS_VAL] += $val*$count;
    }
    else {
        my $b;

        if($self->[LOG_INCR]) {
            my ($mantissa, $exponent) = frexp($val_to_use);
            $b = ($exponent-1 - $self->[MIN]);
        }
        else {
            $b = int (($val_to_use - $self->[MIN]) / $self->[INCR]);
        }

        #print STDERR "sample $val into bucket $b\n";
        if (defined($self->[BUCKETS][$b])) {
            $self->[BUCKETS][$b] += $count;
            $self->[BUCKETS_VAL][$b] += $val*$count;
        } else {
            $self->[BUCKETS][$b] = $count;
            $self->[BUCKETS_VAL][$b] = $val*$count;
        }

    }
}

#
# Get maximum value of the specified bucket.
#
# @arg  $b
#   bucket number
#
# @internal
#
sub _get_bucket_max ($$) {
    my $self = shift;
    my ($b) = @_;

    if($self->[LOG_INCR]) {
        if ($b <= $#{$self->[BUCKETS]}) {
            return (2**($self->[MIN] + $b + 1)) - 1;
        } else {
            return undef;
        }
    }
    else {
        return ($self->[MIN] + ($self->[INCR]*($b+1)) -1);
    }
}

#
# Get minimum value of the specified bucket.
#
# @arg  $b
#   bucket number
#
# @internal
#
sub _get_bucket_min ($$) {
    my $self = shift;
    my ($b) = @_;

    if($self->[LOG_INCR]) {
        return (2 ** ($self->[MIN] + $b));
    }
    else {
        return ($self->[MIN] + $self->[INCR]*($b));
    }
}

#
# Get total count of the histogram.
#
# @arg  $b
#   bucket number
#
sub get_count ($) {
    my $self = shift;
    return $self->[COUNT];
}

#
# Get minimum value of the specified bucket.
#
# @arg  $b
#   bucket number
#
sub get_total_val ($) {
    my $self = shift;
    return $self->[TOTAL_VAL];
}

#
# Get count of largest bucket.
#
# @internal
#
sub _get_largest_bucket ($) {
    my $self = shift;
    my $largest_bucket = 0;
    foreach (@{$self->[BUCKETS]}) {
        $largest_bucket = $_ if (defined $_ && $largest_bucket < $_);
    }
    return $largest_bucket;
}


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
# Merge another Histo into this one.
#
# @arg $that another Histo
#
sub update($$) {
    my ($this, $that) = @_;

    if ($this->[MIN] != $that->[MIN]) {
        warn("Histo min value mismatch: $this->[MIN]and $that->[MIN]\n");
        return;
    }

    if ($this->[INCR] != $that->[INCR]) {
        warn("Histo max value mismatch: $this->[INCR]and $that->[INCR]\n");
        return;
    }

    if ($this->[INTEGER_VALS] != $that->[INTEGER_VALS]) {
        warn("Histo integer_vals mismatch: $this->[INTEGER_VALS]and $that->[INTEGER_VALS]\n");
        return;
    }

    if ($this->[LOG_INCR] != $that->[LOG_INCR]) {
        warn("Histo log_incr mismatch: $this->[LOG_INCR]and $that->[LOG_INCR]\n");
        return;
    }

    if (defined($this->[MAX]) && defined($that->[MAX])) {
        if ($this->[MAX] != $that->[MAX]) {
            warn "Histo min value mismatch: $this->[MAX]and $that->[MAX]\n" ;
        }
    } elsif (defined($that->[MAX])) {
        $this->[MAX] = $that->[MAX];
    }

    $this->[COUNT] += $that->[COUNT];
    $this->[TOTAL_VAL] += $that->[TOTAL_VAL];

    if (defined($this->[MIN_VAL]) && defined($that->[MIN_VAL])) {
        $this->[MIN_VAL] = $that->[MIN_VAL] if ($this->[MIN_VAL] > $that->[MIN_VAL]);
    } else {
        $this->[MIN_VAL] = $that->[MIN_VAL] if (defined($that->[MIN_VAL]));
    }

    if (defined($this->[MAX_VAL]) && defined($that->[MAX_VAL])) {
        $this->[MAX_VAL] = $that->[MAX_VAL] if ($this->[MAX_VAL] < $that->[MAX_VAL]);
    } else {
        $this->[MAX_VAL] = $that->[MAX_VAL] if (defined($that->[MAX_VAL]));
    }

    for (my $i = 0; $i < scalar(@{$that->[BUCKETS]}); $i++) {
        if (defined($that->[BUCKETS][$i])) {
            if (!defined($this->[BUCKETS][$i])) {
                $this->[BUCKETS][$i] = $that->[BUCKETS][$i];
            } else {
                $this->[BUCKETS][$i] += $that->[BUCKETS][$i];
            }
        }
        if (defined($that->[BUCKETS_VAL][$i])) {
            if (!defined($this->[BUCKETS_VAL][$i])) {
                $this->[BUCKETS_VAL][$i] = $that->[BUCKETS_VAL][$i];
            } else {
                $this->[BUCKETS_VAL][$i] += $that->[BUCKETS_VAL][$i];
            }
        }
    }

    if (defined($that->[OVER_MAX])) {
        if (defined($this->[OVER_MAX])) {
            $this->[OVER_MAX] += $that->[OVER_MAX];
            $this->[OVER_MAX_BUCKETS_VAL] += $that->[OVER_MAX_BUCKETS_VAL];
        } else {
            $this->[OVER_MAX] = $that->[OVER_MAX];
            $this->[OVER_MAX_BUCKETS_VAL] = $that->[OVER_MAX_BUCKETS_VAL];
        }
    }

    if (defined($that->[UNDER_MIN])) {
        if (defined($this->[UNDER_MIN])) {
            $this->[UNDER_MIN] += $that->[UNDER_MIN];
            $this->[UNDER_MIN_BUCKETS_VAL] += $that->[UNDER_MIN_BUCKETS_VAL];
        } else {
            $this->[UNDER_MIN] = $that->[UNDER_MIN];
            $this->[UNDER_MIN_BUCKETS_VAL] = $that->[UNDER_MIN_BUCKETS_VAL];
        }
    }
}

#
# Fill the histogram from an array.
# if define $index_as_bin, use index in the array to group the value. otherwise
# group the value into bin based on the value its self.
#
# for the third argument,we use array reference to void flat or copy of the content
# since the content may be big.
#
sub from_array($$$) {
    my ($this, $index_as_bin, $array) = @_;

    if ($index_as_bin == 1) {
        for (my $i = 0; $i < scalar(@{$array}); $i++) {
            $this->add($array->[$i],1,$i);
        }
    } else {
        foreach my $e (@{$array}) {
            $this->add($e,1);
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
sub print ($$$$;) {
    my $self = shift;
    my ($fh, $prefix, $unit_str, $unit_str2) = @_;
    my $c = 0;
    my $d = 0;

    my $width;
    my $fmt;

    $unit_str2 = $unit_str if (!defined $unit_str2);

    $width = length sprintf("%d", $self->_get_bucket_max($#{$self->[BUCKETS]}));
    $fmt = "d";

    my  $bwidth = length sprintf("%d", $self->_get_largest_bucket());
    if($bwidth < 5) {
        $bwidth = 5;
    }

    my $bwidth_val = length sprintf("%.2f", $self->[TOTAL_VAL]);


    printf($fh "%scount=%d avg=%.2f %s\n", $prefix,
           $self->[COUNT],
           # $self->[COUNT] > 0 ? $self->[TOTAL_VAL] / $self->[COUNT] : 0,
           do_div($self->[TOTAL_VAL], $self->[COUNT]),
           $unit_str);
    my ($min_val, $max_val);
    $min_val = defined $self->[MIN_VAL] ? $self->[MIN_VAL] : "0";
    $max_val = defined $self->[MAX_VAL] ? $self->[MAX_VAL] : "0";
    printf($fh "%smin=%.2f %s max=%.2f %s\n", $prefix,
           $min_val, $unit_str, $max_val, $unit_str);

    if(defined $self->[UNDER_MIN] &&  $self->[UNDER_MIN] > 0) {
        $c += $self->[UNDER_MIN];
        $d += $self->[UNDER_MIN_BUCKETS_VAL];
        if ($self->[INTEGER_VALS]) {
            printf($fh "%s[%${width}s<%${width}${fmt} %s]: %${bwidth}d (%5.2f%%) (%6.2f%% cumulative) %${bwidth_val}d %s (%5.2f%%) (%6.2f%% cumulative)\n",
               $prefix, " ", $self->[MIN_USE], $unit_str2,
               $c, do_div($c, $self->[COUNT])*100, do_div($c, $self->[COUNT])*100,
               $d, $unit_str, do_div($d, $self->[TOTAL_VAL])*100, do_div($d,$self->[TOTAL_VAL])*100);

        } else {
            printf($fh "%s[%${width}s<%${width}${fmt} %s]: %${bwidth}d (%5.2f%%) (%6.2f%% cumulative) %${bwidth_val}.2f %s (%5.2f%%) (%6.2f%% cumulative)\n",
               $prefix, " ", $self->[MIN_USE], $unit_str2,
               $c, do_div($c, $self->[COUNT])*100, do_div($c, $self->[COUNT])*100,
               $d, $unit_str, do_div($d, $self->[TOTAL_VAL])*100, do_div($d,$self->[TOTAL_VAL])*100);
        }
    }

    for(my $b = 0; $b <= $#{$self->[BUCKETS]}; $b++) {
        if($self->[BUCKETS]->[$b]) {
            my $x = $self->[BUCKETS]->[$b];
            my $y = $self->[BUCKETS_VAL]->[$b];

            $c += $x;
            $d += $y;

            my $pct = do_div($x, $self->[COUNT]) * 100;
            my $cum_pct = do_div($c, $self->[COUNT]) * 100;

            # if all the files parsed are zero bytes, the total_val will be zero but count will be a positive number
            my $y_pct = do_div($y, $self->[TOTAL_VAL]) * 100;
            my $y_cum_pct = do_div($d, $self->[TOTAL_VAL]) * 100;

            if ($self->[INTEGER_VALS]) {
                printf($fh "%s[%${width}${fmt}-%${width}${fmt} %s]: %${bwidth}d (%5.2f%%) (%6.2f%% cumulative) %${bwidth_val}d %s (%5.2f%%) (%6.2f%% cumulative) \n", $prefix,
                       $self->_get_bucket_min($b), $self->_get_bucket_max($b),
                       $unit_str2, $x, $pct, $cum_pct, $y, $unit_str, $y_pct, $y_cum_pct);
            }else {
                printf($fh "%s[%${width}${fmt}-%${width}${fmt} %s]: %${bwidth}d (%5.2f%%) (%6.2f%% cumulative) %${bwidth_val}.2f %s (%5.2f%%) (%6.2f%% cumulative)\n", $prefix,
                       $self->_get_bucket_min($b), $self->_get_bucket_max($b)+1,
                       $unit_str2, $x, $pct, $cum_pct, $y, $unit_str, $y_pct, $y_cum_pct);

            }

            #     $prev_pct = $cum_pct;
        }
    }
    if(defined $self->[OVER_MAX] && $self->[OVER_MAX] > 0) {
        $c += $self->[OVER_MAX];
        $d += $self->[OVER_MAX_BUCKETS_VAL];
        if ($self->[INTEGER_VALS]) {
            printf($fh "%s[%${width}s>%${width}${fmt} %s]: %${bwidth}d (%5.2f%%) (%6.2f%% cumulative) %${bwidth_val}d %s (%5.2f%%) (%6.2f%% cumulative)\n",
               $prefix, " ", $self->[MAX_USE], $unit_str2,
               $self->[OVER_MAX], do_div($self->[OVER_MAX], $self->[COUNT])*100, do_div($c, $self->[COUNT])*100,
               $self->[OVER_MAX_BUCKETS_VAL], $unit_str, do_div($self->[OVER_MAX_BUCKETS_VAL], $self->[TOTAL_VAL])*100, do_div($d, $self->[TOTAL_VAL])*100);

        } else {
            printf($fh "%s[%${width}s>%${width}${fmt} %s]: %${bwidth}d (%5.2f%%) (%6.2f%% cumulative) %${bwidth_val}.2f %s (%5.2f%%) (%6.2f%% cumulative)\n",
               $prefix, " ", $self->[MAX_USE], $unit_str2,
               $self->[OVER_MAX], do_div($self->[OVER_MAX], $self->[COUNT])*100, do_div($c, $self->[COUNT])*100,
               $self->[OVER_MAX_BUCKETS_VAL], $unit_str, do_div($self->[OVER_MAX_BUCKETS_VAL], $self->[TOTAL_VAL])*100, do_div($d, $self->[TOTAL_VAL])*100);

        }
    }
 }

#
# Print histogram contents to a CSV-format file.
#
# @arg  $fh
#   filehandle to print to
# @arg  $name
#   descriptive name of this histogram, to identify it in the file
# @arg  $unit_str
#   string that describes the units of the histogram items
#
sub print_csv {
    my ($self, $fh,$delim) = @_;
    my $c = 0;
    my $d = 0;

    if (defined $self->[UNDER_MIN] && $self->[UNDER_MIN] > 0) {
        $c += $self->[UNDER_MIN];
        $d += $self->[UNDER_MIN_BUCKETS_VAL];
        if ($self->[INTEGER_VALS]) {
            printf($fh "%d$delim%d$delim%d$delim%f$delim%f$delim%d$delim%f$delim%f\n",
                   -1, $self->[MIN_USE], $c, do_div($c, $self->[COUNT]), do_div($c, $self->[COUNT]),
                   $d, do_div($d, $self->[TOTAL_VAL]), do_div($d, $self->[TOTAL_VAL]));
        } else {
            printf($fh "%d$delim%d$delim%d$delim%f$delim%f$delim%f$delim%f$delim%f\n",
                   -1, $self->[MIN_USE], $c, do_div($c, $self->[COUNT]), do_div($c, $self->[COUNT]),
                   $d, do_div($d, $self->[TOTAL_VAL]), do_div($d, $self->[TOTAL_VAL]));
        }
    }

    for (my $b = 0; $b <= $#{$self->[BUCKETS]}; $b++) {
        if (defined $self->[BUCKETS]->[$b] && $self->[BUCKETS]->[$b] != 0) {
            my $x = $self->[BUCKETS]->[$b];
            my $y = $self->[BUCKETS_VAL]->[$b];

            $c += $x;
            $d += $y;

            my $pct = do_div($x, $self->[COUNT]);
            my $cum_pct = do_div($c, $self->[COUNT]);

            # if all the files parsed are zero bytes, the total_val will be zero but count will be a positive number
            my $y_pct = do_div($y, $self->[TOTAL_VAL]);
            my $y_cum_pct = do_div($d, $self->[TOTAL_VAL]);

            if($self->[INTEGER_VALS]) {
                printf($fh "%d$delim%d$delim%d$delim%f$delim%f$delim%d$delim%f$delim%f\n",
                       $self->_get_bucket_min($b), $self->_get_bucket_max($b),
                       $x, $pct, $cum_pct, $y, $y_pct, $y_cum_pct);
            }
            else {
                printf($fh "%d$delim%d$delim%d$delim%f$delim%f$delim%f$delim%f$delim%f\n",
                       $self->_get_bucket_min($b), $self->_get_bucket_max($b)+1,
                       $x, $pct, $cum_pct, $y, $y_pct, $y_cum_pct);
            }
        }
    }

    if (defined $self->[OVER_MAX] && $self->[OVER_MAX] > 0) {
        $c += $self->[OVER_MAX];
        $d += $self->[OVER_MAX_BUCKETS_VAL];
        if ($self->[INTEGER_VALS]) {
            printf($fh "%d$delim%d$delim%d$delim%f$delim%f$delim%d$delim%f$delim%f\n",
               $self->[MAX_USE], -1, $self->[OVER_MAX], do_div($self->[OVER_MAX], $self->[COUNT]), do_div($c, $self->[COUNT]),
               $self->[OVER_MAX_BUCKETS_VAL],  do_div($self->[OVER_MAX_BUCKETS_VAL], $self->[TOTAL_VAL]), do_div($d, $self->[TOTAL_VAL]));
        } else {
            printf($fh "%d$delim%d$delim%d$delim%f$delim%f$delim%f$delim%f$delim%f\n",
               $self->[MAX_USE], -1, $self->[OVER_MAX], do_div($self->[OVER_MAX], $self->[COUNT]), do_div($c, $self->[COUNT]),
               $self->[OVER_MAX_BUCKETS_VAL],  do_div($self->[OVER_MAX_BUCKETS_VAL], $self->[TOTAL_VAL]), do_div($d, $self->[TOTAL_VAL]));
        }
    }
    print $fh "\n";
}

#
# Print histogram contents to a CSV-format file.
#
# @arg  $fh
#   filehandle to print to
# @arg  $name
#   descriptive name of this histogram, to identify it in the file
# @arg  $unit_str
#   string that describes the units of the histogram items
#
sub print_csv_head {
    my $self = shift;
    my ($fh, $name, $unit_str) = @_;
    my $c = 0;
    my $d = 0;


    printf($fh "histogram,%s\n", $name);
    printf($fh "count,%d,items\n",
           $self->[COUNT]);
    printf($fh "average,%f,%s\n",
           #$self->[COUNT] > 0 ? $self->[TOTAL_VAL] / $self->[COUNT] : 0,
           do_div($self->[TOTAL_VAL], $self->[COUNT]),
           $unit_str);
    my ($min_val, $max_val);
    $min_val = defined $self->[MIN_VAL] ? $self->[MIN_VAL] : "0";
    $max_val = defined $self->[MAX_VAL] ? $self->[MAX_VAL] : "0";
    printf($fh "min,%d,%s\n", $min_val, $unit_str);
    printf($fh "max,%d,%s\n", $max_val, $unit_str);
    print $fh "bucket min,bucket max,count,percent,cumulative pct,val count,percent,cumulative pct\n";

}




1;
