use t::Util;
use Test::More;

my $service = service();

my $title = join(' - ', 'test for folder', scalar localtime);

ok my $folder = $service->add_item(
    {
        title => $title,
        kind => 'folder',
    }
);

sleep 6;
my $found;
until ($found) {
    $found = $service->item(
        { 
            title => $title,
            category => 'folder',
        },
    );
    sleep 3;
}

is $found->id, $folder->id;

{
    my $subfolder_title = join(' - ', 'test for subfolder', scalar localtime);
    ok my $subfolder = $found->add_folder(
        {
            title => $subfolder_title,
        }
    );
    sleep 10;
    my $found_subfolder = $found->folder({title => $subfolder_title});

    my $doc_title =  join(' - ', 'test for move item', scalar localtime);
    my $doc = $found->add_item(
        {
            kind => 'document',
            title => $doc_title,
        }
    );
    sleep 10; 
    ok my $found_doc = $found->item(
        {
            title => $doc_title,
            'title-exact' => 'true',
        }
    );
    is $found_doc->id, $doc->id;

    ok $doc->move_to($found_subfolder);
    sleep 10;
    ok my $moved_doc = $found_subfolder->item(
        {
            title => $doc_title,
            'title-exact' => 'true',
        }
    );
    is $moved_doc->id, $doc->id;

    $moved_doc->move_out_of($found_subfolder);

    sleep 10;
    TODO: {
        local $TODO = "This might be google's bug";
        ok ! $found_subfolder->item(
            {
                title => $doc_title,
                'title-exact' => 'true',
            }
        );
    }
    ok my $moved_again = $found->item(
        {
            title => $doc_title,
            'title-exact' => 'true',
        }
    );

    $moved_again->delete;

    sleep 10;
    ok $service->item(
        {
            title => $doc_title,
            category => 'trash',
            'title-exact' => 'true',
        }
    );
}


$folder->delete({delete => 'ture'});
ok ! $service->item(
    {
        title => $title,
        category => 'folder',
    }
);

done_testing;
