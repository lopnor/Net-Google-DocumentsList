use t::Util;
use Test::More;

my $service = service();

my $title = join(' - ', 'test for folder', scalar localtime);

ok my $folder = $service->add_document(
    {
        title => $title,
        kind => 'folder',
    }
);

sleep 6;
my $found;
until ($found) {
    $found = $service->document(
        { 
            title => $title,
            category => 'folder',
        },
    );
    sleep 3;
}

is $found->id, $folder->id;
$folder->delete({delete => 'ture'});
ok ! $service->document(
    {
        title => $title,
        category => 'folder',
    }
);

done_testing;
