package Net::Google::DocumentsList::ACL;
use Any::Moose;
use namespace::autoclean;
use Net::Google::DataAPI;
with 'Net::Google::DataAPI::Role::Entry';

__PACKAGE__->meta->make_immutable;

1;
