package Net::Google::DocumentsList;
use Any::Moose;
use namespace::autoclean;
use Net::Google::DataAPI;
use Net::Google::DataAPI::Auth::ClientLogin::Multiple;
use 5.008001;

our $VERSION = '0.00_01';

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
    Net::Google::DataAPI::Auth::ClientLogin::Multiple->new(
        source => $self->source,
        accountType => $self->account_type,
        services => {
            'docs.google.com' => 'writely',
            'spreadsheets.google.com' => 'wise',
        },
        username => $self->username,
        password => $self->password,
    );
}

feedurl item => (
    entry_class => 'Net::Google::DocumentsList::Item',
    default => 'https://docs.google.com/feeds/default/private/full',
    is => 'ro',
);

with 'Net::Google::DocumentsList::Role::HasItems';

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Net::Google::DocumentsList - Perl interface to Google Documents List Data API

=head1 SYNOPSIS

  use Net::Google::DocumentsList;

  my $client = Net::Google::DocumentsList->new(
    username => 'myname@gmail.com',
    password => 'p4$$w0rd'
  );
  

=head1 DESCRIPTION

Net::Google::DocumentsList is a Perl interface to Google Documents List Data 
API.

=head1 METHODS

=head2 new

creates Google Documents List Data API client.

  my $clinet = Net::Google::DocumentsList->new(
    username => 'foo.bar@gmail.com',
    password => 'p4ssw0rd',
    source   => 'MyClient', 
        # optional, default is 'Net::Google::DocumentsList'
    account_type => 'GOOGLE',
        # optional, default is 'HOSTED_OR_GOOGLE'
  );

You can set alternative authorization module like this:

  my $oauth = Net::Google::DataAPI::Auth::OAuth->new(...);
  my $client = Net::Google::DocumentsList->new(
    auth => $oauth,
  );

Make sure Documents List Data API would need those scopes:

=over 2

=item * http://docs.google.com/feeds/

=item * http://spreadsheets.google.com/feeds/

=item * http://docs.googleusercontent.com/

=back

=head2 add_item, items, item, add_folder, folders, folder

These methods are implemented in 
L<Net::Google::DocumentsList::Role::HasItems>.

=head1 AUTHOR

Noubo Danjou E<lt>nobuo.danjou@gmail.comE<gt>

=head1 SEE ALSO

L<XML::Atom>

L<Net::Google::AuthSub>

L<Net::Google::DataAPI>

L<Net::Google::DocumentsList::Role::HasItems>

L<http://code.google.com/apis/documents/docs/3.0/developers_guide_protocol.html>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
