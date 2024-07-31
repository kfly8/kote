package caseval::Factory;
use strict;
use warnings;

use Carp ();
use caseval::Prototype;

use constant STRICT => $ENV{PERL_CASEVAL_STRICT} || 1;

sub new {
    my ($class, $name, $type) = @_;
    # validate $name, $check

    bless [$name, $type] => $class;
}

sub name() { $_[0]->[0] }
sub type() { $_[0]->[1] }

sub create {
    my ($self, $value) = @_;

    Carp::croak "Must handle error" unless wantarray;

    if (STRICT) {
        local $_ = $value;
        if (!$self->type->check($value)) {
            return (undef, "invalid value");
        }
    }

    return (caseval::Prototype->new($self->name, $value), undef);
}

1;
