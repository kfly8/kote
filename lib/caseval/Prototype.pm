package caseval::Prototype;
use strict;
use warnings;

sub new {
    my ($class, $typename, $value, $operations) = @_;
    bless [$typename, $value, $operations] => $class;
}

sub __typename() { $_[0]->[0] }
sub value() { $_[0]->[1] }

sub equals {
    my ($self, $other) = @_;
    return unless Scalar::Util::blessed($other) && $other->can('__typename');
    return unless $self->__typename eq $other->__typename;

    # TODO
    $self->value eq $other->value;
}

1;
