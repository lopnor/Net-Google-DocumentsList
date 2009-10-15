package Net::Google::DocumentsList::Document;
use Moose;
use Net::Google::DataAPI;
with 'Net::Google::DataAPI::Role::Entry';
use XML::Atom::Util qw(nodelist);

entry_has 'published' => ( tagname => 'published', is => 'ro' );
entry_has 'updated' => ( tagname => 'updated', is => 'ro' );
entry_has 'edited' => ( tagname => 'edited', ns => 'app', is => 'ro' );
entry_has 'resource_id' => ( tagname => 'resourceId', ns => 'gd', is => 'ro' );
entry_has 'last_viewd' => ( tagname => 'lastViewed', ns => 'gd', is => 'ro' );
entry_has 'kind' => (
    is => 'ro',
    from_atom => sub {
        my ($self, $atom) = @_;
        my ($kind) = 
            map {$_->label}
            grep {$_->scheme eq 'http://schemas.google.com/g/2005#kind'}
            $atom->categories;
        return $kind;
    },
    to_atom => sub {
        my ($self, $atom) = @_;
        my $cat = XML::Atom::Category->new;
        $cat->scheme('http://schemas.google.com/g/2005#kind');
        $cat->label($self->kind);
        $cat->term(join("#", "http://schemas.google.com/docs/2007", $self->kind));
        $atom->category($cat);
    }
);

feedurl 'acl' => (
    from_atom => sub {
        my ($self, $atom) = @_;
        return $self->_get_feedlink('http://schemas.google.com/acl/2007#accessControlList');
    },
    entry_class => 'Net::Google::DocumentsList::ACL',
);

feedurl 'revision' => (
    from_atom => sub {
        my ($self, $atom) = @_;
        return $self->_get_feedlink('http://schemas.google.com/docs/2007/revisions');
    },
    entry_class => 'Net::Google::DocumentsList::Revision',
);

sub _get_feedlink {
    my ($self, $rel) = @_;
    my ($feedurl) = 
        map {$_->getAttribute('href')}
        grep {$_->getAttribute('rel') eq $rel}
        nodelist($self->elem, $self->ns('gd')->{uri}, 'feedLink');
    return $feedurl;
}

sub delete {
    my ($self, $args) = @_;
    $self->service->request(
        {
            uri => $self->editurl,
            method => 'DELETE',
# XXX: deleting spreadsheet with etag raises 412
#            header => {'If-Match' => $self->etag},
            header => {'If-Match' => '*'},
            $args->{delete} ? (query => {delete => 'true'}) : (),
        }
    );
};

1;
