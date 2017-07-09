#!perl -T

use v5.22;
use strict;
use warnings;

use Test::More;
use Test::Exception;
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

# https://github.com/w3c/web-platform-tests/blob/master/url/urltestdata.json
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
	];
	$test_data = [ $test_data->@*, $test_data_gaps->@* ];

	# Ignore validation errors.
	$SIG{'__WARN__'} = sub { warn $_[0] unless $_[0] =~ m/^validation error/ };

	foreach my $test ($test_data->@*) {
		unless (ref $test eq 'HASH') {
			note(Encode::encode_utf8($test));
			next;
		}

		subtest Encode::encode('UTF-8', $test->{'input'}) => sub {
			if (exists $test->{'failure'} && $test->{'failure'}) {
				throws_ok { WHATWG::URL::URL->new($test->{'input'}, $test->{'base'}) } qr/TypeError/ || explain(WHATWG::URL::URL->new($test->{'input'}, $test->{'base'}));
			}
			else {
				my $url = WHATWG::URL::URL->new($test->{'input'}, WHATWG::URL::URL->new($test->{'base'}));

				if (0) {
					fail('placeholder - this should never happen');
				}
				elsif ($test->{'hostname'} =~ m/(\.|%2E){2}|^\.$/i) {
					TODO: {
						local $TODO = 'known issue with Net::IDN::UTS46';

						isnt($url, undef) || explain($url);
					}
				}
				else {
					isnt($url, undef) || explain($url);
				}

				if (defined $url) {
					if (0) {
						fail('placeholder - this should never happen');
					}
					elsif ($test->{'hostname'} =~ m/(\.|%2E){2}|^\.$/i) {
						TODO: {
							local $TODO = 'known issue with Net::IDN::UTS46';

							is($url->href, $test->{'href'}) || explain($url);
							is($url->toJSON(), $test->{'href'}) || explain($url);
							is($url->host, $test->{'host'}) || explain($url);
							is($url->hostname, $test->{'hostname'}) || explain($url);
						}
					}
					else {
						is($url->href, $test->{'href'}) || explain($url);
						is($url->toJSON(), $test->{'href'}) || explain($url);
						is($url->host, $test->{'host'}) || explain($url);
						is($url->hostname, $test->{'hostname'}) || explain($url);
					}

					is($url->protocol, $test->{'protocol'}) || explain($url);
					is($url->username, $test->{'username'}) || explain($url);
					is($url->password, $test->{'password'}) || explain($url);
					is($url->port, $test->{'port'}) || explain($url);
					is($url->pathname, $test->{'pathname'}) || explain($url);
					is($url->search, $test->{'search'}) || explain($url);
					is($url->hash, $test->{'hash'}) || explain($url);

					TODO: {
						local $TODO = 'origin';

						if (exists $test->{'origin'}) {
							is($url->origin, $test->{'origin'}) || explain($url);
						}
					}

					TODO: {
						local $TODO = 'searchParams';

						if (exists $test->{'searchParams'}) {
							is($url->searchParams, $test->{'searchParams'}) || explain($url);
						}
					}
				}
			}
		};
	}
}


done_testing();
