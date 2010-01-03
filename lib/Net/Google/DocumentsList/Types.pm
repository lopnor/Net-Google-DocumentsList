package Net::Google::DocumentsList::Types;
use Any::Moose;
use Any::Moose '::Util::TypeConstraints';

subtype 'Net::Google::DocumentsList::Types::ACL::Scope'
    => as 'HashRef'
    => where {
        my $args = shift;
        scalar keys %$args == 2 &&
        defined $args->{type} &&
        defined $args->{value};
    };

1;
