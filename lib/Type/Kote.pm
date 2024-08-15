use v5.38;
use experimental qw(class);

use Carp ();
use Data::Lock ();

class Type::Kote {
    field $name :param;
    field $checker :param;

    ADJUST {
        # TODO
        # $name must be ...
        # $checker must be ...
    }

    method check($value) {
        local $_ = $value;
        !!$checker->($value);
    }

    method get_message($value) {
        "Value of '$name' is invalid";
    }

    method create($value) {
        Carp::croak "Must handle error" unless wantarray;

        unless ($checker->($value)) {
            return (undef, $self->get_message($value));
        }

        Data::Lock::dlock($value);

        $value;
    }


    sub make($class, $name, $checker) {
        if ($checker isa Type::Kote) {
            return $checker;
        }

        if ($checker isa Data::Checks::Constraint) {
            return $class->new(
                name    => $name,
                checker => sub { $checker->check($_[0]) },
            );
        }

        if ($checker isa Type::Tiny) {
            return $class->new(
                name    => $name,
                checker => $checker->compiled_check,
            )
        }

        if (reftype($checker) eq 'CODE') {
            return $class->new(
                name    => $name,
                checker => $checker,
            );
        }

        return undef;
    }
}
