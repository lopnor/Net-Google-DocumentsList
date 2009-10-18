package Net::Google::DocumentsList;
use Moose;
use Net::Google::DataAPI;
use 5.008001;

our $VERSION = '0.01';

with 'Net::Google::DataAPI::Role::Service' => {
    service => 'writely',
    source => __PACKAGE__.'-'.$VERSION,
    gdata_version => '3.0',
    ns => {
        gAcl => 'http://schemas.google.com/acl/2007',
        batch => 'http://schemas.google.com/gdata/batch',
        docs => 'http://schemas.google.com/docs/2007',
        app => 'http://www.w3.org/2007/app',
    }
};

feedurl document => (
    entry_class => 'Net::Google::DocumentsList::Document',
    default => 'http://docs.google.com/feeds/default/private/full',
    is => 'ro',
);

with 'Net::Google::DocumentsList::Role::HasDocuments';

1;
__END__

=head1 NAME

Net::Google::DocumentsList -

=head1 SYNOPSIS

  use Net::Google::DocumentsList;

=head1 DESCRIPTION

Net::Google::DocumentsList is

=head1 AUTHOR

Noubo Danjou E<lt>nobuo.danjou@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
