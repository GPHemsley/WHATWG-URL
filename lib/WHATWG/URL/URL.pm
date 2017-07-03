package WHATWG::URL::URL;

use v5.22;
use strict;
use warnings;

=head1 NAME

WHATWG::URL::URL - The URL class from the WHATWG URL standard

=cut

our $VERSION = '0.1.0-20170702';

use WHATWG::URL;
use WHATWG::URL::URLSearchParams;

# XXX
use Data::Dumper;

use feature 'refaliasing';
use experimental 'refaliasing';
use feature 'postderef';
use experimental 'postderef';

use fields qw(url query_object);

use overload (
	q{""} => \&href,
);

# # For Perl compatibility only.
# sub new {
# 	goto &URL;
# }

# # LegacyWindowAlias
# sub webkitURL {
# 	goto &URL;
# }

# sub URL {
sub new {
	my ($class, $url, $base) = @_;

	my $parsed_base;

	if (defined $base) {
		$parsed_base = WHATWG::URL->basic_url_parse($base);

		# XXX
		print Dumper($base, $parsed_base);

		unless (defined $parsed_base) {
			die 'TypeError'; # TODO: Throw exception
		}
	}

	my $parsed_url = WHATWG::URL->basic_url_parse($url, $parsed_base);

	unless (defined $parsed_url) {
		die 'TypeError'; # TODO: Throw exception
	}

	my $query = (defined $parsed_url->{'query'}) ? $parsed_url->{'query'} : '';

	my $result = fields::new($class);

	$result->{'url'} = $parsed_url;

	$result->{'query_object'} = WHATWG::URL::URLSearchParams->new($query);

	$result->{'query_object'}->{'url_object'} = $result;

	return $result;
}

sub href {
	my $self = shift;
	my $value = shift;

	if (defined $value) {
		my $parsed_url = WHATWG::URL->basic_url_parse($value);

		unless (defined $parsed_url) {
			die 'TypeError'; # TODO: Throw exception
		}

		$self->{'url'} = $parsed_url;

		$self->{'query_object'}->{'list'} = [];

		my $query = $self->{'url'}->{'query'};

		if (defined $query) {
			$self->{'query_object'}->{'list'} = WHATWG::URL::urlencoded_string_parse($query);
		}
	}

	return $self->{'url'}->serialize();
}

sub origin {
	my $self = shift;

	# TODO
}

sub protocol {
	my $self = shift;
	my $value = shift;

	if (defined $value) {
		WHATWG::URL->basic_url_parse("$value\N{U+003A}", undef, undef, $self->{'url'}, 'scheme start state');
	}

	return $self->{'url'}->{'scheme'} . "\N{U+003A}";
}

sub username {
	my $self = shift;
	my $value = shift;

	if (defined $value) {
		if ($self->{'url'}->cannot_have_username_password_port) {
			return;
		}

		$self->{'url'}->set_username($value);
	}

	return $self->{'url'}->{'username'};
}

sub password {
	my $self = shift;
	my $value = shift;

	if (defined $value) {
		if ($self->{'url'}->cannot_have_username_password_port) {
			return;
		}

		$self->{'url'}->set_password($value);
	}

	return $self->{'url'}->{'password'};
}

sub host {
	my $self = shift;
	my $value = shift;

	if (defined $value) {
		if ($self->{'url'}->{'cannot_be_a_base_url_flag'}) {
			return;
		}

		WHATWG::URL->basic_url_parse($value, undef, undef, $self->{'url'}, 'host state');
	}

	my $url = $self->{'url'};

	unless (defined $url->{'host'}) {
		return '';
	}

	unless (defined $url->{'port'}) {
		return WHATWG::URL::host_serialize($url->{'host'});
	}

	return WHATWG::URL::host_serialize($self->{'url'}->{'host'}) . "\N{U+003A}" . WHATWG::URL::integer_serialize($url->{'port'});
}

sub hostname {
	my $self = shift;
	my $value = shift;

	if (defined $value) {
		if ($self->{'url'}->{'cannot_be_a_base_url_flag'}) {
			return;
		}

		WHATWG::URL->basic_url_parse($value, undef, undef, $self->{'url'}, 'hostname state');
	}

	unless (defined $self->{'url'}->{'host'}) {
		return '';
	}

	print Dumper($self->{'url'}->{'host'}, WHATWG::URL::host_serialize($self->{'url'}->{'host'}));

	return WHATWG::URL::host_serialize($self->{'url'}->{'host'});
}

sub port {
	my $self = shift;
	my $value = shift;

	if (defined $value) {
		if ($self->{'url'}->cannot_have_username_password_port) {
			return;
		}

		if ($value eq '') {
			$self->{'url'}->{'port'} = undef;
		}
		else {
			WHATWG::URL->basic_url_parse($value, undef, undef, $self->{'url'}, 'port state');
		}
	}

	unless (defined $self->{'url'}->{'port'}) {
		return '';
	}

	return WHATWG::URL::integer_serialize($self->{'url'}->{'port'});
}

sub pathname {
	my $self = shift;
	my $value = shift;

	if (defined $value) {
		if ($self->{'url'}->{'cannot_be_a_base_url_flag'}) {
			return;
		}

		$self->{'url'}->{'path'} = [];

		WHATWG::URL->basic_url_parse($value, undef, undef, $self->{'url'}, 'path start state');
	}

	if ($self->{'url'}->{'cannot_be_a_base_url_flag'}) {
		return $self->{'url'}->{'path'}->[0];
	}

	unless ($self->{'url'}->{'path'}->@*) {
		return '';
	}

	return "\N{U+002F}" . join("\N{U+002F}", $self->{'url'}->{'path'}->@*);
}

sub search {
	my $self = shift;
	my $value = shift;

	if (defined $value) {
		\my $url = $self->{'url'};

		if ($value eq '') {
			$url->{'query'} = undef;
			$self->{'query_object'}->{'list'} = [];
			return;
		}

		my $input = ($value =~ s/^\N{U+003F}//r);  #/

		$url->{'query'} = '';

		WHATWG::URL->basic_url_parse($value, undef, undef, $url, 'query state');

		$self->{'query_object'}->{'list'} = WHATWG::URL::urlencoded_string_parse($input);
	}

	if (!defined $self->{'url'}->{'query'} || $self->{'url'}->{'query'} eq '') {
		return '';
	}

	return "\N{U+003F}" . $self->{'url'}->{'query'};
}

sub searchParams {
	my $self = shift;

	return $self->{'query_object'};
}

sub hash {
	my $self = shift;
	my $value = shift;

	if (defined $value) {
		if ($value eq '') {
			$self->{'url'}->{'fragment'} = undef;
			return;
		}

		my $input = ($value =~ s/^\N{U+0023}//r);  #/

		$self->{'url'}->{'fragment'} = '';

		WHATWG::URL->basic_url_parse($value, undef, undef, $self->{'url'}, 'fragment state');
	}

	if (!defined $self->{'url'}->{'fragment'} || $self->{'url'}->{'fragment'} eq '') {
		return '';
	}

	return "\N{U+0023}" . $self->{'url'}->{'fragment'};
}

sub toJSON {
	my ($self) = @_;

	return $self->{'url'}->serialize();
}

=head1 LICENSE

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at L<http://mozilla.org/MPL/2.0/>.

=cut

1;
