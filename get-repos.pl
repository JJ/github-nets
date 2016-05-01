#!/usr/bin/env perl

use strict;
use warnings;
use v5.14;

use File::Slurp::Tiny qw(read_lines);
use Net::GitHub;

my $gh = Net::GitHub->new(
        access_token => $ENV{'GH_TOKEN'} # from above
			     );

my $place = shift || "Granada";
my $dir = shift || "../top-github-users-data/data";

my @data = read_lines( "$dir/user-data-$place.csv" );

die "No data" if !@data;

shift @data;
for my $d (@data ) {
  my ($username,@foo) = split(/;\s*/,$d);
  my @repos =$gh->repos->list_user($username);
}
