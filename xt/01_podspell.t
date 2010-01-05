use Test::More;
eval q{ use Test::Spelling };
plan skip_all => "Test::Spelling is not installed." if $@;
add_stopwords(map { split /[\s\:\-]/ } <DATA>);
$ENV{LANG} = 'C';
all_pod_files_spelling_ok('lib');
__DATA__
Noubo Danjou
nobuo.danjou@gmail.com
Net::Google::DocumentsList
API
acl
acls
pdf
ro
rw
