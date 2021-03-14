package WHATWG::URL::Util::Pointer;

use v5.22;
use strict;
use warnings;

=head1 NAME

WHATWG::URL - Implementation of a string pointer from the WHATWG URL standard

=cut

# First part is date of this code; second part is date of spec.
# Third part, if present, is iteration.
use version 0.9915; our $VERSION = version->declare('v0.21.03.14.20.05.05');

use fields qw(string pointer);

sub new {
	my ($class, $string, $pointer) = @_;

	my $self = fields::new($class);

	unless (defined $pointer) {
		$pointer = 0;
	}

	$self->{'string'} = $string;
	$self->{'pointer'} = $pointer;

	return $self;
}

sub pointer {
	my $self = shift;

	return $self->{'pointer'};
}

sub is_eof {
	my $self = shift;

	return ($self->pointer >= length($self->{'string'}));
}

sub c {
	my $self = shift;

	my $pointer = $self->pointer;

	if ($pointer < 0) {
		return undef;
	}

	my $string_length = length($self->{'string'});

	if ($pointer > $string_length) {
		$pointer = $string_length;
	}

	return substr($self->{'string'}, $pointer, 1);
}

sub remaining {
	my $self = shift;

	if (!defined $self->c || $self->is_eof) {
		return undef;
	}

	return substr($self->{'string'}, $self->pointer + 1);
}

sub set {
	my ($self, $value) = @_;

	$self->{'pointer'} = $value;
}

sub incr {
	my ($self, $value) = @_;

	$self->set($self->pointer + $value);
}

sub decr {
	my ($self, $value) = @_;

	$self->set($self->pointer - $value);
}

sub reset {
	my ($self) = @_;

	$self->set(0);
}
