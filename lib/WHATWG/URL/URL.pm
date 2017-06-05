package WHATWG::URL::URL;

use v5.22;
use strict;
use warnings;

=head1 NAME

WHATWG::URL::URL - The URL class from the WHATWG URL standard

=cut

our $VERSION = '0.1.0-20170604';

use WHATWG::URL;
use WHATWG::URL::URLSearchParams;

use fields qw(_url _query_object href origin protocol username password host hostname port pathname search search_params hash);

sub new {
	my ($class, $url, $base) = @_;

	my $parsed_base;

	if (defined $base) {
		$parsed_base = WHATWG::URL::URL->basic_url_parse($base);

		unless (defined $parsed_base) {
			die 'TypeError'; # TODO: Throw exception
		}
	}

	my $parsed_url = WHATWG::URL::URL->basic_url_parse($url, $parsed_base);

	unless (defined $parsed_url) {
		die 'TypeError'; # TODO: Throw exception
	}

	my $query = (defined $parsed_url->query) ? $parsed_url->query : '';

	my $result = fields::new($class);

	$result->{'_url'} = $parsed_url;

	$result->{'_query_object'} = WHATWG::URL::URLSearchParams->new($query);

	$result->{'_query_object'}->{'_url_object'} = $result;

	return $result;
}



=head1 LICENSE

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at L<http://mozilla.org/MPL/2.0/>.

=cut

1;
