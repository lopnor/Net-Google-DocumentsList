use t::Util;
use Test::More;

ok my $service = service();

ok my $d = $service->document;
my @acl = $d->acls;
ok scalar @acl;

done_testing;
