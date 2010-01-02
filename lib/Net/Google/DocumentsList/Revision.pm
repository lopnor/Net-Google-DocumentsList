package Net::Google::DocumentsList::Revision;
use Any::Moose;
use namespace::autoclean;
use Net::Google::DataAPI;
with 'Net::Google::DataAPI::Role::Entry';

entry_has 'edited' => ( tagname => 'edited', ns => 'app', is => 'ro' );

feedurl item => (
    is => 'ro',
    as_content_src => 1,
    entry_class => 'Net::Google::DocumentsList::Item',
);

has 'kind' => (is => 'ro', isa => 'Str', default => 'revision');

with 'Net::Google::DocumentsList::Role::Exportable';

__PACKAGE__->meta->make_immutable;

1;
