package Type::Kote;
use strict;
use warnings;

use parent qw(Type::Tiny);

use Data::Lock ();
use Carp ();

sub create {
    my ($self, $value) = @_;

    Carp::croak "Must handle error" unless wantarray;

    no warnings qw(once);
    if ($kote::STRICT) {
        unless ($self->check($value)) {
            return (undef, $self->get_message($value));
        }

        Data::Lock::dlock($value);
    }

    return ($value, undef);
}

1;
