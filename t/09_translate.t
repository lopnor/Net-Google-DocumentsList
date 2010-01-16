use t::Util;
use Test::More;
use LWP::Simple;

my $service = service();
my $title = join(' - ', 'test for translate', scalar localtime);
ok my $doc = $service->add_item( 
    {
        title => $title, 
        kind => 'document',
        file => 't/data/japanese.txt',
        source_language => 'ja',
        target_language => 'en',
    } 
);
is $doc->title, $title;
like $doc->export({format => 'txt'}), qr{Hello};

ok $doc->delete({delete => 1});

done_testing;
