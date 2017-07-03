use v5.22;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'WHATWG::URL',
    AUTHOR           => q{Gordon P. Hemsley <me@gphemsley.org>},
    VERSION_FROM     => 'lib/WHATWG/URL.pm',
    ABSTRACT_FROM    => 'lib/WHATWG/URL.pm',
    LICENSE          => 'open_source',  # 'mozilla_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 'v5.22',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
    },
    BUILD_REQUIRES => {
        'Test::More' => '0',
        'Test::Exception' => '0',
        'Devel::Cover' => '0',
        'LWP::UserAgent' => '0',
        'Encode' => '0',
        'JSON' => '0',
    },
    PREREQ_PM => {
        'List::Util' => '1.33',
        'Encode' => '2.21',
        'POSIX' => '0',
        'Net::IDN::UTS46' => '2.500_20170604',
        'WHATWG::Infra' => '0',
    },
    test => { TESTS => 't/000-*.t t/001-*.t t/002-*.t t/004-*.t' },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'WHATWG-URL-*' },
);
