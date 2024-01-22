package caseval;
use strict;
use warnings;

our $VERSION = "0.01";

use Data::Lock qw(dlock);
use Carp qw(croak);

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

