package Net::Google::DocumentsList::Revision;
use Any::Moose;
use namespace::autoclean;
use Net::Google::DataAPI;
with 'Net::Google::DataAPI::Role::Entry';

__PACKAGE__->meta->make_immutable;

1;
