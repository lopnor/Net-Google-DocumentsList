use t::Util;
use Test::More;

ok my $service = service();

ok my $d = $service->add_item(
    {
        title => join(' - ', 'test for acl', scalar localtime),
        kind => 'document',
    }
);;
my @acl = $d->acls;
ok scalar @acl;

done_testing;
