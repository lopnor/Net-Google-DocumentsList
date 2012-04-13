package Net::Google::DocumentsList::Metadata;
use Any::Moose;
use Net::Google::DataAPI;
with 'Net::Google::DataAPI::Role::Entry';
use XML::Atom::Util qw(nodelist first);
use String::CamelCase ();

has 'kind' => (is => 'ro', isa => 'Str', default => 'metadata');
entry_has 'updated' => ( tagname => 'updated', is => 'ro' );
entry_has largest_changestamp => (
    is => 'ro',
    isa => 'Int',
    from_atom => sub {
        my ($self, $atom) = @_;
        my $elem = first($atom->elem, $self->ns('docs')->{uri}, 'largestChangestamp') or return;
        $elem->getAttribute('value');
    }
);
entry_has quota_bytes_total => (is => 'ro', isa => 'Int', tagname => 'quotaBytesTotal', ns => 'gd');
entry_has quota_bytes_used => (is => 'ro', isa => 'Int', tagname => 'quotaBytesUsed', ns => 'gd');
entry_has quota_bytes_used_in_trash => (is => 'ro', isa => 'Int', tagname => 'quotaBytesUsed', ns => 'gd');
entry_has max_upload_size => (is => 'ro', isa => 'HashRef',
    from_atom => sub {
        my ($self, $atom) = @_;
        +{ 
            map { $_->getAttribute('kind') => $_->textContent } 
            nodelist($atom->elem, $self->ns('docs')->{uri}, 'maxUploadSize')
        }
    },
);
for my $tag (qw(importFormat exportFormat)) {
    entry_has String::CamelCase::decamelize($tag) => (is => 'ro', isa => 'HashRef',
        from_atom => sub {
            my ($self, $atom) = @_;
            my $res = {};
            for my $node (nodelist($atom->elem, $self->ns('docs')->{uri}, $tag)) {
                my $source =  $node->getAttribute('source');
                my $target = $node->getAttribute('target');
                $res->{$source} ||= [];
                push @{$res->{$source}}, $target;
            }
            return $res;
        }
    );
}

__PACKAGE__->meta->make_immutable;

no Any::Moose;

1;
