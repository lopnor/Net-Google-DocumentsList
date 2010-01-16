package Net::Google::DocumentsList::Role::UpdateWithoutEtag;
use Any::Moose '::Role';

sub update {
    my ($self) = @_;
    $self->atom or return;
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

1;
