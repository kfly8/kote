package kote;
use strict;
use warnings;

our $VERSION = "0.01";

use Carp qw(croak);
use Scalar::Util qw(blessed);

use Types::TypeTiny ();
use Eval::TypeTiny qw( set_subname type_to_coderef );

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

    my $caller = caller;
    (my $kote, $err) = $class->_create_kote($name, $type, $caller);
    croak $err if $err;

    $err = $class->_add_kote($name, $kote, $caller);
    croak $err if $err;

    $err = $class->_setup_exporter($caller);
    croak $err if $err;
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

sub _to_type {
    my ($class, $type) = @_;

    Types::TypeTiny::to_TypeTiny($type);
}

sub _create_kote {
    my ($class, $name, $type, $caller) = @_;

    $type = $class->_to_type($type);
    unless (blessed($type) && $type->isa('Type::Tiny')) {
        return (undef, "$name: type must be able to be a Type::Tiny");
    }

    my $kote = Type::Kote->new(
        name   => $name,
        parent => $type,
        library => $caller,
    );

    # make kote immutable
    $kote->coercion->freeze;

    return ($kote, undef);
}

sub _add_kote {
    my ($class, $name, $kote, $caller) = @_;

    if ($caller->can($name)) {
        return "'$name' is already defined";
    }

    my $code = type_to_coderef($kote);

    {
        no strict "refs";
        *{"$caller\::$name"} = set_subname( "$caller\::$name", $code);
        push @{"$caller\::EXPORT_OK"}, $name;
        push @{ ${"$caller\::EXPORT_TAGS"}{types} ||= [] }, $name;
    }

    return;
}

sub _exporter_class {
    'Exporter::Tiny';
}

sub _setup_exporter {
    my ($class, $caller) = @_;

    my $exporter_class = $class->_exporter_class;

    unless ($caller->isa($exporter_class)) {
        no strict "refs";
        push @{ "$caller\::ISA" }, $exporter_class;
        ( my $file = $caller ) =~ s{::}{/}g;
        $INC{"$file.pm"} ||= __FILE__;
    }

    return;
}

1;
__END__

=encoding utf-8

=head1 NAME

kote - Type::Tiny based type framework

=head1 SYNOPSIS

    package My::Character {
        use v5.40;

        our @EXPORT_OK;
        push @EXPORT_OK, qw(summary);

        use Types::Standard -types;
        use Devel::StrictMode;

        use kote CharacterName => Str & sub { /^[A-Z][a-z]+$/ };
        use kote CharacterLevel => Int & sub { $_ >= 1 && $_ <= 100 };
        use kote Character => Dict[
            name => CharacterName,
            level => CharacterLevel,
        ];

        sub summary($character) {
            STRICT && Character->assert_valid($character);
            return "Name: $character->{name}, Level: $character->{level}";
        }
    }

    package main {
        use v5.40;
        use My::Character qw(Character summary);

        my $err;

        (my $alice, $err) = Character->create({name => 'Alice', level => 99});
        say $err; # undef
        say $alice->{name}; # Alice
        say $alice->{level}; # 99
        say summary($alice); # Name: Alice, Level: 99

        (my $bob, $err) = Character->create({name => 'bob', level => 0});
        say $bob; # undef
        say $err; # Error
    }

=head1 DESCRIPTION

kote is ...

=head1 LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kobaken E<lt>kentafly88@gmail.comE<gt>

=cut

