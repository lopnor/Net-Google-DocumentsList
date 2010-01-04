package Net::Google::DocumentsList::Item;
use Any::Moose;
use namespace::autoclean;
use Net::Google::DataAPI;
with 'Net::Google::DataAPI::Role::Entry',
    'Net::Google::DocumentsList::Role::EnsureListed';
use XML::Atom::Util qw(nodelist first);
use Carp;
use URI::Escape;

our $SLEEP = 5;

feedurl item => (
    is => 'ro',
    as_content_src => 1,
    entry_class => 'Net::Google::DocumentsList::Item',
);

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

with 'Net::Google::DocumentsList::Role::HasItems',
    'Net::Google::DocumentsList::Role::Exportable';

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
    can_add => 0,
);

entry_has 'published' => ( tagname => 'published', is => 'ro' );
entry_has 'updated' => ( tagname => 'updated', is => 'ro' );
entry_has 'edited' => ( tagname => 'edited', ns => 'app', is => 'ro' );
entry_has 'resource_id' => ( tagname => 'resourceId', ns => 'gd', is => 'ro' );
entry_has 'last_viewd' => ( tagname => 'lastViewed', ns => 'gd', is => 'ro' );
entry_has 'deleted' => ( 
    is => 'ro',
    isa => 'Bool',
    from_atom => sub {
        my ($self, $atom) = @_;
        first($atom->elem, $self->ns('gd')->{uri}, 'deleted') ? 1 : 0;
    },
);
entry_has 'parent' => (
    is => 'ro',
    isa => 'Str',
    from_atom => sub {
        my ($self, $atom) = @_;
        $self->container or return;
        my ($parent) = 
            grep {$_ eq $self->container->_url_with_resource_id}
            map {$_->href}
            grep {$_->rel eq 'http://schemas.google.com/docs/2007#parent'}
            $atom->link;
        $parent;
    }
);

sub _url_with_resource_id {
    my ($self) = @_;
    join('/', $self->service->item_feedurl, uri_escape $self->resource_id);
}

sub _get_feedlink {
    my ($self, $rel) = @_;
    my ($feedurl) = 
        map {$_->getAttribute('href')}
        grep {$_->getAttribute('rel') eq $rel}
        nodelist($self->elem, $self->ns('gd')->{uri}, 'feedLink');
    return $feedurl;
}

sub update_content {
    my ($self, $file) = @_;

    $self->kind eq 'folder' 
        and confess "You can't update folder content with a file";
    -r $file or confess "File $file does not exist";
    my $part = HTTP::Message->new(
        ['Content-Type' => MIME::Types->new->mimeTypeOf($file)->type ]
    );
    my $ref = read_file($file, scalar_ref => 1, binmode=>':raw');
    $part->content_ref($ref);
    my $atom = $self->service->request(
        {
            method => 'PUT',
            uri => $self->editurl,
            parts => [
                HTTP::Message->new(
                    ['Content-Type' => 'application/atom+xml'],
                    $self->atom->as_xml,
                ),
                $part,
            ],
            response_object => 'XML::Atom::Entry',
        }
    );
    $self->container->sync if $self->container;
    $self->atom($atom);
}

sub move_to {
    my ($self, $dest) = @_;

    (
        ref($dest) eq 'Net::Google::DocumentsList::Item'
        && $dest->kind eq 'folder'
    ) or confess 'destination should be a folder';
    
    my $atom = $self->service->request(
        {
            method => 'POST',
            content_type => 'application/atom+xml',            
            uri => $dest->item_feedurl,
            content => $self->atom->as_xml,
            response_object => 'XML::Atom::Entry',
        }
    );
    my $item = (ref $self)->new(
        container => $dest,
        atom => $atom,
    );
    my $updated = $dest->ensure_listed($item);
    $self->container->sync if $self->container;
    $dest->sync;
    $self->atom($updated->atom);
}

sub move_out_of {
    my ($self, $folder) = @_;

    (
        ref($folder) eq 'Net::Google::DocumentsList::Item'
        && $folder->kind eq 'folder'
    ) or confess 'the argument should be a folder';
    
    my $res = $self->service->request(
        {
            method => 'DELETE',
            uri => join('/', $folder->item_feedurl, $self->resource_id),
            header => {'If-Match' => $self->etag},
        }
    );
    if ($res->is_success) {
        $self->ensure_not_listed($folder);
        $self->container->sync if $self->container;
        $folder->sync;
        $self->sync;
    }
}

sub update {
    my ($self) = @_;
    $self->etag or return;
    my $parent = $self->container || $self->service;
    my $atom = $self->service->put(
        {
            self => $self,
            entry => $self->to_atom,
        }
    );
    my $item = (ref $self)->new(
        $self->container ? (container => $self->container) 
        : ( service => $self->service),
        atom => $atom
    );
    my $updated = $parent->ensure_listed($item);
    $self->container->sync if $self->container;
    $self->atom($updated->atom);
}

sub delete {
    my ($self, $args) = @_;

    my $parent = $self->container || $self->service;

    my $selfurl = $self->container ? $self->_url_with_resource_id : $self->selfurl;

    $args->{delete} = 'true' if $args->{delete};
    my $res = $self->service->request(
        {
            uri => $selfurl,
            method => 'DELETE',
            header => {'If-Match' => $self->etag},
            self => $self,
            query => $args,
        }
    );
    $res->is_success or return;
    if ($args->{delete}) {
        $parent->ensure_deleted($self);
    } else {
        $parent->ensure_trashed($self);
    }
    return 1;
}

__PACKAGE__->meta->make_immutable;

1;
