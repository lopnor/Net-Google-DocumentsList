use t::Util;
use Test::More;

my $service = service();

my $d = $service->add_item(
    {
        title => join(' - ', 'test for revision', scalar localtime),
        kind => 'document',
    }
);
ok $d->title($d->title . ' - modified');
ok my @rev = $d->revisions;

for (@rev) {
    warn $_->atom->as_xml;
    ok $_->content_url, $_->content_url;
}

$d->delete({delete => 'true'});

done_testing;
