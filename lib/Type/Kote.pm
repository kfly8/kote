package Type::Kote;
use strict;
use warnings;

use parent qw(Type::Tiny);

use Data::Lock ();
use Carp ();
use Scalar::Util ();
use Types::Standard ();

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

sub into {
    my ($self, $type, @args) = @_;
    my $t = $type->parameterize($self, @args);
    _to_TypeKote($t);
}

sub maybe {
    my $self = shift;
    $self->into(Types::Standard::Maybe)
}

sub optional {
    my $self = shift;
    $self->into(Types::Standard::Optional)
}

# override
sub child_type_class {
    __PACKAGE__
}

# override
sub _build_complementary_type {
    my $self = shift;
    my $t = $self->SUPER::_build_complementary_type();
    _to_TypeKote($t);
}

sub _to_TypeKote {
    my $type = shift;
    if (Scalar::Util::blessed($type) && $type->isa('Type::Kote')) {
        return $type;
    }
    else {
        my $t = Types::TypeTiny::to_TypeTiny($type);
        return Type::Kote->new(
            display_name => $t->display_name,
            parent       => $t,
        );
    }
}

1;
