package Net::Google::DocumentsList::Role::HasDocuments;
use Moose::Role;
use Net::Google::DataAPI;
use URI;
use MIME::Types;
use File::Slurp;

requires 'documents', 'document', 'add_document';

around documents => sub {
    my ($next, $self, $cond) = @_;

    if (my $cats = delete $cond->{category}) {
        $cats = [ "$cats" ] unless ref $cats eq 'ARRAY';
        my $uri = URI->new_abs(
            join('/','-', @$cats),
            $self->document_feedurl. '/',
        );
        my $feed = $self->service->get_feed($uri, $cond);
        return map {
            Net::Google::DocumentsList::Document->new(
                $self->can('sync') ? (container => $self) : (service => $self),
                atom => $_,
            );
        } $feed->entries;
    } else {
        return $next->($self, $cond);
    }
};

around add_document => sub {
    my ($next, $self, $args) = @_;
    if (my $file = delete $args->{file}) {
        -r $file or confess "File $file does not exist";
        my $part = HTTP::Message->new(
            ['Content-Type' => MIME::Types->new->mimeTypeOf($file)->type]
        );
        my $ref = read_file($file, scalar_ref => 1, binmode=>':raw');
        $part->content_ref($ref);
        my $entry = Net::Google::DocumentsList::Document->new(
            $self->can('sync') ? (container => $self) : (service => $self),
            %$args,
        )->to_atom;
        my $atom = $self->service->request(
            {  
                uri => $self->document_feedurl,
                parts => [
                    HTTP::Message->new(
                        ['Content-Type' => 'application/atom+xml'],
                        $entry->as_xml,
                    ),
                    $part,
                ],
                response_object => 'XML::Atom::Entry',
            }
        );
        $self->sync if $self->can('sync');
        return Net::Google::DocumentsList::Document->new(
            $self->can('sync') ? (container => $self) : (service => $self),
            atom => $atom,
        );
    } else {
        return $next->($self, $args);
    }
};

sub add_folder {
    my ($self, $args) = @_;
    return $self->add_document(
        {
            %$args,
            kind => 'folder',
        }
    );
}

sub folders {
    my ($self, $args) = @_;
    return $self->documents(
        {
            %$args,
            category => 'folder',
        }
    );
}

sub folder {
    my ($self, $args) = @_;
    return [ $self->folders($args) ]->[0];
}

1;
