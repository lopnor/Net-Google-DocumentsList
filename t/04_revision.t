use t::Util;
use Test::More;

plan skip_all => 'revisions dont seem to work';

my $service = service();

TODO: {
    local $TODO = 'revisions dont seem to work';
    my $d = $service->add_document(
        {
            title => join(' - ', 'test for revision', scalar localtime),
            kind => 'document',
        }
    );
    $d->title($d->title . ' - modified');
    ok my @rev = $d->revisions;
}

done_testing;
