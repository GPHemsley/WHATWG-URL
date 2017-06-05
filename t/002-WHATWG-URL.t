#!perl -T

use v5.22;
use strict;
use warnings;

use Test::More;

# XXX
use Data::Dumper;

use_ok('WHATWG::URL');

is(WHATWG::URL->basic_url_parse('http://example.org/')->serialize(), 'http://example.org/');
is(WHATWG::URL->basic_url_parse('http://example.org/test')->serialize(), 'http://example.org/test');
is(WHATWG::URL->basic_url_parse('http://username:password@example.org/test/ing')->serialize(), 'http://username:password@example.org/test/ing');

is(WHATWG::URL->basic_url_parse(''), undef);
is(WHATWG::URL->basic_url_parse('about:blank')->serialize(), 'about:blank');

# 4. URLs
is(WHATWG::URL->basic_url_parse('https:example.org')->serialize(), 'https://example.org/');
is(WHATWG::URL->basic_url_parse('https://////example.com///')->serialize(), 'https://example.com///');
is(WHATWG::URL->basic_url_parse('https://example.com/././foo')->serialize(), 'https://example.com/foo');
is(WHATWG::URL->basic_url_parse('hello:world', WHATWG::URL->basic_url_parse('https://example.com/'))->serialize(), 'hello:world');
is(WHATWG::URL->basic_url_parse('https:example.org', WHATWG::URL->basic_url_parse('https://example.com/'))->serialize(), 'https://example.com/example.org');
is(WHATWG::URL->basic_url_parse('\example\..\demo/.\\', WHATWG::URL->basic_url_parse('https://example.com/'))->serialize(), 'https://example.com/demo/');
is(WHATWG::URL->basic_url_parse('example', WHATWG::URL->basic_url_parse('https://example.com/demo'))->serialize(), 'https://example.com/example');
is(WHATWG::URL->basic_url_parse('file:///C|/demo')->serialize(), 'file:///C:/demo');
is(WHATWG::URL->basic_url_parse('..', WHATWG::URL->basic_url_parse('file:///C:/demo'))->serialize(), 'file:///C:/');
is(WHATWG::URL->basic_url_parse('file://loc%61lhost/')->serialize(), 'file:///');
is(WHATWG::URL->basic_url_parse('https://user:password@example.org/')->serialize(), 'https://user:password@example.org/');
is(WHATWG::URL->basic_url_parse('https://example.org/foo bar')->serialize(), 'https://example.org/foo%20bar');
is(WHATWG::URL->basic_url_parse('https://EXAMPLE.com/../x')->serialize(), 'https://example.com/x');
is(WHATWG::URL->basic_url_parse('https://ex ample.org/'), undef);
is(WHATWG::URL->basic_url_parse('example'), undef);
is(WHATWG::URL->basic_url_parse('https://example.com:demo'), undef);
is(WHATWG::URL->basic_url_parse('http://[www.example.com]/'), undef);

#
# Debug
#

is(WHATWG::URL->basic_url_parse('http://192.168.001.001:80/')->serialize(), 'http://192.168.1.1/');
# is(WHATWG::URL->basic_url_parse('non-special://192.168.001.001:80/')->serialize(), 'non-special://192.168.1.1:80/');
is(WHATWG::URL->basic_url_parse('http://[0:f:0:0:f:f:0:0]:80/')->serialize(), 'http://[0:f::f:f:0:0]/');
is(WHATWG::URL->basic_url_parse('non-special://[1:2::3]:80/')->serialize(), 'non-special://[1:2::3]:80/');

is(WHATWG::URL->basic_url_parse('http://192.0x00A80001')->serialize(), 'http://192.168.0.1/');
is(WHATWG::URL->basic_url_parse('http://%30%78%63%30%2e%30%32%35%30.01%2e')->serialize(), 'http://192.168.0.1/');

is(WHATWG::URL->basic_url_parse('http://255.255.255.255/')->serialize(), 'http://255.255.255.255/');

is(WHATWG::URL->basic_url_parse('http://192.168.257', WHATWG::URL->basic_url_parse('http://example.com/'))->serialize(), 'http://192.168.1.1/');
is(WHATWG::URL->basic_url_parse('http://192.168.257.com', WHATWG::URL->basic_url_parse('http://example.com/'))->serialize(), 'http://192.168.257.com/');

is(WHATWG::URL->basic_url_parse('https://0x.0x.0', WHATWG::URL->basic_url_parse('about:blank'))->serialize(), 'https://0.0.0.0/');

is(WHATWG::URL->basic_url_parse('', WHATWG::URL->basic_url_parse('http://user:pass@example.org:21/smth'))->serialize(), 'http://user:pass@example.org:21/smth');

is(WHATWG::URL->basic_url_parse('', WHATWG::URL->basic_url_parse('file:///path?quer#frag'))->serialize(), 'file:///path?quer');
is(WHATWG::URL->basic_url_parse('file:', WHATWG::URL->basic_url_parse('file:///path?quer#frag'))->serialize(), 'file:///path?quer');

TODO: {
	local $TODO = 'Net::IDN::UTS46 has issues';

	is(WHATWG::URL::domain_to_ascii('.'), '.');
	is(WHATWG::URL::domain_to_ascii('..'), '..');

	is(WHATWG::URL->basic_url_parse('http://10000000000', WHATWG::URL->basic_url_parse('http://example.com/')), undef);
	is(WHATWG::URL->basic_url_parse('http://4294967296', WHATWG::URL->basic_url_parse('http://example.com/')), undef);
	is(WHATWG::URL->basic_url_parse('http://0xffffffff1', WHATWG::URL->basic_url_parse('http://example.com/')), undef);
	is(WHATWG::URL->basic_url_parse('http://256.256.256.256', WHATWG::URL->basic_url_parse('http://example.com/')), undef);
}

# is(WHATWG::URL->basic_url_parse('http://./', WHATWG::URL->basic_url_parse('about:blank'))->serialize(), 'http://./');
# is(WHATWG::URL->basic_url_parse('http://./', WHATWG::URL->basic_url_parse('http://example.org/'))->serialize(), 'http://./');
# is(WHATWG::URL->basic_url_parse('http://../', WHATWG::URL->basic_url_parse('about:blank'))->serialize(), 'http://../');
# is(WHATWG::URL->basic_url_parse('http://../', WHATWG::URL->basic_url_parse('http://example.org/'))->serialize(), 'http://../');
is(WHATWG::URL->basic_url_parse('http://0..0x300/', WHATWG::URL->basic_url_parse('about:blank'))->serialize(), 'http://0..0x300/');

done_testing();
