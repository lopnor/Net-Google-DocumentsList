package Net::Google::DocumentsList::Revision;
use Any::Moose;
use Net::Google::DocumentsList::Types;
use namespace::autoclean;
use Net::Google::DataAPI;
with 'Net::Google::DataAPI::Role::Entry';

entry_has 'updated' => ( 
    is => 'ro',
    isa => 'Net::Google::DocumentsList::Types::DateTime',
    tagname => 'updated',
    coerce => 1,
);

feedurl item => (
    is => 'ro',
    as_content_src => 1,
    entry_class => 'Net::Google::DocumentsList::Item',
);

has 'kind' => (is => 'ro', isa => 'Str', default => 'revision');

with 'Net::Google::DocumentsList::Role::Exportable';

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::Google::DocumentsList::Revision - revision object for Google Documents List Data API

=head1 SYNOPSIS

  use Net::Google::DocumentsList;
  
  my $client = Net::Google::DocumentsList->new(
      username => 'myname@gmail.com',
      password => 'p4$$w0rd'
  );
  
  # taking one document
  my $doc = $client->item;
  
  # getting revisions
  my @revisions = $doc->revisions;
  
  for my $rev (@revisions) {
      # checking revision updated time
      if ( $rev->updated < DateTime->now->subtract(days => 1) ) {
      # download a revision
      $rev->export(
          {
              file => 'backup.txt',
              format => 'txt',
          }
      );
      last;
  }

=head1 DESCRIPTION

This module represents revision object for Google Documents List Data API

=head1 METHODS

=head2 export ( implemented in L<Net::Google::DocumentsList::Role::Exportable> )

downloads the revision.

=head1 ATTRIBUTES

=head2 updated

=head1 AUTHOR

Noubo Danjou E<lt>nobuo.danjou@gmail.comE<gt>

=head1 SEE ALSO

L<XML::Atom>

L<Net::Google::DataAPI>

L<Net::Google::DocumentsList::Role::Exportable>

L<http://code.google.com/apis/documents/docs/3.0/developers_guide_protocol.html>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
