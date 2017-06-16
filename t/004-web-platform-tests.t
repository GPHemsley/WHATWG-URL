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

use feature 'postderef';
use experimental 'postderef';

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
				elsif ($test->{'hostname'} =~ m/(\.|%2E){2}|^\.$/i) {
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
					elsif ($test->{'hostname'} =~ m/(\.|%2E){2}|^\.$/i) {
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
