package WHATWG::URL::URLSearchParams;

use v5.22;
use strict;
use warnings;

=head1 NAME

WHATWG::URL::URLSearchParams - The URLSearchParams class from the WHATWG URL standard

=cut

our $VERSION = '0.1.0-20170604';

use fields qw(_list _url_object);

sub new {
	my ($class, $init) = @_;

	my $query = fields::new($class);

	if (ref($init) eq 'ARRAY') {
		# TODO
	}
	elsif (ref($init) eq 'HASH') {
		# TODO
	}
	else {
		# TODO
	}

	return $query;
}

=head1 LICENSE

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at L<http://mozilla.org/MPL/2.0/>.

=cut

1;
