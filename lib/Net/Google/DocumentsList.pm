package Net::Google::DocumentsList;
use Any::Moose;
use namespace::autoclean;
use Net::Google::DataAPI;
use Net::Google::DataAPI::Auth::AuthSub;
use Net::Google::AuthSub;
use 5.008001;

our $VERSION = '0.01';

with 'Net::Google::DataAPI::Role::Service';

has '+gdata_version' => (default => '3.0');
has '+namespaces' => (
    default => sub {
        {
            gAcl => 'http://schemas.google.com/acl/2007',
            batch => 'http://schemas.google.com/gdata/batch',
            docs => 'http://schemas.google.com/docs/2007',
            app => 'http://www.w3.org/2007/app',
        }
    },
);

has username => (is => 'ro', isa => 'Str');
has password => (is => 'ro', isa => 'Str');
has account_type => (is => 'ro', isa => 'Str', required => 1, default => 'HOSTED_OR_GOOGLE');
has source => (is => 'ro', isa => 'Str', required => 1, default => __PACKAGE__ . '-' . $VERSION);

sub _build_auth {
    my ($self) = @_;
    my $authsub = Net::Google::AuthSub->new(
        source => $self->source,
        service => 'writely',
        account_type => $self->account_type,
    );
    my $res = $authsub->login( $self->username, $self->password );
    unless ($res && $res->is_success) {
        die 'Net::Google::AuthSub login failed';
    }
    return Net::Google::DataAPI::Auth::AuthSub->new(
        authsub => $authsub,
    );
}

feedurl item => (
    entry_class => 'Net::Google::DocumentsList::Item',
    default => 'http://docs.google.com/feeds/default/private/full',
    is => 'ro',
);

with 'Net::Google::DocumentsList::Role::HasItems';

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::Google::DocumentsList -

=head1 SYNOPSIS

  use Net::Google::DocumentsList;

=head1 DESCRIPTION

Net::Google::DocumentsList is

=head1 AUTHOR

Noubo Danjou E<lt>nobuo.danjou@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
