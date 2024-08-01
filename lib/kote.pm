package kote;
use strict;
use warnings;

our $VERSION = "0.01";

use Carp qw(croak);
use Scalar::Util qw(blessed);

use Type::Tiny;
use Type::Registry;
use Eval::TypeTiny qw( set_subname );

use Type::Kote;

# kote name must be CamelCase
my $normal_kote_name = qr/^[A-Z][a-zA-Z0-9]*$/;

my %forbidden_kote_name = map { $_ => 1 } qw{
    BEGIN CHECK DESTROY END INIT UNITCHECK
    AUTOLOAD STDIN STDOUT STDERR ARGV ARGVOUT ENV INC SIG
};

sub import {
    my $class = shift;
    my ($name, $type) = @_;

    my $err;

    $err = $class->_validate_name($name);
    croak $err if $err;

    $err = $class->_validate_type($type);
    croak "$name: $err" if $err;

    my $caller = caller;
    $type = $class->_create_type($name, $type, $caller);

    $err = $class->_add_type($name, $type, $caller);
    croak $err if $err;

    {
        # TODO: don't use @ISA
        no strict "refs";
        unless ($caller->isa('Exporter::Tiny')) {
            push @{ "$caller\::ISA" }, 'Exporter::Tiny';
        }
    }
}

sub _validate_name {
    my ($class, $name) = @_;

    if (!$name) {
        return 'kote name is not given';
    }
    elsif ($name !~ $normal_kote_name) {
        return "kote name '$name' is not CamelCase.";
    }
    elsif ($forbidden_kote_name{$name}) {
        return "kote name '$name' is forbidden.";
    }

    return;
}

sub _validate_type {
    my ($class, $type) = @_;

    $type = Types::TypeTiny::to_TypeTiny($type);
    unless (blessed($type) && $type->isa('Type::Tiny')) {
        return "Type must be a Type::Tiny object.";
    }

    return;
}

sub _create_type {
    my ($class, $name, $type, $caller) = @_;

    my $kote = Type::Kote->new(
        name   => $name,
        parent => $type,
        library => $caller,
    );

    # TODO: comment why need this.
    $kote->coercion->freeze;

    return $kote;
}

sub _add_type {
    my ($class, $name, $type, $caller) = @_;

    no strict "refs";

    for my $exportable ( @{ $type->exportables } ) {
        my $name = $exportable->{name};
        my $code = $exportable->{code};
        my $tags = $exportable->{tags};

        return "'$name' is already defined"
            if $caller->can($name);

        *{"$caller\::$name"} = set_subname( "$caller\::$name", $code);
        push @{"$caller\::EXPORT_OK"}, $name;
        push @{ ${"$caller\::EXPORT_TAGS"}{$_} ||= [] }, $name for @$tags;
    }

    Type::Registry->for_class( $caller )->add_type( $type, $name );
    return;
}

1;
__END__

=encoding utf-8

=head1 NAME

kote - It's new $module

=head1 SYNOPSIS

    use kote;

=head1 DESCRIPTION

kote is ...

=head1 LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kobaken E<lt>kentafly88@gmail.comE<gt>

=cut

