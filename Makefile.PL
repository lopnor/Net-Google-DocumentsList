use inc::Module::Install;
name 'Net-Google-DocumentsList';
all_from 'lib/Net/Google/DocumentsList.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
