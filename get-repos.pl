#!/usr/bin/env perl

use strict;
use warnings;
use v5.14;

use File::Slurp::Tiny qw(read_lines);
use Net::GitHub;

my $gh = Net::GitHub->new(
        access_token => $ENV{'GH_TOKEN'} # from above
			     );

my $place = shift || "Almería";
my $dir = shift || "../top-github-users-data/data";

my @data = read_lines( "$dir/user-data-$place.csv" );

die "No data" if !@data;

shift @data;
my $repos = $gh->repos;
my %all_repos;
for my $d (@data ) {
  my ($username,@foo) = split(/;\s*/,$d);
  my @repos =$repos->list_user($username);
  while ( $repos->has_next_page ) {
    push @repos, $repos->next_page;
  }
  for my $r ( @repos ) {
    if ( !$r->{'fork'} & !$all_repos{$r->{'name'}}) {
      $repos->set_default_user_repo( $username, $r->{'name'});
      my @contributors;
      if ( ref $repos->contributors eq 'ARRAY' ) {
	@contributors =  map( $_->{'login'}, @{$repos->contributors});
      } else {
	push @contributors, $username;
      }
      $all_repos{$r->{'name'}} = \@contributors;
    }
  }
}

#Download collaborators
my %relations;
for my $r (keys %all_repos ) {
  my @collaborators =  @{$all_repos{$r}} ;
  for ( my $i = 0; $i < $#collaborators; $i++ ) {
    for (my $j = $i+1; $j <= $#collaborators; $j ++ ) {
      $relations{"$collaborators[$i];$collaborators[$j]"}++;
    }
  }
}

for my $i ( sort { $relations{$a} <=> $relations{$b} } keys %relations ) {
  for ( my $j = 0; $j < $relations{$i};$j ++ ) {
    say $i;
  }
}    