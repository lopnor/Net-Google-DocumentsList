use t::Util;
use Test::More;

ok my $service = service();

for my $kind (qw(document spreadsheet presentation)) {
    my $title = join('-', 'test for N::G::DL', scalar localtime);

    ok my $d = $service->add_item(
        {
            title => $title,
            kind => $kind,
        }
    );

    my $found;
    sleep 10;
    until ($found) {
        $found = $service->item({title => $title, 'title-exact' => 'true'});
        sleep 3;
    }
    is $found->id, $d->id;

    ok my $cat_found = $service->item(
        {
            title => $title, 
            'title-exact' => 'true',
            category => $kind,
        }
    );
    is $cat_found->id, $d->id;

    my $updated_title = join('-', 'update title', scalar localtime);
    my $old_etag = $d->etag;
    ok $d->title($updated_title);
    is $d->title, $updated_title;
    isnt $d->etag, $old_etag;

    my $updated;
    sleep 15;
    until ($updated) {
        $updated = $service->item({title => $updated_title, 'title-exact' => 'true'});
        sleep 3;
    }
    is $updated->title, $updated_title;
    is $updated->id, $d->id;
    is $updated->etag, $d->etag;

    $d->delete;

    ok ! $service->item({title => $title, 'title-exact' => 'true'});

    ok my $deleted_found = $service->item(
        {
            title => $updated_title,
            'title-exact' => 'true',
            category => [$kind, 'trash'],
        }
    );

    $deleted_found->delete({delete => 1});
    ok ! $service->item(
        {
            title => $title, 
            'title-exact' => 'true',
            category => [$kind, 'trash'],
        }
    );
}

done_testing;
