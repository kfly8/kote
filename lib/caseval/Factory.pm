package caseval::Factory;
use strict;
use warnings;

use Carp ();
use Scalar::Util ();
use caseval::Prototype;

use constant STRICT => $ENV{PERL_CASEVAL_STRICT} || 1;

sub new {
    my ($class, $typename, $type) = @_;
    bless [$typename, $type] => $class;
}

sub __typename() { $_[0]->[0] }
sub type() { $_[0]->[1] }

sub create {
    my ($self, $value) = @_;

    Carp::croak "Must handle error" unless wantarray;

    if (STRICT) {
        if (!$self->check($value)) {
            return (undef, $self->get_message($value));
        }
    }

    return (caseval::Prototype->new($self->__typename, $value), undef);
}

sub check {
    my ($self, $value) = @_;

    if (Scalar::Util::blessed($value) && $value->can('__typename')) {
        return $value->__typename eq $self->__typename;
    }
    elsif (ref($value) eq 'HASH' && exists $value->{__TYPENAME__}) {
        return $value->{__TYPENAME__} eq $self->__typename;
    }
    else {
        return !!0;
    }
}

sub get_message {
    my ($self, $value) = @_;
    return "Invalid value for " . $self->__typename;
}

# TODO: need to implement?
sub has_coercion { !!0 }

1;
