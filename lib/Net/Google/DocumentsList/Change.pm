package Net::Google::DocumentsList::Change;
use Any::Moose;
use Net::Google::DataAPI;
with 'Net::Google::DataAPI::Role::Entry';
use XML::Atom::Util qw(first);

entry_has 'resource_id' => ( tagname => 'resourceId', ns => 'gd', is => 'ro' );
entry_has 'updated' => ( 
    is => 'ro',
    isa => 'Net::Google::DocumentsList::Types::DateTime',
    tagname => 'updated',
    coerce => 1,
);
entry_has 'changestamp' => (is => 'ro', isa => 'Int',
    from_atom => sub {
        my ($self, $atom) = @_;
        my $elem = first($atom->elem, $self->ns('docs')->{uri}, 'changestamp') or return;
        $elem->getAttribute('value');
    }
);
entry_has deleted => ( is => 'ro', isa => 'Bool',
    from_atom => sub {
        my ($self, $atom) = @_;
        first($atom->elem, $self->ns('gd')->{uri}, 'deleted') ? 1 : 0;
    },
);
entry_has removed => ( is => 'ro', isa => 'Bool',
    from_atom => sub {
        my ($self, $atom) = @_;
        first($atom->elem, $self->ns('docs')->{uri}, 'removed') ? 1 : 0;
    },
);

sub item {
    my $self = shift;
    return $self->service->item({resource_id => $self->resource_id});
}

__PACKAGE__->meta->make_immutable;

no Any::Moose;

1;
