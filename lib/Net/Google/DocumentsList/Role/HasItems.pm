package Net::Google::DocumentsList::Role::HasItems;
use Any::Moose '::Role';
with 'Net::Google::DocumentsList::Role::EnsureListed';
use Net::Google::DataAPI;
use URI;
use MIME::Types;
use File::Slurp;
use Carp;

requires 'items', 'item', 'add_item';

around items => sub {
    my ($next, $self, $cond) = @_;

    my @items;
    if (my $cats = delete $cond->{category}) {
        $cats = [ "$cats" ] unless ref $cats eq 'ARRAY';
        my $uri = URI->new_abs(
            join('/','-', @$cats),
            $self->item_feedurl. '/',
        );
        my $feed = $self->service->get_feed($uri, $cond);
        my $class = $self->item_entryclass;
        Any::Moose::load_class($class);
        @items = map {
            $class->new(
                $self->can('sync') ? (container => $self) : (service => $self),
                atom => $_,
            );
        } $feed->entries;
    } else {
        @items = $next->($self, $cond);
    }
    if ($self->can('sync')) {
        @items = grep {$_->parent eq $self->_url_with_resource_id} @items;
    }
    @items;
};

around add_item => sub {
    my ($next, $self, $args) = @_;
    my $item;
    if (my $file = delete $args->{file}) {
        -r $file or confess "File $file does not exist";
        my $part = HTTP::Message->new(
            ['Content-Type' => MIME::Types->new->mimeTypeOf($file)->type]
        );
        my $ref = read_file($file, scalar_ref => 1, binmode=>':raw');
        $part->content_ref($ref);
        my $class = $self->item_entryclass;
        Any::Moose::load_class($class);
        my $entry = $class->new(
            $self->can('sync') ? (container => $self) : (service => $self),
            %$args,
        )->to_atom;
        my $atom = $self->service->request(
            {  
                uri => $self->item_feedurl,
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
        $item = $class->new(
            $self->can('sync') ? (container => $self) : (service => $self),
            atom => $atom,
        );
    } else {
        $item = $next->($self, $args);
    }
    return $self->ensure_listed($item, {etag_should_change => 1});
};

sub add_folder {
    my ($self, $args) = @_;
    return $self->add_item(
        {
            %{$args || {}},
            kind => 'folder',
        }
    );
}

sub folders {
    my ($self, $args) = @_;
    my $cat = delete $args->{category} || [];
    $cat = [ $cat ] unless ref $cat;
    return $self->items(
        {
            %{$args || {}},
            category => [ 'folder', @$cat ],
        }
    );
}

sub folder {
    my ($self, $args) = @_;
    return [ $self->folders($args) ]->[0];
}

1;
__END__

=head1 NAME

Net::Google::DocumentsList::Role::HasItems - item CRUD implementation

=head1 SYNOPSIS

  use Net::Google::DocumentsList;

  my $service = Net::Google::DocumentsList->new(
    username => 'myname@gmail.com',
    password => 'p4$$w0rd'
  );

  # add a document to the root directory of your docs.
  my $doc = $service->add_item(
    {
        title => 'my document',
        kind  => 'document',
    }
  );

  # add a folder to the root directory of your docs.
  my $folder = $service->add_folder(
    {
        title => 'my folder',
    }
  );

  # add a spreadsheet to a directory
  my $spreadsheet = $folder->add_item(
    {
        title => 'my spreadsheet',
        kind  => 'spreadsheet',
    }
  );
  

=head1 DESCRIPTION

This module implements item CRUD for Google Documents List Data API.

=head1 METHODS

=head2 add_item

creates specified file or folder.

  my $file = $client->add_item(
    {
        title => 'my document',
        kind  => 'document',
    }
  );

available values for 'kind' are 'document', 'folder', 'pdf', 'presentation',
'spreadsheet', and 'form'.

You can also upload file:

  my $uploaded = $client->add_item(
    {
        title => 'uploaded file',
        file  => '/path/to/my/presentation.ppt',
    }
  );

=head2 items

searches items like this:

  my @items = $client->items(
    {
        'title' => 'my document',
        'title-exact' => 'true',
        'category' => 'document',
    }
  );

  my @not_viewed_and_starred_presentation = $client->items(
    {
        'category' => ['-viewed','starred','presentation'],
    }
  );

You can specify query with hashref and specify categories in 'category' key.
See L<http://code.google.com/intl/en/apis/documents/docs/3.0/developers_guide_protocol.html#SearchingDocs> for details.

=head2 item

returns the first item found by items method.

=head2 add_folder

shortcut for add_item({kind => 'folder'}).

  my $new_folder = $client->add_folder( { title => 'new_folder' } );

is equivalent to 

  my $new_folder = $client->add_item( 
      { 
          title => 'new_folder',
          kind  => 'folder',
      } 
  );

=head2 folders

shortcut for items({category => 'folder'}).

=head2 folder

returns the first folder found by folders method.

=head1 AUTHOR

Noubo Danjou E<lt>nobuo.danjou@gmail.comE<gt>

=head1 SEE ALSO

L<Net::Google::DocumentsList>

L<Net::Google::DataAPI>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
