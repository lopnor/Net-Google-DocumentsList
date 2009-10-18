package Net::Google::DocumentsList::Document;
use Moose;
use Net::Google::DataAPI;
with 'Net::Google::DataAPI::Role::Entry';
use XML::Atom::Util qw(nodelist);
use File::Slurp;

feedurl document => (
    is => 'ro',
    as_content_src => 1,
    entry_class => 'Net::Google::DocumentsList::Document',
);

with 'Net::Google::DocumentsList::Role::HasDocuments';

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

sub export {
    my ($self, $args) = @_;

    $self->kind eq 'folder' 
        and confess "You can't export folder";
    my $res = $self->service->request(
        {
            uri => $self->document_feedurl,
            query => {
                exportFormat => $args->{format},
            },
        }
    );
    if ($res->is_success) {
        if ( my $file = $args->{file} ) {
            my $content = $res->content_ref;
            return write_file( $file, {binmode => ':raw'}, $content );
        }
        return $res->decoded_content;
    }
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
        ref($dest) eq 'Net::Google::DocumentsList::Document'
        && $dest->kind eq 'folder'
    ) or confess 'destination should be a folder';
    
    my $atom = $self->service->request(
        {
            method => 'POST',
            content_type => 'application/atom+xml',            
            uri => $dest->document_feedurl,
            content => $self->atom->as_xml,
            response_object => 'XML::Atom::Entry',
        }
    );
    $self->container->sync if $self->container;
    $dest->sync;
    $self->atom($atom);
}

1;
