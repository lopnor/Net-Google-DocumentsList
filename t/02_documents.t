use t::Util;
use Test::More;

ok my $service = service();

my @list = $service->documents;
ok scalar(@list);

ok $list[0]->acl;
#ok $list[0]->revision;

done_testing;
