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

sub item_of {
    my ($self, $type, @args) = @_;
    my $t = $type->parameterize($self, @args);
    _to_TypeKote($t);
}

sub maybe {
    my $self = shift;
    $self->item_of(Types::Standard::Maybe)
}

sub optional {
    my $self = shift;
    $self->item_of(Types::Standard::Optional)
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

=head1 NAME

Type::Kote - subclass of Type::Tiny

=head1 SYNOPSIS

    use Type::Kote;
    use Types::Standard -types;

    my $type = Type::Kote->new(
        parent => Int,
        constraint => sub { $_ > 0 },
    );

    # You can use Type::Tiny methods
    $type->check(1); # true
    my $subtype = $type->where(sub { $_ < 10 }); # isa Type::Kote

    # Following methods are added

    # type check and lock
    ($value, $error) = $type->create(123);
    ($value, $error) = $type->create(0); # $error has error message

    # create a Kote type
    $list = $type->item_of(ArrayRef);
    $list->check([1, 2, 3]); # true

    # shortcuts
    $type->maybe->check(undef); # true. same as $type->item_of(Maybe)

    my $d = Dict[foo => $type->optional];
    $d->check({}); # true. same as $type->item_of(Optional)


=head1 DESCRIPTION

C<Type::Kote> is a subclass of L<Type::Tiny> that provides additional functionalities for value creation and type manipulation.

=head1 CONFIGURATION

=head2 C<$ENV{KOTE_STRICT}>

If C<$ENV{KOTE_STRICT}> is set to a true value, C<STRICT> constant is true.
Default is true.

=head1 METHODS

=head2 C<< Type::Kote->new(%args) >>

Create a new C<Type::Kote> object. C<%args> are the same as L<Type::Tiny>.

=head2 C<< ($value, $error) = $type->strictly_create($value) >>

    ($value, $error) = $MyInt->strictly_create(123);
    # => (123, undef);

    ($value, $error) = $MyInt->strictly_create({});
    # => (undef, );

Given value is checked by the type constraint.
If the value is invalid, C<undef> is returned and C<$error> is the error message.
If the value is valid, C<$value> is returned and C<$error> is C<undef>, and the value is locked if the value is reference.

=head2 C<< ($value, $error) = $type->create($value) >>

If C<STRICT> is true, this method is an alias of C<strictly_create>.
If false, this method do nothing and return the given value.

=head2 C<< $subtype = $type->item_of($type, @args) >>

    use kote Name => Str & sub { /^[A-Z][a-z]+$/ };

    Name->item_of(ArrayRef)->check(['Alice']); # true


=head1 LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kobaken E<lt>kentafly88@gmail.comE<gt>

=cut


