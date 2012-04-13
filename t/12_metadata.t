use utf8;
use t::Util;
use Test::More;

my $service = service();

ok my $metadata = $service->metadata;
ok my $max = $metadata->max_upload_size;
note explain $max;
ok my $import = $metadata->import_format;
note explain $import;
ok my $export = $metadata->export_format;
note explain $export;
note $metadata->atom->as_xml;

done_testing;
