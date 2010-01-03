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
is scalar @rev, 2;

for (@rev) {
    ok $_->item_feedurl, "url is " . $_->item_feedurl;
    ok $_->title, "title is " . $_->title;
    ok $_->edited, "edited at ". $_->edited;
    ok $_->updated, "updated at ". $_->updated;
    ok $_->author->name, "author name is ". $_->author->name;
    ok eval { $_->export({format => 'txt'}) };
}

$d->delete({delete => 'true'});

done_testing;
