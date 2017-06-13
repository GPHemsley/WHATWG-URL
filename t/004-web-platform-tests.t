#!perl -T

use v5.22;
use strict;
use warnings;

use Test::More;
use LWP::Simple;
use Encode;
use JSON;

# XXX
use Data::Dumper;

use_ok('WHATWG::URL');
use_ok('WHATWG::URL::URL');
use_ok('WHATWG::URL::URLSearchParams');

# https://github.com/w3c/web-platform-tests/tree/master/url
SKIP: {
	my $json = get('https://raw.githubusercontent.com/w3c/web-platform-tests/master/url/urltestdata.json') or skip('Could not get test data');

	my $test_data = decode_json(encode_utf8($json));

	# Ignore validation errors.
	$SIG{'__WARN__'} = sub { warn $_[0] unless $_[0] =~ m/^validation error/ };

	foreach my $test (@{$test_data}) {
		unless (ref $test eq 'HASH') {
			diag(encode_utf8($test));
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
				elsif ($test->{'input'} =~ m/[\N{U+0100}-\N{U+10FFFF}]/) {
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
					elsif ($test->{'input'} =~ m/[\N{U+0100}-\N{U+10FFFF}]/) {
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
