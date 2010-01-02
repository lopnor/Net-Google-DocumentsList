package Net::Google::DocumentsList::Role::Exportable;
use Any::Moose '::Role';

requires 'item_feedurl', 'kind';

sub export {
    my ($self, $args) = @_;

    $self->kind eq 'folder' 
        and confess "You can't export folder";
    my $res = $self->service->request(
        {
            uri => $self->item_feedurl,
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

1;
