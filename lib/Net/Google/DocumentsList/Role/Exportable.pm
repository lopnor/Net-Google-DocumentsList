package Net::Google::DocumentsList::Role::Exportable;
use Any::Moose '::Role';
use File::Slurp;

requires 'item_feedurl', 'kind';

sub export {
    my ($self, $args) = @_;

    $self->kind eq 'folder' 
        and confess "You can't export folder";
    my $format = delete $args->{format};
    my $file = delete $args->{file};
    my $res = $self->service->request(
        {
            uri => $self->item_feedurl,
            query => {
                %{$args || {}},
                exportFormat => $format,
            },
        }
    );
    if ($res->is_success) {
        if ( $file ) {
            my $content = $res->content_ref;
            return write_file( $file, {binmode => ':raw'}, $content );
        }
        return $res->decoded_content;
    }
}

1;
