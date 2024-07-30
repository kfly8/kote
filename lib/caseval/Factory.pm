package caseval::Factory;
use strict;
use warnings;

use Carp ();
use caseval::Prototype;

use constant STRICT => $ENV{PERL_CASEVAL_STRICT} || 1;

sub new {
    my ($class, $name, $check) = @_;
    # validate $name, $check

    bless [$name, $check] => $class;
}

sub name() { $_[0]->[0] }
sub check() { $_[0]->[1] }
sub creater() { $_[0]->[2] }

sub create {
    my ($self, $value) = @_;

    Carp::croak "Must handle error" unless wantarray;

    if (STRICT) {
        local $_ = $value;
        if (!$self->check->($value)) {
            return (undef, "invalid value");
        }
    }

    return (caseval::Prototype->new($self->name, $value), undef);
}

sub type {
    my ($self) = @_;

    require Type::Tiny;
    Type::Tiny->new(
        name       => $self->name,
        constraint => sub { ... },
    );
}

1;
