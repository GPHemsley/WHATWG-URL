#!perl -T

use v5.22;
use strict;
use warnings;

use Test::More;
use WHATWG::URL::URL;

plan tests => 4;

BEGIN {
    use_ok( 'WHATWG::URL::Util::Pointer' ) || print "Bail out!\n";
    use_ok( 'WHATWG::URL' ) || print "Bail out!\n";
    use_ok( 'WHATWG::URL::URL' ) || print "Bail out!\n";
    use_ok( 'WHATWG::URL::URLSearchParams' ) || print "Bail out!\n";
}

diag( "Testing WHATWG::URL $WHATWG::URL::VERSION, Perl $], $^X" );
