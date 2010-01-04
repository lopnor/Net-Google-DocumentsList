package Net::Google::DocumentsList::ACL;
use Any::Moose;
use namespace::autoclean;
use Net::Google::DataAPI;
use XML::Atom::Util qw(first);
use Net::Google::DocumentsList::Types;
with 'Net::Google::DataAPI::Role::Entry';

entry_has 'updated' => ( tagname => 'updated', is => 'ro' );
entry_has 'role' => (
    is => 'rw',
    from_atom => sub {
        my ($self, $atom) = @_;
        first($atom->elem, $self->ns('gAcl')->{uri}, 'role')->getAttribute('value');
    },
    to_atom => sub {
        my ($self, $atom) = @_;
        $atom->set($self->ns('gAcl'),'role', '', {value => $self->role});
    }
);
entry_has 'scope' => (
    is => 'rw',
    isa => 'Net::Google::DocumentsList::Types::ACL::Scope',
    from_atom => sub {
        my ($self, $atom) = @_;
        my $elem = first($atom->elem, $self->ns('gAcl')->{uri}, 'scope');
        return {
            value => $elem->getAttribute('value'),
            type  => $elem->getAttribute('type'),
        };
    },
    to_atom => sub {
        my ($self, $atom) = @_;
        $atom->set($self->ns('gAcl'),'scope', '', $self->scope);
    },
);

sub update {
    my ($self) = @_;
    $self->etag or return;
    # put without etag!
    my $atom = $self->service->request(
        {
            method => 'PUT',
            uri => $self->editurl,
            content => $self->to_atom->as_xml,
            content_type => 'application/atom+xml',
            response_object => 'XML::Atom::Entry',
        }
    );
    $self->container->sync;
    $self->atom($atom);
}

sub delete {
    my ($self) = @_;
    # delete without etag!
    my $res = $self->service->request(
        {
            method => 'DELETE',
            uri => $self->editurl,
        }
    );
    $self->container->sync;
    return $res->is_success;
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::Google::DocumentsList::ACL - Access Control List object for Google Documents List Data API

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
      if $rev->updated
  }

=head1 DESCRIPTION

This module represents Access Control List object for Google Documents List Data API.

=head1 METHODS

=head2 add_acl ( implemented in Net::Google::DocumentsList::Item object )

adds new ACL to document or folder.

  $doc->add_acl(
    role => 'reader',
    scope => {
        type => 'user',
        value => 'foo.bar@gmail.com',
    }
  );

=head2 delete

delete the acl from attached document or folder.

=head1 ATTRIBUTES

=head2 role

=head2 scope

hashref having 'type' and 'value' keys.

see L<http://code.google.com/intl/en/apis/documents/docs/3.0/developers_guide_protocol.html#AccessControlLists> for details.

=head1 AUTHOR

Noubo Danjou E<lt>nobuo.danjou@gmail.comE<gt>

=head1 SEE ALSO

L<XML::Atom>

L<Net::Google::AuthSub>

L<Net::Google::DataAPI>

L<Net::Google::DocumentsList::Role::HasItems>

L<http://code.google.com/apis/documents/docs/3.0/developers_guide_protocol.html>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
