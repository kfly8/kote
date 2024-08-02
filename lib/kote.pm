package kote;
use strict;
use warnings;

our $VERSION = "0.01";

use Carp qw(croak);
use Scalar::Util qw(blessed);

use Types::TypeTiny ();
use Eval::TypeTiny qw( set_subname type_to_coderef );

use Type::Kote;

# If $STRICT is 0, type->create skips check value and convert to immutable reference
our $STRICT = 1;

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

    use Types::Standard -types;

    use kote CharacterName  => Str & sub { /^[A-Z][a-z]+$/ };
    use kote CharacterLevel => Int & sub { $_ >= 1 && $_ <= 100 };
    use kote Character => Dict[
        name => CharacterName,
        level => CharacterLevel,
    ];

    my ($alice, $err) = Character->create({ name => 'Alice', level => 1 });
    is $alice->{name}, 'Alice';

    my ($bob, $err) = Character->create({ name => 'bob', level => 0 });
    say $err; # Error

=head1 DESCRIPTION

Kote - B<means "gauntlet"🧤 in Japanese> - is a type framework based on Type::Tiny.

=head2 FEATURES

=over 2

=item * Simplify type declarations

Type declarations just need to write in one place.

    use kote CharacterName => Str & sub { /^[A-Z][a-z]+$/ };

=item * Easy to check value

Only legal values can be created.

    my ($alice, $err) = CharacterName->create('Alice');
    croak $err if $err; # Must handle error!

=item * Type::Tiny based

The types declared by Kote are based on Type::Tiny, so we can use Type::Tiny's all features.

    CharacterName->isa('Type::Tiny'); # true

=back

=head1 CONCEPTS

Kote is inspired by the following book, L<Domain Modeling Made Functional|https://pragprog.com/titles/swdddf/>.

The phrase "Make illegal states unrepresentable" is a particularly important concept in Kote.
This idea works for dynamically typed languages like Perl too. By clearly stating the legal values, it make to easier to maintain codes.

=head1 DETAILS

=head2 Declare types

Kote provides a syntax for declaring types.

    package My::Character;
    use kote CharacterName => Str & sub { /^[A-Z][a-z]+$/ };

The first argument is the type name, which must be CamelCase.
The second argument is the type constraint, which must be a Type::Tiny object or one that can be converted to a Type::Tiny object.

Using Kote inherits Exporter::Tiny, and automatically adds the declared type to C<@EXPORT_OK>.
This means that you can import types as follows.

    package main;
    use My::Character qw(CharacterName);

    CharacterName->check('Alice'); # true

Order of type declarations is important, child types must be declared before parent types.

    # Bad order
    use kote Parent => Dict[ name => Child ];
    use kote Child => Str;

    # Good order
    use kote Child => Str;
    use kote Parent => Dict[ name => Child ];

=head2 Create value method

The type declared in Kote has a C<create> method.

    my ($alice, $err) = Character->create({name => 'Alice', level => 1});
    croak $err if $err;

The C<create> method returns a error message if the given value does not satisfy the type, and returns the value if it does:

    create(Any $value) -> (Any $value, undef) or (undef, Str $error)

Note that if the value is a reference, it be converted to an immutable.

    $alice->{name} = 'Bob'; # Error
    $alice->{unknown}; # Error

Throw an exception if an error is not handled. That is, when calling the create method in scalar or void context, throw an exception:

    my $alice = Character->create({name => 'Alice', level => 1});
    # => Exception: Must handle error!!

=head1 TIPS

=head2 Export functions

We can export functions as well as types by pushing them to C<@EXPORT_OK>.

    package My::Character {
        our @EXPORT_OK;
        push @EXPORT_OK, qw(is_alice);

        use kote CharacterName => Str & sub { /^[A-Z][a-z]+$/ };

        sub is_alice($name) { $name eq 'Alice' }
    }

    package main;
    use My::Character qw(CharacterName is_alice);

=head2 Skip check value

If C<$kote::STRICT> is set to false, validation of the value and conversion to make it to immutable are skipped.
However, be careful not to skip values that need to be validated.

    local $kote::STRICT = 0;
    my ($alice, $err) = CharacterName->create(1234);
    $err; # No Error

=head1 THANKS

Toby Inkster, the author of L<Type::Tiny>.

=head1 LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kobaken E<lt>kentafly88@gmail.comE<gt>

=cut

