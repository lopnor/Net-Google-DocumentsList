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
        $atom->set($self->ns('gAcl'),'role', undef, {value => $self->role});
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
        $atom->set($self->ns('gAcl'),'scope', undef, $self->scope);
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
