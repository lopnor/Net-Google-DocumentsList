use t::Util;
use Test::More;
use utf8;
use Encode;
use File::Temp;
use File::BOM;

my $service = service();

my $bom = $File::BOM::enc2bom{'UTF-8'};

my $title = join(' - ', 'test for upload', scalar localtime);

ok my $doc = $service->add_item(
    {
        title => $title,
        file => 't/data/foobar.txt',
    }
);
TODO: {
    local $TODO = 'http://code.google.com/p/gdata-issues/issues/detail?id=1756';
    my $file = File::Temp->new;

    ok eval {
        $doc->export(
            {
                format => 'txt',
                file => $file,
            }
        )
    };
    close $file;
    open my $fh, "<:via(File::BOM)", $file->filename;
    my $content = do {local $/; <$fh>};
    is $content, "foobar";
}

ok $doc->update_content('t/data/hogefuga.txt');

TODO: {
    local $TODO = 'http://code.google.com/p/gdata-issues/issues/detail?id=1756';
    ok my $export = eval { $doc->export({format => 'txt'}) };
    is Encode::encode('utf-8', $export), $bom.'hogefuga';
}

ok $doc->delete({delete => 'true'});

done_testing;
