use t::Util;
use Test::More;

ok my $service = service();

for my $kind (qw(document spreadsheet presentation)) {
    my $title = join('-', 'test for N::G::DL', scalar localtime);

    ok my $d = $service->add_document(
        {
            title => $title,
            kind => $kind,
        }
    );

    my $found;
    sleep 6;
    until ($found) {
        $found = $service->document({title => $title, 'title-exact' => 'true'});
        sleep 3;
    }
    is $found->id, $d->id;

    my $updated_title = join('-', 'update title', scalar localtime);
    my $old_etag = $d->etag;
    ok $d->title($updated_title);
    is $d->title, $updated_title;
    isnt $d->etag, $old_etag;

    my $updated;
    sleep 6;
    until ($updated) {
        $updated = $service->document({title => $updated_title, 'title-exact' => 'true'});
        sleep 3;
    }
    is $updated->title, $updated_title;
    is $updated->id, $d->id;
    is $updated->etag, $d->etag;

    $d->delete({delete => 1});
    ok ! $service->document({title => $title, 'title-exact' => 'true'});
}

done_testing;
