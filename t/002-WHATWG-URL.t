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

# integer_serialize
is(WHATWG::URL::integer_serialize('0'), 0);
is(WHATWG::URL::integer_serialize('000'), 0);
is(WHATWG::URL::integer_serialize('1'), 1);
is(WHATWG::URL::integer_serialize('001'), 1);
is(WHATWG::URL::integer_serialize('8'), 8);
is(WHATWG::URL::integer_serialize('008'), 8);
is(WHATWG::URL::integer_serialize('10'), 10);
is(WHATWG::URL::integer_serialize('010'), 10);
is(WHATWG::URL::integer_serialize(0x0A), 10);

#
# 1.3. Percent-encoded bytes
#

# percent_encode
is(WHATWG::URL::percent_encode(0), '%00');
is(WHATWG::URL::percent_encode(1), '%01');
is(WHATWG::URL::percent_encode(10), '%0A');
is(WHATWG::URL::percent_encode(16), '%10');
is(WHATWG::URL::percent_encode(0xFF), '%FF');

# percent_decode
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

# utf8_percent_encode / c0_control_percent_encode_set
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

# utf8_percent_encode / path_percent_encode_set
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

# utf8_percent_encode / userinfo_percent_encode_set
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
