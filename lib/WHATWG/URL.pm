package WHATWG::URL;

use v5.22;
use strict;
# use warnings;

=head1 NAME

WHATWG::URL - Primary functionality from the WHATWG URL standard

=cut

our $VERSION = '0.1.0-20171216';

use List::Util ();
use Encode ();
use POSIX;
use Net::IDN::UTS46;
use WHATWG::Infra;

use WHATWG::URL::Util::Pointer;
use WHATWG::URL::URL;
use WHATWG::URL::URLSearchParams;

# XXX
use Data::Dumper;

use feature 'switch';
use experimental 'switch';
use feature 'refaliasing';
use experimental 'refaliasing';
use feature 'postderef';
use experimental 'postderef';

use fields qw(scheme username password host port path query fragment cannot_be_a_base_url_flag object);

#
# 1. Infrastructure
#

sub integer_serialize {
	my ($integer) = @_;

	return int($integer);
}

#
# 1.3. Percent-encoded bytes
#

sub percent_encode {
	my ($byte) = @_;

	return sprintf('%%%02X', $byte);
}

sub percent_decode {
	my ($input) = @_;

	my $output = '';

	for (my $i = 0, my $j = 0; $i < length($input); $i++, $j++) {
		my $byte = vec($input, $i, 8);

		if ($byte ne 0x25) {
			vec($output, $j, 8) .= $byte;
		}
		elsif ($byte eq 0x25 && List::Util::notall { $_ ~~ [ 0x30..0x39, 0x41..0x46, 0x61..0x66 ] } ( vec($input, $i + 1, 8), vec($input, $i + 2, 8) )) {
			vec($output, $j, 8) .= $byte;
		}
		else {
			my $byte_point = hex(join('', map { Encode::decode('UTF-8', pack('C*', $_)) } ( vec($input, $i + 1, 8), vec($input, $i + 2, 8) )));  # TODO: decoded

			vec($output, $j, 8) .= $byte_point;

			$i += 2;
		}
	}

	return $output;
}

our $c0_control_percent_encode_set = q/\N{U+0000}-\N{U+001F}\N{U+007F}-\N{U+FFFFFF}/;

our $fragment_percent_encode_set = $c0_control_percent_encode_set . q/\N{U+0020}\N{U+0022}\N{U+003C}\N{U+003E}\N{U+0060}/;

our $path_percent_encode_set = $fragment_percent_encode_set . q/\N{U+0023}\N{U+003F}\N{U+007B}\N{U+007D}/;

our $userinfo_percent_encode_set = $path_percent_encode_set . q/\N{U+002F}\N{U+003A}\N{U+003B}\N{U+003D}\N{U+0040}\N{U+005B}\N{U+005C}\N{U+005D}\N{U+005E}\N{U+007C}/;

sub utf8_percent_encode {
	my ($code_point, $percent_encode_set) = @_;

	if ($code_point !~ m/^[${percent_encode_set}]$/) {
		return $code_point;
	}

	my $bytes = Encode::encode('UTF-8', $code_point);  # TODO: UTF-8 encode

	my $results = '';
	for (my $i = 0, my $j = 0; $i < length($bytes); $i++, $j++) {
		my $byte = vec($bytes, $i, 8);

		$results .= percent_encode($byte);
	}

	return $results;
}

#
# 3.3. IDNA
#

sub domain_to_ascii {
	my ($domain) = @_;

	# XXX: Net::IDN::UTS46 does not currently support the VerifyDnsLength, so we have to prevent it from croaking.
	my $result;
	{
		# no warnings 'redefine';
		# local *Net::IDN::UTS46::croak = \&Net::IDN::UTS46::carp;
		eval {
			$result = Net::IDN::UTS46::to_ascii($domain, ( 'UseSTD3ASCIIRules' => 0, 'TransitionalProcessing' => 0, 'VerifyDnsLength' => 0 ));
		};
		if ($@) {
			# XXX
			print Dumper($@);
		}

		# XXX: Look into why Net::IDN::UTS46 removes empty sections.
		# if ($result eq '') {
		# 	$result = $domain;
		# }
	}

	# XXX
	if (!defined $result || $domain ne $result) {
		print Dumper($domain, $result);
	}

	unless (defined $result) {
		warn 'validation error';
		return undef;
	}

	return $result;
}

#
# 3.5. Host parsing
#

sub host_parse {
	my ($input, $is_special) = @_;

	if ($input =~ m/^\N{U+005B}/) {
		if ($input !~ m/\N{U+005D}$/) {
			warn 'validation error';
			return undef;
		}

		return ipv6_parse(substr($input, 1, -1));
	}

	unless ($is_special) {
		return opaque_host_parse($input);
	}

	my $domain = Encode::decode('UTF-8', percent_decode(Encode::encode('UTF-8', $input)));  # TODO: UTF-8 decode without BOM; UTF-8 encode

	my $ascii_domain = domain_to_ascii($domain);

	unless (defined $ascii_domain) {
		warn 'validation error';
		return undef;
	}

	if ($ascii_domain =~ m/[\N{U+0000}\N{U+0009}\N{U+000A}\N{U+000D}\N{U+0020}\N{U+0023}\N{U+0025}\N{U+002F}\N{U+003A}\N{U+003F}\N{U+0040}\N{U+005B}\N{U+005C}\N{U+005D}]/) {
		warn 'validation error';
		return undef;
	}

	my $ipv4_host = ipv4_parse($ascii_domain);

	# XXX: Make sure this is the right way to identify an IPv4 address.
	{
		no warnings 'numeric';
		if (!defined $ipv4_host || (0 <= $ipv4_host && $ipv4_host < 2**32)) {
			return $ipv4_host;
		}
	}

	return $ascii_domain;
}

sub ipv4_number_parse {
	my ($input, $validation_error_flag) = @_;

	my $R = 10;

	if (length($input) >= 2 && $input =~ m/^(0x|0X)/) {
		$$validation_error_flag = 1;

		$input = substr($input, 2);

		$R = 16;
	}
	elsif (length($input) >= 2 && $input =~ m/^\N{U+0030}/) {
		$$validation_error_flag = 1;

		$input = substr($input, 1);

		$R = 8;
	}

	if ($input eq '') {
		return 0;
	}

	# XXX: This behavior isn't well-defined in the spec.
	if (($R == 10 && $input =~ m/[^0-9]/) || ($R == 16 && $input =~ m/[^0-9A-Fa-f]/) || ($R == 8 && $input =~ m/[^0-7]/)) {
		return undef;
	}

	# XXX: This behavior isn't well-defined in the spec.
	if ($R == 16) {
		return hex($input);
	}
	elsif ($R == 8) {
		return oct($input);
	}
	else {
		return int($input);
	}
}

sub ipv4_parse {
	my ($input) = @_;

	my $validation_error_flag = 0;

	# XXX: This behavior isn't well-defined in the spec.
	my @parts = split(/\N{U+002E}/, $input, -1);
	# NOTE: This is required because Perl discards failed matches.
	unless (@parts) {
		@parts = ( $input );
	}

	if ($parts[-1] eq '') {
		$validation_error_flag = 1;

		if (scalar(@parts) > 1) {
			pop @parts;
		}
	}

	if (scalar(@parts) > 4) {
		return $input;
	}

	my @numbers;

	foreach my $part (@parts) {
		if ($part eq '') {
			return $input;
		}

		my $n = ipv4_number_parse($part, \$validation_error_flag);

		unless (defined $n) {
			return $input;
		}

		push @numbers, $n;
	}

	if ($validation_error_flag) {
		warn 'validation error';
	}

	if (grep { $_ > 255 } @numbers) {
		warn 'validation error';
	}

	if (grep { $_ > 255 } @numbers[0 .. $#numbers - 1]) {
		return undef;
	}

	if ($numbers[-1] >= 256**(5 - scalar(@numbers))) {
		warn 'validation error';
		return undef;
	}

	my $ipv4 = $numbers[-1];

	pop @numbers;

	my $counter = 0;

	foreach my $n (@numbers) {
		$ipv4 += $n * 256**(3 - $counter);

		$counter++;
	}

	return $ipv4;
}

sub ipv6_parse {
	my ($input) = @_;

	my $address = [ 0, 0, 0, 0, 0, 0, 0, 0 ];

	my $piece_index = 0;

	my $compress;

	my $pointer = WHATWG::URL::Util::Pointer->new($input, 0);

	if ($pointer->c eq "\N{U+003A}")
	{
		if ($pointer->remaining !~ m/^\N{U+003A}/) {
			warn 'validation error';
			return undef;
		}

		$pointer->incr(2);

		$piece_index++;
		$compress = $piece_index;
	}

	while (!$pointer->is_eof) {
		if ($piece_index == 8) {
			warn 'validation error';
			return undef;
		}

		if ($pointer->c eq "\N{U+003A}") {
			if (defined $compress) {
				warn 'validation error';
				return undef;
			}

			$pointer->incr(1);
			$piece_index++;
			$compress = $piece_index;
			next;
		}

		my $value = 0;
		my $length = 0;

		while ($length < 4 && $pointer->c =~ m/^[\N{U+0030}-\N{U+0039}\N{U+0041}-\N{U+0046}\N{U+0061}-\N{U+0066}]$/) {
			$value = $value * 0x10 + hex($pointer->c);
			$pointer->incr(1);
			$length++;
		}

		if ($pointer->c eq "\N{U+002E}") {
			if ($length == 0) {
				warn 'validation error';
				return undef;
			}

			$pointer->decr($length);

			if ($piece_index > 6) {
				warn 'validation error';
				return undef;
			}

			my $numbers_seen = 0;

			while (!$pointer->is_eof) {
				my $ipv4_piece;

				if ($numbers_seen > 0) {
					if ($pointer->c eq "\N{U+002E}" && $numbers_seen < 4) {
						$pointer->incr(1);
					}
					else {
						warn 'validation error';
						return undef;
					}
				}

				if ($pointer->c !~ m/^[\N{U+0030}-\N{U+0039}]$/) {
					warn 'validation error';
					return undef;
				}

				while ($pointer->c =~ m/^[\N{U+0030}-\N{U+0039}]$/) {
					my $number = int($pointer->c);

					if (!defined $ipv4_piece) {
						$ipv4_piece = $number;
					}
					elsif ($ipv4_piece == 0) {
						warn 'validation error';
						return undef;
					}
					else {
						$ipv4_piece = $ipv4_piece * 10 + $number;
					}

					if ($ipv4_piece > 255) {
						warn 'validation error';
						return undef;
					}

					$pointer->incr(1);
				}

				$address->[$piece_index] = $address->[$piece_index] * 0x100 + $ipv4_piece;

				$numbers_seen++;

				if ($numbers_seen ~~ [ 2, 4 ]) {
					$piece_index++;
				}
			}

			if ($numbers_seen != 4) {
				warn 'validation error';
				return undef;
			}

			last;
		}
		elsif ($pointer->c eq "\N{U+003A}") {
			$pointer->incr(1);

			if ($pointer->is_eof) {
				warn 'validation error';
				return undef;
			}
		}
		elsif (!$pointer->is_eof) {
			warn 'validation error';
			return undef;
		}

		$address->[$piece_index] = $value;

		$piece_index++;
	}

	if (defined $compress) {
		my $swaps = $piece_index - $compress;

		$piece_index = 7;

		while ($piece_index != 0 && $swaps > 0) {
			($address->[$piece_index], $address->[$compress + $swaps - 1]) = ($address->[$compress + $swaps - 1], $address->[$piece_index]);
			$piece_index--;
			$swaps--;
		}
	}
	elsif (!defined $compress && $piece_index != 8) {
		warn 'validation error';
		return undef;
	}

	return $address;
}

sub opaque_host_parse {
	my ($input) = @_;

	if ($input =~ m/[\N{U+0000}\N{U+0009}\N{U+000A}\N{U+000D}\N{U+0020}\N{U+0023}\N{U+002F}\N{U+003A}\N{U+003F}\N{U+0040}\N{U+005B}\N{U+005C}\N{U+005D}]/) {
		warn 'validation error';
		return undef;
	}

	my $output = '';

	foreach my $code_point (split(m//, $input)) {
		$output .= utf8_percent_encode($code_point, $c0_control_percent_encode_set);
	}

	return $output;
}

#
# 3.6. Host serializing
#

sub host_serialize {
	my ($host) = @_;

	# XXX: Make sure this is the right way to identify an IPv4 address.
	if ($host ne '' && int($host) eq $host) {
		return ipv4_serialize($host);
	}
	# XXX: Make sure this is the right way to identify an IPv6 address.
	elsif (ref $host eq 'ARRAY') {
		return "\N{U+005B}" . ipv6_serialize($host) . "\N{U+005D}";
	}
	else {
		return $host;
	}
}

sub ipv4_serialize {
	my ($address) = @_;

	my $output = '';

	my $n = int($address);

	foreach my $i (1..4) {
		$output = integer_serialize($n % 256) . $output;

		if ($i != 4) {
			$output = "\N{U+002E}" . $output;
		}

		$n = floor($n / 256);
	}

	return $output;
}

sub ipv6_serialize {
	my ($address) = @_;

	my $output = '';

	# XXX: This behavior isn't well-defined in the spec.
	my $compress;
	my $z_count = 0;
	for (my $i = 0, my $z, my $seen_zero = 0; $i < scalar($address->@*); $i++) {
		if ($address->[$i] == 0) {
			unless ($seen_zero) {
				$z = $i;
			}

			$seen_zero++;

			if ($seen_zero > $z_count) {
				$compress = $z;
				$z_count = $seen_zero;
			}
		}
		else {
			$seen_zero = 0;
		}
	}

	if ($z_count <= 1) {
		undef $compress;
	}

	my $ignore_0 = 0;

	foreach my $piece_index (0..7) {
		if ($ignore_0 && $address->[$piece_index] == 0) {
			next;
		}
		elsif ($ignore_0) {
			$ignore_0 = 0;
		}

		if (defined $compress && $compress == $piece_index) {
			my $separator = ($piece_index == 0) ? '::' : "\N{U+003A}";

			$output .= $separator;

			$ignore_0 = 1;
			next;
		}

		$output .= sprintf('%x', $address->[$piece_index]);

		if ($piece_index != 7) {
			$output .= "\N{U+003A}";
		}
	}

	return $output;
}

#
# 4.1. URL representation
#

sub new {
	my ($class) = @_;

	my $URL = fields::new($class);

	$URL->{'scheme'} = '';
	$URL->{'username'} = '';
	$URL->{'password'} = '';
	$URL->{'host'} = undef;
	$URL->{'port'} = undef;
	$URL->{'path'} = [];
	$URL->{'query'} = undef;
	$URL->{'fragment'} = undef;
	$URL->{'cannot_be_a_base_url_flag'} = 0;
	$URL->{'object'} = undef;

	return $URL;
}

#
# 4.2. URL miscellaneous
#

our $special_schemes = {
	'ftp' => 21,
	'file' => undef,
	'gopher' => 70,
	'http' => 80,
	'https' => 443,
	'ws' => 80,
	'wss' => 443,
};

sub is_special {
	my $self = shift;

	return (exists $special_schemes->{$self->{'scheme'}});
}

sub includes_credentials {
	my $self = shift;

	return ($self->{'username'} ne '' || $self->{'password'} ne '');
}

sub cannot_have_username_password_port {
	my $self = shift;

	return ((!defined $self->{'host'} || $self->{'host'} eq '') || ($self->{'cannot_be_a_base_url_flag'}) || ($self->{'scheme'} eq 'file'));
}

# TODO: Use Infra.
our $windows_drive_letter = q/[\N{U+0041}-\N{U+005A}\N{U+0061}-\N{U+007A}]/ . q/[\N{U+003A}\N{U+007C}]/;

# TODO: Use Infra.
our $normalized_windows_drive_letter = q/[\N{U+0041}-\N{U+005A}\N{U+0061}-\N{U+007A}]/ . q/\N{U+003A}/;

sub starts_with_a_windows_drive_letter {
	my ($string) = @_;

	return ((length($string) >= 2) && (substr($string, 0, 2) =~ m/^$windows_drive_letter$/) && ((length($string) == 2) || (substr($string, 2, 1) =~ m/^[\N{U+002F}\N{U+005C}\N{U+003F}\N{U+0023}]$/)));
}

sub shorten_path {
	my ($self) = @_;

	\my @path = $self->{'path'};

	unless (@path) {
		return;
	}

	if ($self->{'scheme'} eq 'file' && scalar(@path) == 1 && $path[0] =~ m/^$normalized_windows_drive_letter$/) {
		return;
	}

	pop @path;
}

#
# 4.4. URL parsing
#

sub basic_url_parse {
	my ($class, $input, $base, $encoding_override, $url, $state_override) = @_;

	# XXX
	# print Dumper($input, $base);

	unless (defined $url) {
		$url = $class->new();

		if ($input =~ m/^[\N{U+0000}-\N{U+001F}\N{U+0020}]+|[\N{U+0000}-\N{U+001F}\N{U+0020}]+$/) {
			warn 'validation error';
		}

		$input =~ s/^[\N{U+0000}-\N{U+001F}\N{U+0020}]+|[\N{U+0000}-\N{U+001F}\N{U+0020}]+$//g;
	}

	if ($input =~ m/[\N{U+0009}\N{U+000A}\N{U+000D}]/) {
		warn 'validation error';
	}

	$input =~ s/[\N{U+0009}\N{U+000A}\N{U+000D}]//g;

	my $state = (defined $state_override) ? $state_override : 'scheme start state';

	my $encoding = 'UTF-8';

	if (defined $encoding_override) {
		$encoding = ($encoding_override ~~ [ 'replacement', 'UTF-16BE', 'UTF-16LE' ]) ? 'UTF-8' : $encoding_override;
	}

	my $buffer = '';

	my $at_sign_flag = 0;
	my $square_brackets_flag = 0;
	my $password_token_seen_flag = 0;

	my $pointer = WHATWG::URL::Util::Pointer->new($input, 0);

	while (1) {
		# XXX
		# {
		# 	no warnings 'uninitialized';
		# 	print "$state\n";
		# 	print "${\$pointer->c}\t$buffer\n";
		# }

		given ($state) {
			when ('scheme start state') {
				if ($pointer->c =~ m/^[\N{U+0041}-\N{U+005A}\N{U+0061}-\N{U+007A}]$/) {
					$buffer .= WHATWG::Infra::ascii_lowercase($pointer->c);
					$state = 'scheme state';
				}
				elsif (!defined $state_override) {
					$state = 'no scheme state';
					$pointer->decr(1);
				}
				else {
					warn 'validation error';
					return undef;
				}
			}
			when ('scheme state') {
				if ($pointer->c =~ m/^[\N{U+0030}-\N{U+0039}\N{U+0041}-\N{U+005A}\N{U+0061}-\N{U+007A}\N{U+002B}\N{U+002D}\N{U+002E}]$/) {
					$buffer .= WHATWG::Infra::ascii_lowercase($pointer->c);
				}
				elsif ($pointer->c eq "\N{U+003A}") {
					if (defined $state_override) {
						if ($url->is_special && !exists $special_schemes->{$buffer}) {
							return;
						}
						elsif (!$url->is_special && exists $special_schemes->{$buffer}) {
							return;
						}
						elsif (($url->includes_credentials || defined $url->{'port'}) && $buffer eq 'file') {
							return;
						}
						elsif ($url->{'scheme'} eq 'file' && ($url->{'host'} eq '' || !defined $url->{'host'})) {
							return;
						}
					}

					$url->{'scheme'} = $buffer;

					if (defined $state_override) {
						if ($url->{'port'} eq $special_schemes->{$url->{'scheme'}}) {
							$url->{'port'} = undef;
						}

						return;
					}

					$buffer = '';

					if ($url->{'scheme'} eq 'file') {
						if ($pointer->remaining !~ m'^//') {
							warn 'validation error';
						}

						$state = 'file state';
					}
					elsif ($url->is_special && defined $base && $base->{'scheme'} eq $url->{'scheme'}) {
						$state = 'special relative or authority state';
					}
					elsif ($url->is_special) {
						$state = 'special authority slashes state';
					}
					elsif ($pointer->remaining =~ m'^\N{U+002F}') {
						$state = 'path or authority state';
						$pointer->incr(1);
					}
					else {
						$url->{'cannot_be_a_base_url_flag'} = 1;
						push $url->{'path'}->@*, '';
						$state = 'cannot-be-a-base-URL path state';
					}
				}
				elsif (!defined $state_override) {
					$buffer = '';
					$state = 'no scheme state';
					$pointer->reset();
					next;
				}
				else {
					warn 'validation error';
					return undef;
				}
			}
			when ('no scheme state') {
				if (!defined $base || ($base->{'cannot_be_a_base_url_flag'} && $pointer->c ne "\N{U+0023}")) {
					warn 'validation error';
					return undef;
				}
				elsif ($base->{'cannot_be_a_base_url_flag'} && $pointer->c eq "\N{U+0023}") {
					$url->{'scheme'} = $base->{'scheme'};
					$url->{'path'} = $base->{'path'};
					$url->{'query'} = $base->{'query'};
					$url->{'fragment'} = '';
					$url->{'cannot_be_a_base_url_flag'} = 1;
					$state = 'fragment state';
				}
				elsif ($base->{'scheme'} ne 'file') {
					$state = 'relative state';
					$pointer->decr(1);
				}
				else {
					$state = 'file state';
					$pointer->decr(1);
				}
			}
			when ('special relative or authority state') {
				if ($pointer->c eq "\N{U+002F}" && $pointer->remaining =~ m'^\N{U+002F}') {
					$state = 'special authority ignore slashes state';
					$pointer->incr(1);
				}
				else {
					warn 'validation error';
					$state = 'relative state';
					$pointer->decr(1);
				}
			}
			when ('path or authority state') {
				if ($pointer->c eq "\N{U+002F}") {
					$state = 'authority state';
				}
				else {
					$state = 'path state';
					$pointer->decr(1);
				}
			}
			when ('relative state') {
				$url->{'scheme'} = $base->{'scheme'};

				given ($pointer->c) {
					when ($pointer->is_eof) {
						$url->{'username'} = $base->{'username'};
						$url->{'password'} = $base->{'password'};
						$url->{'host'} = $base->{'host'};
						$url->{'port'} = $base->{'port'};
						$url->{'path'} = $base->{'path'};
						$url->{'query'} = $base->{'query'};
					}
					when ("\N{U+002F}") {
						$state = 'relative slash state';
					}
					when ("\N{U+003F}") {
						$url->{'username'} = $base->{'username'};
						$url->{'password'} = $base->{'password'};
						$url->{'host'} = $base->{'host'};
						$url->{'port'} = $base->{'port'};
						$url->{'path'} = $base->{'path'};
						$url->{'query'} = '';
						$state = 'query state';
					}
					when ("\N{U+0023}") {
						$url->{'username'} = $base->{'username'};
						$url->{'password'} = $base->{'password'};
						$url->{'host'} = $base->{'host'};
						$url->{'port'} = $base->{'port'};
						$url->{'path'} = $base->{'path'};
						$url->{'query'} = $base->{'query'};
						$url->{'fragment'} = '';
						$state = 'fragment state';
					}
					default {
						if ($url->is_special && $pointer->c eq "\N{U+005C}") {
							warn 'validation error';
							$state = 'relative slash state';
						}
						else {
							$url->{'username'} = $base->{'username'};
							$url->{'password'} = $base->{'password'};
							$url->{'host'} = $base->{'host'};
							$url->{'port'} = $base->{'port'};
							$url->{'path'} = $base->{'path'};
							pop $url->{'path'}->@*;

							$state = 'path state';
							$pointer->decr(1);
						}
					}
				}
			}
			when ('relative slash state') {
				if ($url->is_special && $pointer->c =~ m/^[\N{U+002F}\N{U+005C}]$/) {
					if ($pointer->c eq "\N{U+005C}") {
						warn 'validation error';
					}

					$state = 'special authority ignore slashes state';
				}
				elsif ($pointer->c eq "\N{U+002F}") {
					$state = 'authority state';
				}
				else {
					$url->{'username'} = $base->{'username'};
					$url->{'password'} = $base->{'password'};
					$url->{'host'} = $base->{'host'};
					$url->{'port'} = $base->{'port'};
					$state = 'path state';
					$pointer->decr(1);
				}
			}
			when ('special authority slashes state') {
				if ($pointer->c eq "\N{U+002F}" && $pointer->remaining =~ m'^\N{U+002F}') {
					$state = 'special authority ignore slashes state';
					$pointer->incr(1);
				}
				else {
					warn 'validation error';
					$state = 'special authority ignore slashes state';
					$pointer->decr(1);
				}
			}
			when ('special authority ignore slashes state') {
				if ($pointer->c !~ m/^[\N{U+002F}\N{U+005C}]$/) {
					$state = 'authority state';
					$pointer->decr(1);
				}
				else {
					warn 'validation error';
				}
			}
			when ('authority state') {
				if ($pointer->c eq "\N{U+0040}") {
					warn 'validation error';
					if ($at_sign_flag) {
						$buffer = '%40' . $buffer;
					}

					$at_sign_flag = 1;

					foreach my $code_point (split //, $buffer) {
						if ($code_point eq "\N{U+003A}" && !$password_token_seen_flag) {
							$password_token_seen_flag = 1;
							next;
						}

						my $encoded_code_points = utf8_percent_encode($code_point, $userinfo_percent_encode_set);

						if ($password_token_seen_flag) {
							$url->{'password'} .= $encoded_code_points;
						}
						else {
							$url->{'username'} .= $encoded_code_points;
						}
					}

					$buffer = '';
				}
				elsif (($pointer->is_eof || $pointer->c =~ m/^[\N{U+002F}\N{U+003F}\N{U+0023}]$/) || ($url->is_special && $pointer->c eq "\N{U+005C}")) {
					if ($at_sign_flag && $buffer eq '') {
						warn 'validation error';
						return undef;
					}

					$pointer->decr(length($buffer) + 1);
					$buffer = '';
					$state = 'host state';
				}
				else {
					$buffer .= $pointer->c;
				}
			}
			when ([ 'host state', 'hostname state' ]) {
				if (defined $state_override && $url->{'scheme'} eq 'file') {
					$pointer->decr(1);
					$state = 'file host state';
				}
				elsif ($pointer->c eq "\N{U+003A}" && !$square_brackets_flag) {
					if ($buffer eq '') {
						warn 'validation error';
						return undef;
					}

					my $host = host_parse($buffer, $url->is_special);

					unless (defined $host) {
						return undef;
					}

					$url->{'host'} = $host;
					$buffer = '';
					$state = 'port state';

					if (defined $state_override && $state_override eq 'hostname state') {
						return;
					}
				}
				elsif (($pointer->is_eof || $pointer->c =~ m/^[\N{U+002F}\N{U+003F}\N{U+0023}]$/) || ($url->is_special && $pointer->c eq "\N{U+005C}")) {
					$pointer->decr(1);

					if ($url->is_special && $buffer eq '') {
						warn 'validation error';
						return undef;
					}
					elsif (defined $state_override && $buffer eq '' && ($url->includes_credentials || (defined $url->{'port'}))) {
						warn 'validation error';
						return undef;
					}

					my $host = host_parse($buffer, $url->is_special);

					unless (defined $host) {
						return undef;
					}

					$url->{'host'} = $host;
					$buffer = '';
					$state = 'path start state';

					if (defined $state_override) {
						return;
					}
				}
				else {
					if ($pointer->c eq "\N{U+005B}") {
						$square_brackets_flag = 1;
					}

					if ($pointer->c eq "\N{U+005D}") {
						$square_brackets_flag = 0;
					}

					$buffer .= $pointer->c;
				}
			}
			when ('port state') {
				if ($pointer->c =~ m/^[\N{U+0030}-\N{U+0039}]$/) {
					$buffer .= $pointer->c;
				}
				elsif (($pointer->is_eof || $pointer->c =~ m/^[\N{U+002F}\N{U+003F}\N{U+0023}]$/) || ($url->is_special && $pointer->c eq "\N{U+005C}") || (defined $state_override)) {
					if ($buffer ne '') {
						my $port = int($buffer);

						if ($port > 2**16 - 1) {
							warn 'validation error';
							return undef;
						}

						$url->{'port'} = ($port eq $special_schemes->{$url->{'scheme'}}) ? undef : $port;

						$buffer = '';
					}

					if (defined $state_override) {
						return;
					}

					$state = 'path start state';
					$pointer->decr(1);
				}
				else {
					warn 'validation error';
					return undef;
				}
			}
			when ('file state') {
				$url->{'scheme'} = 'file';

				if ($pointer->c ~~ [ "\N{U+002F}", "\N{U+005C}" ]) {
					if ($pointer->c eq "\N{U+005C}") {
						warn 'validation error';
					}

					$state = 'file slash state';
				}
				elsif (defined $base && $base->{'scheme'} eq 'file') {
					given ($pointer->c) {
						when ($pointer->is_eof) {
							$url->{'host'} = $base->{'host'};
							$url->{'path'} = $base->{'path'};
							$url->{'query'} = $base->{'query'};
						}
						when ("\N{U+003F}") {
							$url->{'host'} = $base->{'host'};
							$url->{'path'} = $base->{'path'};
							$url->{'query'} = '';
							$state = 'query state';
						}
						when ("\N{U+0023}") {
							$url->{'host'} = $base->{'host'};
							$url->{'path'} = $base->{'path'};
							$url->{'query'} = $base->{'query'};
							$url->{'fragment'} = '';
							$state = 'fragment state';
						}
						default {
							if (!starts_with_a_windows_drive_letter($pointer->c . $pointer->remaining)) {
								$url->{'host'} = $base->{'host'};
								$url->{'path'} = $base->{'path'};
								$url->shorten_path();
							}
							else {
								warn 'validation error';
							}

							$state = 'path state';
							$pointer->decr(1);
						}
					}
				}
				else {
					$state = 'path state';
					$pointer->decr(1);
				}
			}
			when ('file slash state') {
				if ($pointer->c =~ m/^[\N{U+002F}\N{U+005C}]$/) {
					if ($pointer->c eq "\N{U+005C}") {
						warn 'validation error';
					}

					$state = 'file host state';
				}
				else {
					if (defined $base && $base->{'scheme'} eq 'file' && !starts_with_a_windows_drive_letter($pointer->c . $pointer->remaining)) {
						if ($base->{'path'}->[0] =~ m/^$normalized_windows_drive_letter$/) {
							push $url->{'path'}->@*, $base->{'path'}->[0];
						}
						else {
							$url->{'host'} = $base->{'host'};
						}
					}

					$state = 'path state';
					$pointer->decr(1);
				}
			}
			when ('file host state') {
				if ($pointer->is_eof || $pointer->c =~ m/^[\N{U+002F}\N{U+005C}\N{U+003F}\N{U+0023}]$/) {
					$pointer->decr(1);
					if(!defined $state_override && $buffer =~ m/^$windows_drive_letter$/) {
						warn 'validation error';
						$state = 'path state';
					}
					elsif ($buffer eq '') {
						$url->{'host'} = '';

						if (defined $state_override) {
							return;
						}

						$state = 'path start state';
					}
					else {
						my $host = host_parse($buffer, $url->is_special);

						unless (defined $host) {
							return undef;
						}

						if ($host eq 'localhost') {
							$host = '';
						}

						$url->{'host'} = $host;

						if (defined $state_override) {
							return;
						}

						$buffer = '';
						$state = 'path start state';
					}
				}
				else {
					$buffer .= $pointer->c;
				}
			}
			when ('path start state') {
				if ($url->is_special) {
					if ($pointer->c eq "\N{U+005C}") {
						warn 'validation error';
					}

					$state = 'path state';

					if ($pointer->c !~ m/^[\N{U+002F}\N{U+005C}]$/) {
						$pointer->decr(1);
					}
				}
				elsif (!defined $state_override && $pointer->c eq "\N{U+003F}") {
					$url->{'query'} = '';
					$state = 'query state';
				}
				elsif (!defined $state_override && $pointer->c eq "\N{U+0023}") {
					$url->{'fragment'} = '';
					$state = 'fragment state';
				}
				elsif (!$pointer->is_eof) {
					$state = 'path state';

					if ($pointer->c ne "\N{U+002F}") {
						$pointer->decr(1);
					}
				}
			}
			when ('path state') {
				if (($pointer->is_eof || $pointer->c eq "\N{U+002F}") || ($url->is_special && $pointer->c eq "\N{U+005C}") || (!defined $state_override && $pointer->c =~ m/^[\N{U+003F}\N{U+0023}]$/)) {
					if ($url->is_special && $pointer->c eq "\N{U+005C}") {
						warn 'validation error';
					}

					if ($buffer eq '..' || WHATWG::Infra::ascii_lowercase($buffer) ~~ [ '.%2e', '%2e.', '%2e%2e' ]) {
						$url->shorten_path();

						if (!($pointer->c eq "\N{U+002F}") && !($url->is_special && $pointer->c eq "\N{U+005C}")) {
							push $url->{'path'}->@*, '';
						}
					}
					elsif (($buffer eq '.' || WHATWG::Infra::ascii_lowercase($buffer) ~~ '%2e') && !($pointer->c eq "\N{U+002F}") && !($url->is_special && $pointer->c eq "\N{U+005C}")) {
						push $url->{'path'}->@*, '';
					}
					elsif (!($buffer eq '.' || WHATWG::Infra::ascii_lowercase($buffer) ~~ '%2e')) {
						if ($url->{'scheme'} eq 'file' && !$url->{'path'}->@* && $buffer =~ m/^$windows_drive_letter$/) {
							if (defined $url->{'host'} && $url->{'host'} ne '') {
								warn 'validation error';
								$url->{'host'} = '';
							}

							substr($buffer, 1, 1) = ':';
						}

						push $url->{'path'}->@*, $buffer;
					}

					$buffer = '';

					if ($url->{'scheme'} eq 'file' && ($pointer->is_eof || $pointer->c =~ m/^[\N{U+003F}\N{U+0023}]$/)) {
						while (scalar($url->{'path'}->@*) > 1 && $url->{'path'}->[0] eq '') {
							warn 'validation error';
							shift $url->{'path'}->@*;
						}
					}

					if ($pointer->c eq "\N{U+003F}") {
						$url->{'query'} = '';
						$state = 'query state';
					}

					if ($pointer->c eq "\N{U+0023}") {
						$url->{'fragment'} = '';
						$state = 'fragment state';
					}
				}
				else {
					# TODO

					if ($pointer->c eq "\N{U+0025}" && $pointer->remaining !~ m/^[\N{U+0030}-\N{U+0039}\N{U+0041}-\N{U+0046}\N{U+0061}-\N{U+0066}]{2}/) {
						warn 'validation error';
					}

					$buffer .= utf8_percent_encode($pointer->c, $path_percent_encode_set);
				}
			}
			when ('cannot-be-a-base-URL path state') {
				if ($pointer->c eq "\N{U+003F}") {
					$url->{'query'} = '';
					$state = 'query state';
				}
				elsif ($pointer->c eq "\N{U+0023}") {
					$url->{'fragment'} = '';
					$state = 'fragment state';
				}
				else {
					# TODO

					if ($pointer->c eq "\N{U+0025}" && $pointer->remaining !~ m/^[\N{U+0030}-\N{U+0039}\N{U+0041}-\N{U+0046}\N{U+0061}-\N{U+0066}]{2}/) {
						warn 'validation error';
					}

					if (!$pointer->is_eof) {
						$url->{'path'}->[0] .= utf8_percent_encode($pointer->c, $c0_control_percent_encode_set);
					}
				}
			}
			when ('query state') {
				if ($pointer->is_eof || (!defined $state_override && $pointer->c eq "\N{U+0023}")) {
					if (!$url->is_special || $url->{'scheme'} ~~ [ 'ws', 'wss' ]) {
						$encoding = 'UTF-8';
					}

					$buffer = Encode::encode($encoding, $buffer);  # TODO: encode

					for (my $i = 0, my $j = 0; $i < length($buffer); $i++, $j++) {
						my $byte = vec($buffer, $i, 8);

						if ($byte < 0x21 || $byte > 0x7E || $byte ~~ [ 0x22, 0x23, 0x3C, 0x3E ]) {
							$url->{'query'} .= percent_encode($byte);
						}
						else {
							$url->{'query'} .= chr($byte);
						}
					}

					$buffer = '';

					if ($pointer->c eq "\N{U+0023}") {
						$url->{'fragment'} = '';
						$state = 'fragment state';
					}
				}
				else {
					# TODO

					if ($pointer->c eq "\N{U+0025}" && $pointer->remaining !~ m/^[\N{U+0030}-\N{U+0039}\N{U+0041}-\N{U+0046}\N{U+0061}-\N{U+0066}]{2}/) {
						warn 'validation error';
					}

					$buffer .= $pointer->c;
				}
			}
			when ('fragment state') {
				given ($pointer->c) {
					when ($pointer->is_eof) {
						# Do nothing.
					}
					when ("\N{U+0000}") {
						warn 'validation error';
					}
					default {
						# TODO

						if ($pointer->c eq "\N{U+0025}" && $pointer->remaining !~ m/^[\N{U+0030}-\N{U+0039}\N{U+0041}-\N{U+0046}\N{U+0061}-\N{U+0066}]{2}/) {
							warn 'validation error';
						}

						$url->{'fragment'} .= utf8_percent_encode($pointer->c, $fragment_percent_encode_set);
					}
				}
			}
			default {
				die "Invalid state: $state";
			}
		}

		if ($pointer->is_eof) {
			last;
		}
		else {
			$pointer->incr(1);
		}
	}

	# XXX
	# print Dumper($url);

	return $url;
}

sub set_username {
	my ($self, $username) = @_;

	$self->{'username'} = '';

	foreach my $code_point (split(m//, $username)) {
		$self->{'username'} .= utf8_percent_encode($code_point, $userinfo_percent_encode_set);
	}
}

sub set_password {
	my ($self, $password) = @_;

	$self->{'password'} = '';

	foreach my $code_point (split(m//, $password)) {
		$self->{'password'} .= utf8_percent_encode($code_point, $userinfo_percent_encode_set);
	}
}

#
# 4.5. URL serializing
#

sub serialize {
	my ($self, $exclude_fragment_flag) = @_;

	my $output = $self->{'scheme'} . chr(0x003A);

	if (defined $self->{'host'}) {
		$output .= '//';

		if ($self->includes_credentials) {
			$output .= $self->{'username'};

			if ($self->{'password'} ne '') {
				$output .= chr(0x003A) . $self->{'password'};
			}

			$output .= chr(0x0040);
		}

		$output .= host_serialize($self->{'host'});

		if (defined $self->{'port'}) {
			$output .= chr(0x003A) . integer_serialize($self->{'port'});
		}
	}
	elsif (!defined $self->{'host'} && $self->{'scheme'} eq 'file') {
		$output .= '//';
	}

	if ($self->{'cannot_be_a_base_url_flag'}) {
		$output .= $self->{'path'}->[0];
	}
	else {
		foreach my $string ($self->{'path'}->@*) {
			$output .= chr(0x002F) . $string;
		}
	}

	if (defined $self->{'query'}) {
		$output .= chr(0x003F) . $self->{'query'};
	}

	if (!$exclude_fragment_flag && defined $self->{'fragment'}) {
		$output .= chr(0x0023) . $self->{'fragment'};
	}

	return $output;
}

#
# 4.6. URL equivalence
#

sub equals {
	my ($A, $B, $exclude_fragments_flag) = @_;

	my $serialized_A = $A->serialize($exclude_fragments_flag);
	my $serialized_B = $B->serialize($exclude_fragments_flag);

	return ($serialized_A eq $serialized_B);
}

#
# 5.1. application/x-www-form-urlencoded parsing
#

sub urlencoded_parse {
	my ($input) = @_;

	my @sequences = split(m/\x26/, $input);

	my $output = [];

	foreach my $bytes (@sequences) {
		if ($bytes eq '') {
			next;
		}

		my $name;
		my $value;
		if ($bytes =~ m/\x3D/) {
			($name, $value) = ($bytes =~ m/^(.*?)\x3D(.*)$/);
		}
		else {
			$name = $bytes;
			$value = '';
		}

		$name =~ s/\x2B/\x20/g;
		$value =~ s/\x2B/\x20/g;

		my $name_string = Encode::decode('UTF-8', percent_decode($name));  # TODO: UTF-8 decode without BOM
		my $value_string = Encode::decode('UTF-8', percent_decode($value));  # TODO: UTF-8 decode without BOM

		push $output->@*, [ $name_string, $value_string ];
	}

	return $output;
}

#
# 5.3. Hooks
#

sub urlencoded_string_parse {
	my ($input) = @_;

	return urlencoded_parse(Encode::encode('UTF-8', $input));  # TODO: UTF-8 encode
}

=head1 LICENSE

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at L<http://mozilla.org/MPL/2.0/>.

=cut

1;
