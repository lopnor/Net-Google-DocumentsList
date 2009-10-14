use t::Util;
use Test::More;

ok my $service = service();

my @list = $service->documents;
ok scalar(@list);

done_testing;
