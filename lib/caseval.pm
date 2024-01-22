package caseval;
use strict;
use warnings;

our $VERSION = "0.01";

use Data::Lock qw(dlock);
use Carp qw(croak);

use constant STRICT => $ENV{PERL_CASEVAL_STRICT} || 0;

sub import {
    my $class = shift;
    my ($func_name, $type) = @_;

    if (my $e = _validate_func_name($func_name)) {
        croak($e);
    }

    if (my $e = _validate_type($type)) {
        croak($e);
    }

    my $_type = $type; # for closure
    my $code = _create_caseval_code($type);

    no strict qw(refs);
    my $caller = caller;
    *{"${caller}::${func_name}"} = sub () { $_type };
    *{"${caller}::${func_name}::val"} = $code;
}

sub _validate_func_name {
    my ($func_name) = @_;

    if (not defined $func_name) {
        return "func_name is not defined";
    }

    return;
}

sub _validate_type {
    my ($type) = @_;

    if (not defined $type) {
        return "type is not defined";
    }
}

sub _create_caseval_code {
    my ($type) = @_;

    my $is_hash = $type->is_a_type_of('HashRef');
    my $is_array = $type->is_a_type_of('ArrayRef');

    my $code = $is_hash ? sub {
        my $data = { @_ };
        if (STRICT) {
            croak $type->get_message($data) unless $type->check($data);
            dlock $data;
        }
        return $data;
    } : $is_array ? sub {
        ...
    } : sub {
        ...
    };

    return $code;
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

