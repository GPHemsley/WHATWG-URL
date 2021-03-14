#!perl -T

use v5.22;
use strict;
use warnings;

use Test::More;

# XXX
use Data::Dumper;

use_ok('WHATWG::URL::Util::Pointer');

#
# Test pointer
#

my $pointer_default = WHATWG::URL::Util::Pointer->new('');
my $pointer_0 = WHATWG::URL::Util::Pointer->new('', 0);
my $pointer_1 = WHATWG::URL::Util::Pointer->new('', 1);

is(ref $pointer_default, 'WHATWG::URL::Util::Pointer');
is(ref $pointer_0, 'WHATWG::URL::Util::Pointer');
is(ref $pointer_1, 'WHATWG::URL::Util::Pointer');

is($pointer_default->pointer, 0);
is($pointer_0->pointer, 0);
is($pointer_1->pointer, 1);

$pointer_default->incr(1);
$pointer_0->incr(1);
$pointer_1->incr(1);

is($pointer_default->pointer, 1);
is($pointer_0->pointer, 1);
is($pointer_1->pointer, 2);

$pointer_default->incr(2);
$pointer_0->incr(2);
$pointer_1->incr(2);

is($pointer_default->pointer, 3);
is($pointer_0->pointer, 3);
is($pointer_1->pointer, 4);

$pointer_default->decr(1);
$pointer_0->decr(1);
$pointer_1->decr(1);

is($pointer_default->pointer, 2);
is($pointer_0->pointer, 2);
is($pointer_1->pointer, 3);

$pointer_default->decr(2);
$pointer_0->decr(2);
$pointer_1->decr(2);

is($pointer_default->pointer, 0);
is($pointer_0->pointer, 0);
is($pointer_1->pointer, 1);

$pointer_default->set(10);
$pointer_0->set(10);
$pointer_1->set(10);

is($pointer_default->pointer, 10);
is($pointer_0->pointer, 10);
is($pointer_1->pointer, 10);

$pointer_default->reset();
$pointer_0->reset();
$pointer_1->reset();

is($pointer_default->pointer, 0);
is($pointer_0->pointer, 0);
is($pointer_1->pointer, 0);

$pointer_default->decr(1);
$pointer_0->decr(1);
$pointer_1->decr(1);

is($pointer_default->pointer, -1);
is($pointer_0->pointer, -1);
is($pointer_1->pointer, -1);

$pointer_default->incr(1);
$pointer_0->incr(1);
$pointer_1->incr(1);

is($pointer_default->pointer, 0);
is($pointer_0->pointer, 0);
is($pointer_1->pointer, 0);

$pointer_default->reset();
$pointer_0->reset();
$pointer_1->reset();

is($pointer_default->pointer, 0);
is($pointer_0->pointer, 0);
is($pointer_1->pointer, 0);

#
# Test string indexing
#

my $pointer_foobar = WHATWG::URL::Util::Pointer->new('foobar');

ok($pointer_default->is_eof);
ok($pointer_0->is_eof);
ok($pointer_1->is_eof);
ok(!$pointer_foobar->is_eof);

is($pointer_default->c, '');
is($pointer_0->c, '');
is($pointer_1->c, '');
is($pointer_foobar->c, 'f');

is($pointer_default->remaining, undef);
is($pointer_0->remaining, undef);
is($pointer_1->remaining, undef);
is($pointer_foobar->remaining, 'oobar');

$pointer_default->incr(1);
$pointer_0->incr(1);
$pointer_1->incr(1);
$pointer_foobar->incr(1);

is($pointer_default->c, '');
is($pointer_0->c, '');
is($pointer_1->c, '');
is($pointer_foobar->c, 'o');

is($pointer_default->remaining, undef);
is($pointer_0->remaining, undef);
is($pointer_1->remaining, undef);
is($pointer_foobar->remaining, 'obar');

$pointer_default->decr(2);
$pointer_0->decr(2);
$pointer_1->decr(2);
$pointer_foobar->decr(2);

is($pointer_default->c, undef);
is($pointer_0->c, undef);
is($pointer_1->c, undef);
is($pointer_foobar->c, undef);

is($pointer_default->remaining, undef);
is($pointer_0->remaining, undef);
is($pointer_1->remaining, undef);
is($pointer_foobar->remaining, undef);

$pointer_default->set(6);
$pointer_0->set(6);
$pointer_1->set(6);
$pointer_foobar->set(6);

ok($pointer_foobar->is_eof);

is($pointer_default->c, '');
is($pointer_0->c, '');
is($pointer_1->c, '');
is($pointer_foobar->c, '');

is($pointer_default->remaining, undef);
is($pointer_0->remaining, undef);
is($pointer_1->remaining, undef);
is($pointer_foobar->remaining, undef);

done_testing();
