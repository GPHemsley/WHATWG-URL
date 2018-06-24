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

# https://github.com/w3c/web-platform-tests/blob/master/url/setters_tests.json
my $user_agent = LWP::UserAgent->new();

my $response = $user_agent->get('http://w3c-test.org/url/setters_tests.json');

my $json;
if ($response->is_success()) {
	$json = $response->decoded_content;
}
else {
	fail('Could not get test data');
}

SKIP: {
	skip('No test data available') unless defined $json;

	my $test_data = decode_json($json);

	# Ignore validation errors.
	$SIG{'__WARN__'} = sub { warn $_[0] unless $_[0] =~ m/^validation error/ };

	foreach my $test_attribute (sort keys $test_data->%*) {
		if ($test_attribute eq 'comment') {
			next;
		}

		subtest Encode::encode('UTF-8', $test_attribute) => sub {
			foreach my $test ($test_data->{$test_attribute}->@*) {
				subtest Encode::encode('UTF-8', $test->{'href'}) => sub {
					if (exists $test->{'comment'}) {
						note(Encode::encode_utf8($test->{'comment'}));
					}

					my $url;
					lives_ok { $url = WHATWG::URL::URL->new($test->{'href'}); };

					my $new_value = $url->$test_attribute($test->{'new_value'});

					# is($new_value, $test->{'expected'}->{$test_attribute}) || diag(explain($new_value), explain($test->{'expected'}->{$test_attribute}));

					foreach my $expected_attribute (sort keys $test->{'expected'}->%*) {
						subtest Encode::encode('UTF-8', $expected_attribute) => sub {
							is($url->$expected_attribute, $test->{'expected'}->{$expected_attribute});
						};
					}
				};
			}
		};
	}
}

done_testing();
