#! /depot/perl-5.14.2/bin/perl
## Copyright (C) 2013 by Yours Truly
use 5.014;
use warnings;
use strict;

my $star_input = $ARGV[0];
my @star_list = split (/\s+|,/, $star_input);


print $star_list[0];
