use inc::Module::Install;
name 'Net-Google-DocumentsList';
all_from 'lib/Net/Google/DocumentsList.pm';

# requires '';
requires 'Net::Google::DataAPI';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
build_requires 'File::BOM';
use_test_base;
auto_include;
WriteAll;
