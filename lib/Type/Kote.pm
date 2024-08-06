package Type::Kote;
use strict;
use warnings;

use parent qw(Type::Tiny);

use Data::Lock ();
use Carp ();
use Types::Standard ();

use constant STRICT => $ENV{KOTE_STRICT} // 1;

sub strictly_create {
    my ($self, @values) = @_;

    Carp::croak "Must handle error" unless wantarray;

    unless ($self->all(@values)) {
        if (@values == 1) {
            return ($self->get_message($values[0]), undef);
        }
        else {
            my $list = Types::Standard::ArrayRef[$self];
            return ($list->get_message(\@values), undef);
        }
    }

    Data::Lock::dlock($_) for @values;

    return (undef, @values);
}

sub create;
*create = STRICT ? \&strictly_create : sub { (undef, @_) };

1;
