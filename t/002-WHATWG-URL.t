#!perl -T

use v5.22;
use strict;
use warnings;

use Test::More;
use Encode ();

# XXX
use Data::Dumper;

###

use_ok('WHATWG::URL');

###

#
# 1. Infrastructure
#

subtest 'integer_serialize' => sub {
	is(WHATWG::URL::integer_serialize('0'), 0);
	is(WHATWG::URL::integer_serialize('000'), 0);
	is(WHATWG::URL::integer_serialize('1'), 1);
	is(WHATWG::URL::integer_serialize('001'), 1);
	is(WHATWG::URL::integer_serialize('8'), 8);
	is(WHATWG::URL::integer_serialize('008'), 8);
	is(WHATWG::URL::integer_serialize('10'), 10);
	is(WHATWG::URL::integer_serialize('010'), 10);
	is(WHATWG::URL::integer_serialize(0x0A), 10);
};

#
# 1.3. Percent-encoded bytes
#

subtest 'percent_encode' => sub {
	is(WHATWG::URL::percent_encode(0), '%00');
	is(WHATWG::URL::percent_encode(1), '%01');
	is(WHATWG::URL::percent_encode(10), '%0A');
	is(WHATWG::URL::percent_encode(16), '%10');
	is(WHATWG::URL::percent_encode(0xFF), '%FF');
};

subtest 'percent_decode' => sub {
	is(WHATWG::URL::percent_decode(''), '');
	is(WHATWG::URL::percent_decode('a'), 'a');
	is(WHATWG::URL::percent_decode('%'), '%');
	is(WHATWG::URL::percent_decode('%%'), '%%');
	is(WHATWG::URL::percent_decode('%%%'), '%%%');
	is(WHATWG::URL::percent_decode('abc'), 'abc');
	is(WHATWG::URL::percent_decode('abc%'), 'abc%');
	is(WHATWG::URL::percent_decode('abc%gh'), 'abc%gh');
	is(WHATWG::URL::percent_decode('abc%25'), 'abc%');
	is(WHATWG::URL::percent_decode('abc%00def'), "abc\x00def");
	is(WHATWG::URL::percent_decode('abc%7fdef'), "abc\x7fdef");
	is(WHATWG::URL::percent_decode('abc%24def'), "abc\x24def");
	is(WHATWG::URL::percent_decode('abc%C2%A2def'), "abc\xC2\xA2def");
	is(WHATWG::URL::percent_decode('sm%C3%B6rg%C3%A5sbord'), "sm\xC3\xB6rg\xC3\xA5sbord");
	is(WHATWG::URL::percent_decode('abc%ffdef'), "abc\xffdef");
};

subtest 'utf8_percent_encode' => sub {
	subtest 'c0_control_percent_encode_set' => sub {
		is(WHATWG::URL::utf8_percent_encode("\N{U+0000}", $WHATWG::URL::c0_control_percent_encode_set), '%00');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0001}", $WHATWG::URL::c0_control_percent_encode_set), '%01');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0002}", $WHATWG::URL::c0_control_percent_encode_set), '%02');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0003}", $WHATWG::URL::c0_control_percent_encode_set), '%03');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0004}", $WHATWG::URL::c0_control_percent_encode_set), '%04');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0005}", $WHATWG::URL::c0_control_percent_encode_set), '%05');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0006}", $WHATWG::URL::c0_control_percent_encode_set), '%06');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0007}", $WHATWG::URL::c0_control_percent_encode_set), '%07');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0008}", $WHATWG::URL::c0_control_percent_encode_set), '%08');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0009}", $WHATWG::URL::c0_control_percent_encode_set), '%09');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000A}", $WHATWG::URL::c0_control_percent_encode_set), '%0A');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000B}", $WHATWG::URL::c0_control_percent_encode_set), '%0B');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000C}", $WHATWG::URL::c0_control_percent_encode_set), '%0C');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000D}", $WHATWG::URL::c0_control_percent_encode_set), '%0D');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000E}", $WHATWG::URL::c0_control_percent_encode_set), '%0E');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000F}", $WHATWG::URL::c0_control_percent_encode_set), '%0F');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0010}", $WHATWG::URL::c0_control_percent_encode_set), '%10');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0011}", $WHATWG::URL::c0_control_percent_encode_set), '%11');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0012}", $WHATWG::URL::c0_control_percent_encode_set), '%12');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0013}", $WHATWG::URL::c0_control_percent_encode_set), '%13');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0014}", $WHATWG::URL::c0_control_percent_encode_set), '%14');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0015}", $WHATWG::URL::c0_control_percent_encode_set), '%15');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0016}", $WHATWG::URL::c0_control_percent_encode_set), '%16');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0017}", $WHATWG::URL::c0_control_percent_encode_set), '%17');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0018}", $WHATWG::URL::c0_control_percent_encode_set), '%18');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0019}", $WHATWG::URL::c0_control_percent_encode_set), '%19');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001A}", $WHATWG::URL::c0_control_percent_encode_set), '%1A');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001B}", $WHATWG::URL::c0_control_percent_encode_set), '%1B');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001C}", $WHATWG::URL::c0_control_percent_encode_set), '%1C');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001D}", $WHATWG::URL::c0_control_percent_encode_set), '%1D');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001E}", $WHATWG::URL::c0_control_percent_encode_set), '%1E');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001F}", $WHATWG::URL::c0_control_percent_encode_set), '%1F');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0020}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+0020}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+0021}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+0021}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+0022}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+0022}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+0023}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+0023}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+0024}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+0024}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+002F}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+002F}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+003A}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+003A}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+003B}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+003B}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+003C}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+003C}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+003D}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+003D}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+003E}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+003E}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+003F}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+003F}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+0040}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+0040}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+005A}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+005A}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+005B}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+005B}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+005C}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+005C}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+005D}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+005D}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+005E}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+005E}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+005F}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+005F}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+0060}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+0060}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+007A}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+007A}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+007B}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+007B}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+007C}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+007C}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+007D}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+007D}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+007E}", $WHATWG::URL::c0_control_percent_encode_set), "\N{U+007E}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+007F}", $WHATWG::URL::c0_control_percent_encode_set), '%7F');
		is(WHATWG::URL::utf8_percent_encode("\N{U+00A2}", $WHATWG::URL::c0_control_percent_encode_set), '%C2%A2');
		is(WHATWG::URL::utf8_percent_encode("\N{U+00FE}", $WHATWG::URL::c0_control_percent_encode_set), '%C3%BE');
		is(WHATWG::URL::utf8_percent_encode("\N{U+00FF}", $WHATWG::URL::c0_control_percent_encode_set), '%C3%BF');
		is(WHATWG::URL::utf8_percent_encode("\N{U+20AC}", $WHATWG::URL::c0_control_percent_encode_set), '%E2%82%AC');
		is(WHATWG::URL::utf8_percent_encode("\N{U+10348}", $WHATWG::URL::c0_control_percent_encode_set), '%F0%90%8D%88');
	};

	subtest 'path_percent_encode_set' => sub {
		is(WHATWG::URL::utf8_percent_encode("\N{U+0000}", $WHATWG::URL::path_percent_encode_set), '%00');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0001}", $WHATWG::URL::path_percent_encode_set), '%01');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0002}", $WHATWG::URL::path_percent_encode_set), '%02');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0003}", $WHATWG::URL::path_percent_encode_set), '%03');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0004}", $WHATWG::URL::path_percent_encode_set), '%04');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0005}", $WHATWG::URL::path_percent_encode_set), '%05');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0006}", $WHATWG::URL::path_percent_encode_set), '%06');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0007}", $WHATWG::URL::path_percent_encode_set), '%07');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0008}", $WHATWG::URL::path_percent_encode_set), '%08');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0009}", $WHATWG::URL::path_percent_encode_set), '%09');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000A}", $WHATWG::URL::path_percent_encode_set), '%0A');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000B}", $WHATWG::URL::path_percent_encode_set), '%0B');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000C}", $WHATWG::URL::path_percent_encode_set), '%0C');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000D}", $WHATWG::URL::path_percent_encode_set), '%0D');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000E}", $WHATWG::URL::path_percent_encode_set), '%0E');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000F}", $WHATWG::URL::path_percent_encode_set), '%0F');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0010}", $WHATWG::URL::path_percent_encode_set), '%10');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0011}", $WHATWG::URL::path_percent_encode_set), '%11');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0012}", $WHATWG::URL::path_percent_encode_set), '%12');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0013}", $WHATWG::URL::path_percent_encode_set), '%13');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0014}", $WHATWG::URL::path_percent_encode_set), '%14');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0015}", $WHATWG::URL::path_percent_encode_set), '%15');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0016}", $WHATWG::URL::path_percent_encode_set), '%16');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0017}", $WHATWG::URL::path_percent_encode_set), '%17');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0018}", $WHATWG::URL::path_percent_encode_set), '%18');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0019}", $WHATWG::URL::path_percent_encode_set), '%19');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001A}", $WHATWG::URL::path_percent_encode_set), '%1A');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001B}", $WHATWG::URL::path_percent_encode_set), '%1B');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001C}", $WHATWG::URL::path_percent_encode_set), '%1C');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001D}", $WHATWG::URL::path_percent_encode_set), '%1D');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001E}", $WHATWG::URL::path_percent_encode_set), '%1E');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001F}", $WHATWG::URL::path_percent_encode_set), '%1F');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0020}", $WHATWG::URL::path_percent_encode_set), '%20');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0021}", $WHATWG::URL::path_percent_encode_set), "\N{U+0021}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+0022}", $WHATWG::URL::path_percent_encode_set), '%22');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0023}", $WHATWG::URL::path_percent_encode_set), '%23');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0024}", $WHATWG::URL::path_percent_encode_set), "\N{U+0024}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+002F}", $WHATWG::URL::path_percent_encode_set), "\N{U+002F}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+003A}", $WHATWG::URL::path_percent_encode_set), "\N{U+003A}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+003B}", $WHATWG::URL::path_percent_encode_set), "\N{U+003B}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+003C}", $WHATWG::URL::path_percent_encode_set), '%3C');
		is(WHATWG::URL::utf8_percent_encode("\N{U+003D}", $WHATWG::URL::path_percent_encode_set), "\N{U+003D}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+003E}", $WHATWG::URL::path_percent_encode_set), '%3E');
		is(WHATWG::URL::utf8_percent_encode("\N{U+003F}", $WHATWG::URL::path_percent_encode_set), '%3F');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0040}", $WHATWG::URL::path_percent_encode_set), "\N{U+0040}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+005A}", $WHATWG::URL::path_percent_encode_set), "\N{U+005A}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+005B}", $WHATWG::URL::path_percent_encode_set), "\N{U+005B}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+005C}", $WHATWG::URL::path_percent_encode_set), "\N{U+005C}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+005D}", $WHATWG::URL::path_percent_encode_set), "\N{U+005D}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+005E}", $WHATWG::URL::path_percent_encode_set), "\N{U+005E}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+005F}", $WHATWG::URL::path_percent_encode_set), "\N{U+005F}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+0060}", $WHATWG::URL::path_percent_encode_set), '%60');
		is(WHATWG::URL::utf8_percent_encode("\N{U+007A}", $WHATWG::URL::path_percent_encode_set), "\N{U+007A}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+007B}", $WHATWG::URL::path_percent_encode_set), '%7B');
		is(WHATWG::URL::utf8_percent_encode("\N{U+007C}", $WHATWG::URL::path_percent_encode_set), "\N{U+007C}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+007D}", $WHATWG::URL::path_percent_encode_set), '%7D');
		is(WHATWG::URL::utf8_percent_encode("\N{U+007E}", $WHATWG::URL::path_percent_encode_set), "\N{U+007E}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+007F}", $WHATWG::URL::path_percent_encode_set), '%7F');
		is(WHATWG::URL::utf8_percent_encode("\N{U+00A2}", $WHATWG::URL::path_percent_encode_set), '%C2%A2');
		is(WHATWG::URL::utf8_percent_encode("\N{U+00FE}", $WHATWG::URL::path_percent_encode_set), '%C3%BE');
		is(WHATWG::URL::utf8_percent_encode("\N{U+00FF}", $WHATWG::URL::path_percent_encode_set), '%C3%BF');
		is(WHATWG::URL::utf8_percent_encode("\N{U+20AC}", $WHATWG::URL::path_percent_encode_set), '%E2%82%AC');
		is(WHATWG::URL::utf8_percent_encode("\N{U+10348}", $WHATWG::URL::path_percent_encode_set), '%F0%90%8D%88');
	};

	subtest 'userinfo_percent_encode_set' => sub {
		is(WHATWG::URL::utf8_percent_encode("\N{U+0000}", $WHATWG::URL::userinfo_percent_encode_set), '%00');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0001}", $WHATWG::URL::userinfo_percent_encode_set), '%01');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0002}", $WHATWG::URL::userinfo_percent_encode_set), '%02');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0003}", $WHATWG::URL::userinfo_percent_encode_set), '%03');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0004}", $WHATWG::URL::userinfo_percent_encode_set), '%04');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0005}", $WHATWG::URL::userinfo_percent_encode_set), '%05');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0006}", $WHATWG::URL::userinfo_percent_encode_set), '%06');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0007}", $WHATWG::URL::userinfo_percent_encode_set), '%07');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0008}", $WHATWG::URL::userinfo_percent_encode_set), '%08');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0009}", $WHATWG::URL::userinfo_percent_encode_set), '%09');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000A}", $WHATWG::URL::userinfo_percent_encode_set), '%0A');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000B}", $WHATWG::URL::userinfo_percent_encode_set), '%0B');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000C}", $WHATWG::URL::userinfo_percent_encode_set), '%0C');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000D}", $WHATWG::URL::userinfo_percent_encode_set), '%0D');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000E}", $WHATWG::URL::userinfo_percent_encode_set), '%0E');
		is(WHATWG::URL::utf8_percent_encode("\N{U+000F}", $WHATWG::URL::userinfo_percent_encode_set), '%0F');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0010}", $WHATWG::URL::userinfo_percent_encode_set), '%10');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0011}", $WHATWG::URL::userinfo_percent_encode_set), '%11');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0012}", $WHATWG::URL::userinfo_percent_encode_set), '%12');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0013}", $WHATWG::URL::userinfo_percent_encode_set), '%13');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0014}", $WHATWG::URL::userinfo_percent_encode_set), '%14');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0015}", $WHATWG::URL::userinfo_percent_encode_set), '%15');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0016}", $WHATWG::URL::userinfo_percent_encode_set), '%16');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0017}", $WHATWG::URL::userinfo_percent_encode_set), '%17');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0018}", $WHATWG::URL::userinfo_percent_encode_set), '%18');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0019}", $WHATWG::URL::userinfo_percent_encode_set), '%19');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001A}", $WHATWG::URL::userinfo_percent_encode_set), '%1A');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001B}", $WHATWG::URL::userinfo_percent_encode_set), '%1B');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001C}", $WHATWG::URL::userinfo_percent_encode_set), '%1C');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001D}", $WHATWG::URL::userinfo_percent_encode_set), '%1D');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001E}", $WHATWG::URL::userinfo_percent_encode_set), '%1E');
		is(WHATWG::URL::utf8_percent_encode("\N{U+001F}", $WHATWG::URL::userinfo_percent_encode_set), '%1F');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0020}", $WHATWG::URL::userinfo_percent_encode_set), '%20');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0021}", $WHATWG::URL::userinfo_percent_encode_set), "\N{U+0021}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+0022}", $WHATWG::URL::userinfo_percent_encode_set), '%22');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0023}", $WHATWG::URL::userinfo_percent_encode_set), '%23');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0024}", $WHATWG::URL::userinfo_percent_encode_set), "\N{U+0024}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+002F}", $WHATWG::URL::userinfo_percent_encode_set), '%2F');
		is(WHATWG::URL::utf8_percent_encode("\N{U+003A}", $WHATWG::URL::userinfo_percent_encode_set), '%3A');
		is(WHATWG::URL::utf8_percent_encode("\N{U+003B}", $WHATWG::URL::userinfo_percent_encode_set), '%3B');
		is(WHATWG::URL::utf8_percent_encode("\N{U+003C}", $WHATWG::URL::userinfo_percent_encode_set), '%3C');
		is(WHATWG::URL::utf8_percent_encode("\N{U+003D}", $WHATWG::URL::userinfo_percent_encode_set), '%3D');
		is(WHATWG::URL::utf8_percent_encode("\N{U+003E}", $WHATWG::URL::userinfo_percent_encode_set), '%3E');
		is(WHATWG::URL::utf8_percent_encode("\N{U+003F}", $WHATWG::URL::userinfo_percent_encode_set), '%3F');
		is(WHATWG::URL::utf8_percent_encode("\N{U+0040}", $WHATWG::URL::userinfo_percent_encode_set), '%40');
		is(WHATWG::URL::utf8_percent_encode("\N{U+005A}", $WHATWG::URL::userinfo_percent_encode_set), "\N{U+005A}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+005B}", $WHATWG::URL::userinfo_percent_encode_set), '%5B');
		is(WHATWG::URL::utf8_percent_encode("\N{U+005C}", $WHATWG::URL::userinfo_percent_encode_set), '%5C');
		is(WHATWG::URL::utf8_percent_encode("\N{U+005D}", $WHATWG::URL::userinfo_percent_encode_set), '%5D');
		is(WHATWG::URL::utf8_percent_encode("\N{U+005E}", $WHATWG::URL::userinfo_percent_encode_set), '%5E');
		is(WHATWG::URL::utf8_percent_encode("\N{U+005F}", $WHATWG::URL::userinfo_percent_encode_set), "\N{U+005F}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+0060}", $WHATWG::URL::userinfo_percent_encode_set), '%60');
		is(WHATWG::URL::utf8_percent_encode("\N{U+007A}", $WHATWG::URL::userinfo_percent_encode_set), "\N{U+007A}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+007B}", $WHATWG::URL::userinfo_percent_encode_set), '%7B');
		is(WHATWG::URL::utf8_percent_encode("\N{U+007C}", $WHATWG::URL::userinfo_percent_encode_set), '%7C');
		is(WHATWG::URL::utf8_percent_encode("\N{U+007D}", $WHATWG::URL::userinfo_percent_encode_set), '%7D');
		is(WHATWG::URL::utf8_percent_encode("\N{U+007E}", $WHATWG::URL::userinfo_percent_encode_set), "\N{U+007E}");
		is(WHATWG::URL::utf8_percent_encode("\N{U+007F}", $WHATWG::URL::userinfo_percent_encode_set), '%7F');
		is(WHATWG::URL::utf8_percent_encode("\N{U+00A2}", $WHATWG::URL::userinfo_percent_encode_set), '%C2%A2');
		is(WHATWG::URL::utf8_percent_encode("\N{U+00FE}", $WHATWG::URL::userinfo_percent_encode_set), '%C3%BE');
		is(WHATWG::URL::utf8_percent_encode("\N{U+00FF}", $WHATWG::URL::userinfo_percent_encode_set), '%C3%BF');
		is(WHATWG::URL::utf8_percent_encode("\N{U+20AC}", $WHATWG::URL::userinfo_percent_encode_set), '%E2%82%AC');
		is(WHATWG::URL::utf8_percent_encode("\N{U+10348}", $WHATWG::URL::userinfo_percent_encode_set), '%F0%90%8D%88');
	};
};

#
# 3.3. IDNA
#

subtest 'domain_to_ascii' => sub {
	plan skip_all => 'TODO';
};

#
# 3.5. Host parsing
#

subtest 'host_parse' => sub {
	plan skip_all => 'TODO';
	# is_deeply(WHATWG::URL::host_parse('', 0), '');
	# is_deeply(WHATWG::URL::host_parse('', 1), '');
};

subtest 'ipv4_number_parse' => sub {
	my $r10;
	$r10 = 0;
	is(WHATWG::URL::ipv4_number_parse('', \$r10), 0);
	is($r10, 0);
	$r10 = 0;
	is(WHATWG::URL::ipv4_number_parse('0', \$r10), 0);
	is($r10, 0);
	$r10 = 0;
	is(WHATWG::URL::ipv4_number_parse('123', \$r10), 123);
	is($r10, 0);
	$r10 = 0;
	is(WHATWG::URL::ipv4_number_parse('1239', \$r10), 1239);
	is($r10, 0);
	$r10 = 0;
	is(WHATWG::URL::ipv4_number_parse('123A', \$r10), undef);
	is($r10, 0);
	$r10 = 0;
	is(WHATWG::URL::ipv4_number_parse('123G', \$r10), undef);
	is($r10, 0);

	my $r16;
	$r16 = 0;
	is(WHATWG::URL::ipv4_number_parse('0x', \$r16), 0);
	is($r16, 1);
	$r16 = 0;
	is(WHATWG::URL::ipv4_number_parse('0x0', \$r16), 0x0);
	is($r16, 1);
	$r16 = 0;
	is(WHATWG::URL::ipv4_number_parse('0x123', \$r16), 0x123);
	is($r16, 1);
	$r16 = 0;
	is(WHATWG::URL::ipv4_number_parse('0x1239', \$r16), 0x1239);
	is($r16, 1);
	$r16 = 0;
	is(WHATWG::URL::ipv4_number_parse('0x123A', \$r16), 0x123A);
	is($r16, 1);
	$r16 = 0;
	is(WHATWG::URL::ipv4_number_parse('0x123G', \$r16), undef);
	is($r16, 1);
	$r16 = 0;
	is(WHATWG::URL::ipv4_number_parse('0X', \$r16), 0);
	is($r16, 1);
	$r16 = 0;
	is(WHATWG::URL::ipv4_number_parse('0X0', \$r16), 0x0);
	is($r16, 1);
	$r16 = 0;
	is(WHATWG::URL::ipv4_number_parse('0X123', \$r16), 0x123);
	is($r16, 1);
	$r16 = 0;
	is(WHATWG::URL::ipv4_number_parse('0X1239', \$r16), 0x1239);
	is($r16, 1);
	$r16 = 0;
	is(WHATWG::URL::ipv4_number_parse('0X123A', \$r16), 0x123A);
	is($r16, 1);
	$r16 = 0;
	is(WHATWG::URL::ipv4_number_parse('0X123G', \$r16), undef);
	is($r16, 1);

	my $r8;
	$r8 = 0;
	is(WHATWG::URL::ipv4_number_parse('00', \$r8), 00);
	is($r8, 1);
	$r8 = 0;
	is(WHATWG::URL::ipv4_number_parse('0123', \$r8), 0123);
	is($r8, 1);
	$r8 = 0;
	is(WHATWG::URL::ipv4_number_parse('01239', \$r8), undef);
	is($r8, 1);
	$r8 = 0;
	is(WHATWG::URL::ipv4_number_parse('0123A', \$r8), undef);
	is($r8, 1);
	$r8 = 0;
	is(WHATWG::URL::ipv4_number_parse('0123G', \$r8), undef);
	is($r8, 1);
};

subtest 'ipv4_parse' => sub {
	is(WHATWG::URL::ipv4_parse('0.0.0.0'), 0);
	is(WHATWG::URL::ipv4_parse('0.0.0.1'), 1);
	is(WHATWG::URL::ipv4_parse('0.0.1.0'), 256);
	is(WHATWG::URL::ipv4_parse('0.1.0.0'), 65536);
	is(WHATWG::URL::ipv4_parse('1.0.0.0'), 16777216);
	is(WHATWG::URL::ipv4_parse('127.0.0.1'), 2130706433);
	is(WHATWG::URL::ipv4_parse('255.255.255.255'), 4294967295);
	is(WHATWG::URL::ipv4_parse(''), '');
	is(WHATWG::URL::ipv4_parse('.'), '.');
	is(WHATWG::URL::ipv4_parse('1.1.1.1.1'), '1.1.1.1.1');
	is(WHATWG::URL::ipv4_parse('a.b.c.d'), 'a.b.c.d');
	is(WHATWG::URL::ipv4_parse('0xa.0xb.0xc.0xd'), 168496141);
	is(WHATWG::URL::ipv4_parse('e.f.g.h'), 'e.f.g.h');
	is(WHATWG::URL::ipv4_parse('0xe.0xf.0xg.0xh'), '0xe.0xf.0xg.0xh');
	is(WHATWG::URL::ipv4_parse('0..0x300'), '0..0x300');
	is(WHATWG::URL::ipv4_parse('255.255.256'), 4294902016);
	is(WHATWG::URL::ipv4_parse('256.256.256.256'), undef);
	is(WHATWG::URL::ipv4_parse('4294967295'), 4294967295);
	is(WHATWG::URL::ipv4_parse('0.4294967295'), undef);
	is(WHATWG::URL::ipv4_parse('4294967296'), '4294967296');
	is(WHATWG::URL::ipv4_parse('0.4294967296'), undef);
};

subtest 'ipv6_parse' => sub {
	is_deeply(WHATWG::URL::ipv6_parse(''), undef);
	is_deeply(WHATWG::URL::ipv6_parse(':'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('0:0:0:0:0:0:0:0:0'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('0000:0000:0000:0000:0000:0000:0000:0000:0000'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('::1:1:1:1:1:1:1:1'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('1:1:1:1::1:1:1:1'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('1:1:1:1:1:1:1:1::'), undef);
	is_deeply(WHATWG::URL::ipv6_parse(':::'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('.'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('0001:0001:0001:0001:0001:0001:0001:127.0.0.1'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('::127.0.0.0.1'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('::127.0:0:0:1'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('::127.0.f.1'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('::127.0.0.01'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('::127.0.0.256'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('::256.0.0.1'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('::0.1'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('0:0:0:0:0:0:0:0:'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('0000:0000:0000:0000:0000:0000:0000:0000:'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('0:0:0:0:0:0:0:0x'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('0000:0000:0000:0000:0000:0000:0000:0000x'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('::FFFFFF'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('FFFFFF::1'), undef);
	is_deeply(WHATWG::URL::ipv6_parse('127.0.0.1'), undef);

	is_deeply(WHATWG::URL::ipv6_parse('0:0:0:0:0:0:0:0'), [ 0, 0, 0, 0, 0, 0, 0, 0 ]);
	is_deeply(WHATWG::URL::ipv6_parse('0000:0000:0000:0000:0000:0000:0000:0000'), [ 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000 ]);
	is_deeply(WHATWG::URL::ipv6_parse('1:1:1:1:1:1:1:1'), [ 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1 ]);
	is_deeply(WHATWG::URL::ipv6_parse('0001:0001:0001:0001:0001:0001:0001:0001'), [ 0x0001, 0x0001, 0x0001, 0x0001, 0x0001, 0x0001, 0x0001, 0x0001 ]);
	is_deeply(WHATWG::URL::ipv6_parse('f:f:f:f:f:f:f:f'), [ 0xF, 0xF, 0xF, 0xF, 0xF, 0xF, 0xF, 0xF ]);
	is_deeply(WHATWG::URL::ipv6_parse('FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF'), [ 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF ]);
	is_deeply(WHATWG::URL::ipv6_parse('::'), [ 0, 0, 0, 0, 0, 0, 0, 0 ]);
	is_deeply(WHATWG::URL::ipv6_parse('::0'), [ 0, 0, 0, 0, 0, 0, 0, 0 ]);
	is_deeply(WHATWG::URL::ipv6_parse('0::0'), [ 0, 0, 0, 0, 0, 0, 0, 0 ]);
	is_deeply(WHATWG::URL::ipv6_parse('::127.0.0.1'), [ 0, 0, 0, 0, 0, 0, 0x7F00, 0x0001 ]);
	is_deeply(WHATWG::URL::ipv6_parse('0001:0001:0001:0001:0001:0001:127.0.0.1'), [ 0x0001, 0x0001, 0x0001, 0x0001, 0x0001, 0x0001, 0x7F00, 0x0001 ]);
};

subtest 'opaque_host_parse' => sub {
	is(WHATWG::URL::opaque_host_parse(''), '');
	is(WHATWG::URL::opaque_host_parse('ab'), 'ab');
	is(WHATWG::URL::opaque_host_parse("a\N{U+0000}b"), undef);
	is(WHATWG::URL::opaque_host_parse("a\N{U+0009}b"), undef);
	is(WHATWG::URL::opaque_host_parse("a\N{U+000A}b"), undef);
	is(WHATWG::URL::opaque_host_parse("a\N{U+000D}b"), undef);
	is(WHATWG::URL::opaque_host_parse("a\N{U+0020}b"), undef);
	is(WHATWG::URL::opaque_host_parse("a\N{U+0023}b"), undef);
	is(WHATWG::URL::opaque_host_parse("a\N{U+0025}b"), "a\N{U+0025}b");
	is(WHATWG::URL::opaque_host_parse("a\N{U+002F}b"), undef);
	is(WHATWG::URL::opaque_host_parse("a\N{U+003A}b"), undef);
	is(WHATWG::URL::opaque_host_parse("a\N{U+003F}b"), undef);
	is(WHATWG::URL::opaque_host_parse("a\N{U+0040}b"), undef);
	is(WHATWG::URL::opaque_host_parse("a\N{U+005B}b"), undef);
	is(WHATWG::URL::opaque_host_parse("a\N{U+005C}b"), undef);
	is(WHATWG::URL::opaque_host_parse("a\N{U+005D}b"), undef);
	is(WHATWG::URL::opaque_host_parse("a\N{U+0024}b"), "a\N{U+0024}b");
	is(WHATWG::URL::opaque_host_parse("a\N{U+00A2}b"), 'a%C2%A2b');
	is(WHATWG::URL::opaque_host_parse("a\N{U+20AC}b"), 'a%E2%82%ACb');
	is(WHATWG::URL::opaque_host_parse("a\N{U+10348}b"), 'a%F0%90%8D%88b');
};

#
# 3.6. Host serializing
#

subtest 'host_serialize' => sub {
	plan skip_all => 'TODO';
};

subtest 'ipv4_serialize' => sub {
	my @i = ( 0x00, 0x01, 0x0F, 0x7F, 0xFF );
	foreach my $w (@i) {
		foreach my $x (@i) {
			foreach my $y (@i) {
				foreach my $z (@i) {
					my $ipv4 = $w;
					$ipv4 = $ipv4 << 8 | $x;
					$ipv4 = $ipv4 << 8 | $y;
					$ipv4 = $ipv4 << 8 | $z;

					is(WHATWG::URL::ipv4_serialize($ipv4), "$w.$x.$y.$z");
				}
			}
		}
	}

	# Everything above 0xFFFFFFFF is discarded.
	foreach my $v (@i) {
		is(WHATWG::URL::ipv4_serialize($v << 32), '0.0.0.0');
	}
};

subtest 'ipv6_serialize' => sub {
	is(WHATWG::URL::ipv6_serialize([ 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000 ]), '::');
	is(WHATWG::URL::ipv6_serialize([ 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0001 ]), '::1');
	is(WHATWG::URL::ipv6_serialize([ 0x0001, 0x0001, 0x0001, 0x0001, 0x0001, 0x0001, 0x0001, 0x0001 ]), '1:1:1:1:1:1:1:1');
	is(WHATWG::URL::ipv6_serialize([ 0x0000, 0x0001, 0x0000, 0x0001, 0x0000, 0x0001, 0x0000, 0x0001 ]), '0:1:0:1:0:1:0:1');
	is(WHATWG::URL::ipv6_serialize([ 0x0001, 0x0000, 0x0001, 0x0000, 0x0001, 0x0000, 0x0001, 0x0000 ]), '1:0:1:0:1:0:1:0');
	is(WHATWG::URL::ipv6_serialize([ 0x0001, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0001 ]), '1::1');
	is(WHATWG::URL::ipv6_serialize([ 0xF, 0xF, 0xF, 0xF, 0xF, 0xF, 0xF, 0xF ]), 'f:f:f:f:f:f:f:f');
	is(WHATWG::URL::ipv6_serialize([ 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF ]), 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff');
};

###

done_testing();

######

# is(WHATWG::URL->basic_url_parse('http://example.org/')->serialize(), 'http://example.org/');
# is(WHATWG::URL->basic_url_parse('http://example.org/test')->serialize(), 'http://example.org/test');
# is(WHATWG::URL->basic_url_parse('http://username:password@example.org/test/ing')->serialize(), 'http://username:password@example.org/test/ing');

# is(WHATWG::URL->basic_url_parse(''), undef);
# is(WHATWG::URL->basic_url_parse('about:blank')->serialize(), 'about:blank');

# # 4. URLs
# is(WHATWG::URL->basic_url_parse('https:example.org')->serialize(), 'https://example.org/');
# is(WHATWG::URL->basic_url_parse('https://////example.com///')->serialize(), 'https://example.com///');
# is(WHATWG::URL->basic_url_parse('https://example.com/././foo')->serialize(), 'https://example.com/foo');
# is(WHATWG::URL->basic_url_parse('hello:world', WHATWG::URL->basic_url_parse('https://example.com/'))->serialize(), 'hello:world');
# is(WHATWG::URL->basic_url_parse('https:example.org', WHATWG::URL->basic_url_parse('https://example.com/'))->serialize(), 'https://example.com/example.org');
# is(WHATWG::URL->basic_url_parse('\example\..\demo/.\\', WHATWG::URL->basic_url_parse('https://example.com/'))->serialize(), 'https://example.com/demo/');
# is(WHATWG::URL->basic_url_parse('example', WHATWG::URL->basic_url_parse('https://example.com/demo'))->serialize(), 'https://example.com/example');
# is(WHATWG::URL->basic_url_parse('file:///C|/demo')->serialize(), 'file:///C:/demo');
# is(WHATWG::URL->basic_url_parse('..', WHATWG::URL->basic_url_parse('file:///C:/demo'))->serialize(), 'file:///C:/');
# is(WHATWG::URL->basic_url_parse('file://loc%61lhost/')->serialize(), 'file:///');
# is(WHATWG::URL->basic_url_parse('https://user:password@example.org/')->serialize(), 'https://user:password@example.org/');
# is(WHATWG::URL->basic_url_parse('https://example.org/foo bar')->serialize(), 'https://example.org/foo%20bar');
# is(WHATWG::URL->basic_url_parse('https://EXAMPLE.com/../x')->serialize(), 'https://example.com/x');
# is(WHATWG::URL->basic_url_parse('https://ex ample.org/'), undef);
# is(WHATWG::URL->basic_url_parse('example'), undef);
# is(WHATWG::URL->basic_url_parse('https://example.com:demo'), undef);
# is(WHATWG::URL->basic_url_parse('http://[www.example.com]/'), undef);

# #
# # Debug
# #

# is(WHATWG::URL->basic_url_parse('http://192.168.001.001:80/')->serialize(), 'http://192.168.1.1/');
# # is(WHATWG::URL->basic_url_parse('non-special://192.168.001.001:80/')->serialize(), 'non-special://192.168.1.1:80/');
# is(WHATWG::URL->basic_url_parse('http://[0:f:0:0:f:f:0:0]:80/')->serialize(), 'http://[0:f::f:f:0:0]/');
# is(WHATWG::URL->basic_url_parse('non-special://[1:2::3]:80/')->serialize(), 'non-special://[1:2::3]:80/');

# is(WHATWG::URL->basic_url_parse('http://192.0x00A80001')->serialize(), 'http://192.168.0.1/');
# is(WHATWG::URL->basic_url_parse('http://%30%78%63%30%2e%30%32%35%30.01%2e')->serialize(), 'http://192.168.0.1/');

# is(WHATWG::URL->basic_url_parse('http://255.255.255.255/')->serialize(), 'http://255.255.255.255/');

# is(WHATWG::URL->basic_url_parse('http://192.168.257', WHATWG::URL->basic_url_parse('http://example.com/'))->serialize(), 'http://192.168.1.1/');
# is(WHATWG::URL->basic_url_parse('http://192.168.257.com', WHATWG::URL->basic_url_parse('http://example.com/'))->serialize(), 'http://192.168.257.com/');

# is(WHATWG::URL->basic_url_parse('https://0x.0x.0', WHATWG::URL->basic_url_parse('about:blank'))->serialize(), 'https://0.0.0.0/');

# is(WHATWG::URL->basic_url_parse('', WHATWG::URL->basic_url_parse('http://user:pass@example.org:21/smth'))->serialize(), 'http://user:pass@example.org:21/smth');

# is(WHATWG::URL->basic_url_parse('', WHATWG::URL->basic_url_parse('file:///path?quer#frag'))->serialize(), 'file:///path?quer');
# is(WHATWG::URL->basic_url_parse('file:', WHATWG::URL->basic_url_parse('file:///path?quer#frag'))->serialize(), 'file:///path?quer');

# TODO: {
# 	local $TODO = 'Net::IDN::UTS46 has issues';

# 	is(WHATWG::URL::domain_to_ascii('.'), '.');
# 	is(WHATWG::URL::domain_to_ascii('..'), '..');

# 	is(WHATWG::URL->basic_url_parse('http://10000000000', WHATWG::URL->basic_url_parse('http://example.com/')), undef);
# 	is(WHATWG::URL->basic_url_parse('http://4294967296', WHATWG::URL->basic_url_parse('http://example.com/')), undef);
# 	is(WHATWG::URL->basic_url_parse('http://0xffffffff1', WHATWG::URL->basic_url_parse('http://example.com/')), undef);
# 	is(WHATWG::URL->basic_url_parse('http://256.256.256.256', WHATWG::URL->basic_url_parse('http://example.com/')), undef);
# }

# # is(WHATWG::URL->basic_url_parse('http://./', WHATWG::URL->basic_url_parse('about:blank'))->serialize(), 'http://./');
# # is(WHATWG::URL->basic_url_parse('http://./', WHATWG::URL->basic_url_parse('http://example.org/'))->serialize(), 'http://./');
# # is(WHATWG::URL->basic_url_parse('http://../', WHATWG::URL->basic_url_parse('about:blank'))->serialize(), 'http://../');
# # is(WHATWG::URL->basic_url_parse('http://../', WHATWG::URL->basic_url_parse('http://example.org/'))->serialize(), 'http://../');
# is(WHATWG::URL->basic_url_parse('http://0..0x300/', WHATWG::URL->basic_url_parse('about:blank'))->serialize(), 'http://0..0x300/');

# done_testing();
