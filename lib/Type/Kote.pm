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

sub as {
    my ($self, $type, @args) = @_;

    my $new = $type->parameterize($self, @args);
    $self->to_kote($new);
}

# override
sub child_type_class {
    __PACKAGE__
}

# override
sub _build_complementary_type {
    my $self = shift;
    my $type = $self->SUPER::_build_complementary_type();
    $self->to_kote($type);
}

sub to_kote {
    my ($self, $type) = @_;

    if (Scalar::Util::blessed($type) && $type->isa('Type::Kote')) {
        return $type;
    }

    $type = Types::TypeTiny::to_TypeTiny($type);
    if (Scalar::Util::blessed($type) && $type->isa('Type::Tiny')) {
        return $self->child_type_class->new(
            display_name => $type->display_name,
            parent       => $type,
            library      => $self->library,
        );
    }

    $type;
}

1;
