#!perl -T

use v5.22;
use strict;
use warnings;

use Test::More;
use LWP::UserAgent ();
use Encode;
use JSON;

# XXX
use Data::Dumper;

use_ok('WHATWG::URL');
use_ok('WHATWG::URL::URL');
use_ok('WHATWG::URL::URLSearchParams');

# https://github.com/w3c/web-platform-tests/tree/master/url
SKIP: {
	my $user_agent = LWP::UserAgent->new();

	my $response = $user_agent->get('http://w3c-test.org/url/urltestdata.json');

	my $json;
	if ($response->is_success()) {
		$json = $response->decoded_content;
	}
	else {
		skip('Could not get test data');
	}

	my $test_data = decode_json($json);

	# Fill in gaps in coverage.
	my $test_data_gaps = [
		'More IPv4 parsing (via https://github.com/jsdom/whatwg-url/issues/92)',
		{
			'input' => 'https://0x100000000/test',
			'base' => 'about:blank',
			'failure' => JSON::true,
		},
		{
			'input' => 'https://256.0.0.1/test',
			'base' => 'about:blank',
			'failure' => JSON::true,
		},
		'Invalid IPv4 radix digits',
		{
			'input' => 'http://0177.0.0.0189',
			'base' => 'about:blank',
			'href' => 'http://0177.0.0.0189/',
			'protocol' => 'http:',
			'username' => '',
			'password' => '',
			'host' => '0177.0.0.0189',
			'hostname' => '0177.0.0.0189',
			'port' => '',
			'pathname' => '/',
			'search' => '',
			'hash' => '',
		},
		{
			'input' => 'http://0x7f.0.0.0x7g',
			'base' => 'about:blank',
			'href' => 'http://0x7f.0.0.0x7g/',
			'protocol' => 'http:',
			'username' => '',
			'password' => '',
			'host' => '0x7f.0.0.0x7g',
			'hostname' => '0x7f.0.0.0x7g',
			'port' => '',
			'pathname' => '/',
			'search' => '',
			'hash' => '',
		},
		{
			'input' => 'http://0X7F.0.0.0X7G',
			'base' => 'about:blank',
			'href' => 'http://0x7f.0.0.0x7g/',
			'protocol' => 'http:',
			'username' => '',
			'password' => '',
			'host' => '0x7f.0.0.0x7g',
			'hostname' => '0x7f.0.0.0x7g',
			'port' => '',
			'pathname' => '/',
			'search' => '',
			'hash' => '',
		},
		'Invalid IPv4 portion of IPv6 address',
		{
			'input' => 'http://[::127.0.0.0.1]',
			'base' => 'about:blank',
			'failure' => JSON::true,
		},
		'Uncompressed IPv6 addresses with 0',
		{
			'input' => 'http://[0:1:0:1:0:1:0:1]',
			'base' => 'about:blank',
			'href' => 'http://[0:1:0:1:0:1:0:1]/',
			'protocol' => 'http:',
			'username' => '',
			'password' => '',
			'host' => '[0:1:0:1:0:1:0:1]',
			'hostname' => '[0:1:0:1:0:1:0:1]',
			'port' => '',
			'pathname' => '/',
			'search' => '',
			'hash' => '',
		},
		{
			'input' => 'http://[1:0:1:0:1:0:1:0]',
			'base' => 'about:blank',
			'href' => 'http://[1:0:1:0:1:0:1:0]/',
			'protocol' => 'http:',
			'username' => '',
			'password' => '',
			'host' => '[1:0:1:0:1:0:1:0]',
			'hostname' => '[1:0:1:0:1:0:1:0]',
			'port' => '',
			'pathname' => '/',
			'search' => '',
			'hash' => '',
		},
		# 'Basic URL parser',
		# {
		# 	'input' => '#',
		# 	'base' => undef,
		# 	'failure' => JSON::true,
		# },
		# {
		# 	'input' => 'ftp://\\@',
		# 	'base' => 'http://example.org/',
		# 	'failure' => JSON::true,
		# },
		# {
		# 	'input' => 'http://e\\x',
		# 	'base' => 'http://example.org/',
		# 	'failure' => JSON::true,
		# },
		'Percent-encoded query and fragment',
		{
			'input' => "http://example.org/test?\x22",
			'base' => 'about:blank',
			'href' => 'http://example.org/test?%22',
			'protocol' => 'http:',
			'username' => '',
			'password' => '',
			'host' => 'example.org',
			'hostname' => 'example.org',
			'port' => '',
			'pathname' => '/test',
			'search' => '?%22',
			'hash' => '',
		},
		{
			'input' => "http://example.org/test?\x23",
			'base' => 'about:blank',
			'href' => 'http://example.org/test?#',
			'protocol' => 'http:',
			'username' => '',
			'password' => '',
			'host' => 'example.org',
			'hostname' => 'example.org',
			'port' => '',
			'pathname' => '/test',
			'search' => '',
			'hash' => '',
		},
		{
			'input' => "http://example.org/test?\x3C",
			'base' => 'about:blank',
			'href' => 'http://example.org/test?%3C',
			'protocol' => 'http:',
			'username' => '',
			'password' => '',
			'host' => 'example.org',
			'hostname' => 'example.org',
			'port' => '',
			'pathname' => '/test',
			'search' => '?%3C',
			'hash' => '',
		},
		{
			'input' => "http://example.org/test?\x3E",
			'base' => 'about:blank',
			'href' => 'http://example.org/test?%3E',
			'protocol' => 'http:',
			'username' => '',
			'password' => '',
			'host' => 'example.org',
			'hostname' => 'example.org',
			'port' => '',
			'pathname' => '/test',
			'search' => '?%3E',
			'hash' => '',
		},
		{
			'input' => "http://example.org/test?\x{2323}",
			'base' => 'about:blank',
			'href' => 'http://example.org/test?%E2%8C%A3',
			'protocol' => 'http:',
			'username' => '',
			'password' => '',
			'host' => 'example.org',
			'hostname' => 'example.org',
			'port' => '',
			'pathname' => '/test',
			'search' => '?%E2%8C%A3',
			'hash' => '',
		},
		{
			'input' => "http://example.org/test?%23%23",
			'base' => 'about:blank',
			'href' => 'http://example.org/test?%23%23',
			'protocol' => 'http:',
			'username' => '',
			'password' => '',
			'host' => 'example.org',
			'hostname' => 'example.org',
			'port' => '',
			'pathname' => '/test',
			'search' => '?%23%23',
			'hash' => '',
		},
		{
			'input' => "http://example.org/test?%GH",
			'base' => 'about:blank',
			'href' => 'http://example.org/test?%GH',
			'protocol' => 'http:',
			'username' => '',
			'password' => '',
			'host' => 'example.org',
			'hostname' => 'example.org',
			'port' => '',
			'pathname' => '/test',
			'search' => '?%GH',
			'hash' => '',
		},
		{
			'input' => "http://example.org/test?a#%EF",
			'base' => 'about:blank',
			'href' => 'http://example.org/test?a#%EF',
			'protocol' => 'http:',
			'username' => '',
			'password' => '',
			'host' => 'example.org',
			'hostname' => 'example.org',
			'port' => '',
			'pathname' => '/test',
			'search' => '?a',
			'hash' => '#%EF',
		},
		{
			'input' => "http://example.org/test?a#%GH",
			'base' => 'about:blank',
			'href' => 'http://example.org/test?a#%GH',
			'protocol' => 'http:',
			'username' => '',
			'password' => '',
			'host' => 'example.org',
			'hostname' => 'example.org',
			'port' => '',
			'pathname' => '/test',
			'search' => '?a',
			'hash' => '#%GH',
		},
		'Null code point in fragment',
		{
			'input' => "http://example.org/test?a#b\N{U+0000}c",
			'base' => 'about:blank',
			'href' => 'http://example.org/test?a#bc',
			'protocol' => 'http:',
			'username' => '',
			'password' => '',
			'host' => 'example.org',
			'hostname' => 'example.org',
			'port' => '',
			'pathname' => '/test',
			'search' => '?a',
			'hash' => '#bc',
		},
	];
	$test_data = [ $test_data->@*, $test_data_gaps->@* ];

	# Ignore validation errors.
	$SIG{'__WARN__'} = sub { warn $_[0] unless $_[0] =~ m/^validation error/ };

	foreach my $test ($test_data->@*) {
		unless (ref $test eq 'HASH') {
			note(encode_utf8($test));
			next;
		}

		subtest Encode::encode('UTF-8', $test->{'input'}) => sub {
			if (exists $test->{'failure'} && $test->{'failure'}) {
				is(WHATWG::URL->basic_url_parse($test->{'input'}, WHATWG::URL->basic_url_parse($test->{'base'})), undef);
			}
			else {
				my $url = WHATWG::URL->basic_url_parse($test->{'input'}, WHATWG::URL->basic_url_parse($test->{'base'}));

				if (0) {
					fail('placeholder - this should never happen');
				}
				elsif ($test->{'hostname'} =~ m/[\N{U+0100}-\N{U+10FFFF}]|(\.|%2E){2}|^\.$/i) {
					TODO: {
						local $TODO = 'known issue with Net::IDN::UTS46';

						isnt($url, undef);
					}
				}
				else {
					isnt($url, undef);
				}

				if (defined $url) {
					if (0) {
						fail('placeholder - this should never happen');
					}
					elsif ($test->{'hostname'} =~ m/[\N{U+0100}-\N{U+10FFFF}]|(\.|%2E){2}|^\.$/i) {
						TODO: {
							local $TODO = 'known issue with Net::IDN::UTS46';

							is($url->serialize(), $test->{'href'});
						}
					}
					else {
						is($url->serialize(), $test->{'href'}) || explain($url);
					}
				}
			}
		};
	}
}


done_testing();
