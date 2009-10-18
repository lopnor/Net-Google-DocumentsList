use t::Util;
use Test::More;
use utf8;
use Encode;
use File::Temp;
use File::BOM;

my $service = service();

my $bom = $File::BOM::enc2bom{'UTF-8'};

my $title = join(' - ', 'test for upload', scalar localtime);

ok my $doc = $service->add_document(
    {
        title => $title,
        file => 't/data/foobar.txt',
    }
);
my $file = File::Temp->new;
ok $doc->export(
    {
        format => 'txt',
        file => $file,
    }
);
close $file;
open my $fh, "<:via(File::BOM)", $file->filename;
my $content = do {local $/; <$fh>};
is $content, "foobar";

ok $doc->update_content('t/data/hogefuga.txt');
my $export = $doc->export({format => 'txt'});
is Encode::encode('utf-8', $export), $bom.'hogefuga';

ok $doc->delete({delete => 'true'});

done_testing;
