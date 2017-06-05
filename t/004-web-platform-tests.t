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

	foreach my $test (@{$test_data}) {
		unless (ref $test eq 'HASH') {
			diag(encode_utf8($test));
			next;
		}

		if (exists $test->{'failure'} && $test->{'failure'}) {
			is(WHATWG::URL->basic_url_parse($test->{'input'}, WHATWG::URL->basic_url_parse($test->{'base'})), undef);
		}
		else {
			my $url = WHATWG::URL->basic_url_parse($test->{'input'}, WHATWG::URL->basic_url_parse($test->{'base'}));

			isnt($url, undef);

			if (defined $url) {
				if ($url->{'host'} ne '' && int($url->{'host'}) eq $url->{'host'}) {
					TODO: {
						local $TODO = 'host_serializer is missing IPv4 support';

						is($url->serialize(), $test->{'href'});
					}
				}
				# elsif (ref $url->{'host'} eq 'ARRAY') {
				# 	TODO: {
				# 		local $TODO = 'host_serializer is missing IPv6 support';

				# 		is($url->serialize(), $test->{'href'});
				# 	}
				# }
				elsif ($test->{'href'} =~ m/%/) {
					TODO: {
						local $TODO = 'utf8_percent_encode is missing byte support';

						is($url->serialize(), $test->{'href'});
					}
				}
				else {
					is($url->serialize(), $test->{'href'}) || explain($url);
				}
			}
		}
	}
}


done_testing();
