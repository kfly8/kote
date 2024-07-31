package caseval::Prototype;
use strict;
use warnings;

sub new {
    my ($class, $name, $value, $operations) = @_;
    bless [$name, $value, $operations] => $class;
}

sub name() { $_[0]->[0] }
sub value() { $_[0]->[1] }

sub equals {
    my ($self, $other) = @_;
    return $self->name eq $other->name && $self->value eq $other->value;
}

1;
