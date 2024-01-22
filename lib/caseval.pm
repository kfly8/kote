package caseval;
use strict;
use warnings;

our $VERSION = "0.01";

use Data::Lock qw(dlock);
use Carp qw(croak);
use Scalar::Util qw(blessed);
use Type::Utils qw(compile_match_on_type);

use constant STRICT => $ENV{PERL_CASEVAL_STRICT} || 0;

# caseval name must be CamelCase
my $normal_caseval_name = qr/^[A-Z][a-zA-Z0-9]*$/;

my %forbidden_caseval_name = map { $_ => 1 } qw{
    BEGIN CHECK DESTROY END INIT UNITCHECK
    AUTOLOAD STDIN STDOUT STDERR ARGV ARGVOUT ENV INC SIG
};

sub import {
    my $class = shift;
    my ($name, $type) = @_;

    if (my $e = _validate_name($name)) {
        croak($e);
    }

    if (my $e = _validate_type($type)) {
        croak($e);
    }

    my $_type = $type; # for closure
    my $code = _create_caseval_code($type);

    my $caller = caller;

    if ($caller->can($name)) {
        croak "caseval name '$name' is already defined.";
    }

    {
        no strict qw(refs);
        *{"${caller}::${name}"} = sub () { $_type };
        *{"${caller}::${name}::val"} = $code;
    }
}

sub _validate_name {
    my ($name) = @_;

    if (!$name) {
        return 'caseval name is not given';
    }
    elsif ($name !~ $normal_caseval_name) {
        return "caseval name '$name' is not CamelCase.";
    }
    elsif ($forbidden_caseval_name{$name}) {
        return "caseval name '$name' is forbidden.";
    }

    return;
}

sub _validate_type {
    my ($type) = @_;

    return "type is not defined" unless $type;
    return "type is not a Type::Tiny object" unless blessed($type) && $type->isa('Type::Tiny');

    return;
}

sub _create_caseval_code {
    my ($type) = @_;

    my $is_hash = $type->is_a_type_of('HashRef');
    my $is_array = $type->is_a_type_of('ArrayRef');
    my $is_union = $type->isa('Type::Tiny::Union');
    my $is_intersection = $type->isa('Type::Tiny::Intersection');
    my $is_class = $type->isa('Type::Tiny::Class');

    if ($is_hash) {
        return sub {
            my $data = { @_ };
            if (STRICT) {
                croak $type->get_message($data) unless $type->check($data);
                dlock $data;
            }
            return $data;
        }
    }
    elsif ($is_array) {
        return sub {
            my $data = [ @_ ];
            if (STRICT) {
                croak $type->get_message($data) unless $type->check($data);
                dlock $data;
            }
            return $data;
        }
    }
    elsif ($is_union) {
        my $types = $type->type_constraints;
        my $codes = [ map { ($_, _create_caseval_code($_)) } @$types ];
        return compile_match_on_type($codes);
    }
    elsif ($is_intersection) {
        my $types = $type->type_constraints;
        my $base = _create_caseval_code($types->[0]);
        return sub {
            my $v = $base->(@_);
            if (STRICT) {
                croak $type->get_message($v) unless $type->check($v);
                dlock $v;
            }
            return $v;
        }
    }
    elsif ($is_class) {
        my $class = $type->class;
        # require $class; # XXX: neccessary?
        return sub {
            $class->new(@_);
        }
    }
    else {
        return sub {
            my $v = $_[0];
            if (STRICT) {
                croak $type->get_message($v) unless $type->check($v);
                dlock $v;
            }
            return $v;
        };
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

caseval - It's new $module

=head1 SYNOPSIS

    use caseval;

=head1 DESCRIPTION

caseval is ...

=head1 LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kobaken E<lt>kentafly88@gmail.comE<gt>

=cut

