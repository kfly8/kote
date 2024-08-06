package Type::Kote;
use strict;
use warnings;

use parent qw(Type::Tiny);

use Data::Lock ();
use Carp ();

use constant STRICT => $ENV{KOTE_STRICT} // 1;

sub strictly_create {
    my ($self, $value) = @_;

    Carp::croak "Must handle error" unless wantarray;

    unless ($self->check($value)) {
        return (undef, $self->get_message($value));
    }

    Data::Lock::dlock($value);

    return ($value, undef);
}

sub create;
*create = STRICT ? \&strictly_create : sub { ($_[1], undef) };

1;
