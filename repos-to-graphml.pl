#!/usr/bin/env perl

use strict;
use warnings;
use v5.14;

use File::Slurp::Tiny qw(read_lines);
use Net::GitHub;
use Graph::Easy;

my $gh = Net::GitHub->new(
        access_token => $ENV{'GH_TOKEN'} # from above
			     );

my $place = shift || "Huelva";
my $dir = shift || "../top-github-users-data/data";

my @data = read_lines( "$dir/user-data-$place.csv" );

die "No data" if !@data;

shift @data;
my $repos = $gh->repos;
my %all_repos;
my $graph = Graph::Easy->new();
for my $d (@data ) {
  my ($username,@foo) = split(/;\s*/,$d);
  my $this_node = $graph->add_node($username);
  $this_node->set_attributes( {
			       label=> $username,
			       border => 'solid 2px green',
			       color => 'red'
			      });
      
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
for my $r (keys %all_repos ) {
  my @collaborators =  @{$all_repos{$r}} ;
  for ( my $i = 0; $i < $#collaborators; $i++ ) {
    for (my $j = $i+1; $j <= $#collaborators; $j ++ ) {
	$graph->add_edge($collaborators[$i],$collaborators[$j]);
    }
  }
}

say $graph->as_graphml();
