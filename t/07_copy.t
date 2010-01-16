use t::Util;
use Test::More;

my $service = service();

my $title = join(' - ', 'test for copy', scalar localtime);
my $copied_title = join(' - ', 'test for copy, copied', scalar localtime);
ok my $doc = $service->add_item( { title => $title, kind => 'document' } );
ok my $copied = $doc->copy($copied_title);
is $copied->title, $copied_title;

ok my $found = $service->item({title => $copied_title, category => 'document'});
is $found->title, $copied_title;
ok $doc->delete({delete => 1});
ok $copied->delete({delete => 1});

done_testing;
