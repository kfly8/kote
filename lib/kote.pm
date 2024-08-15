package kote;
use v5.38;

our $VERSION = "0.01";

use Carp qw(croak);
use Sub::Util qw(set_subname);

use Type::Kote;

my %forbidden_kote_name = map { $_ => 1 } qw{
    BEGIN CHECK DESTROY END INIT UNITCHECK
    AUTOLOAD STDIN STDOUT STDERR ARGV ARGVOUT ENV INC SIG
};

sub import {
    my $class = shift;
    my ($name, $checker) = @_;

    my $err;

    $err = $class->_validate_name($name);
    croak $err if $err;

    my $kote = Type::Kote->make($name, $checker);
    croak "Cannot make kote for $name" unless $kote;

    my $caller = caller;
    $err = $class->_install_kote($name, $kote, $caller);
    croak $err if $err;

    $err = $class->_setup_exporter($caller);
    croak $err if $err;
}

sub _validate_name {
    my ($class, $name) = @_;

    if (!$name) {
        return 'name is required';
    }
    elsif ($forbidden_kote_name{$name}) {
        return "'$name' is forbidden.";
    }

    return;
}

sub _install_kote {
    my ($class, $name, $kote, $caller) = @_;

    if ($caller->can($name)) {
        return "'$name' is already defined";
    }

    my $code = sub () { $kote };

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
        name  => CharacterName,
        level => CharacterLevel,
    ];

    my ($alice, $err) = Character->create({ name => 'Alice', level => 1 });
    say $alice->{name}; # Alice
    say $err; # undef

    my ($bob, $err) = Character->create({ name => 'bob', level => 0 });
    say $bob; # undef
    say $err; # Error!

=head1 DESCRIPTION

Kote - B<means "gauntlet"🧤 in Japanese> - is a type framework based on Type::Tiny.
Kote aims to simplify type declarations and value checks in Perl.

=head2 FEATURES

=over 2

=item * Simplify Type Declarations

Type declarations just need to write in one place.

    use kote CharacterName => Str & sub { /^[A-Z][a-z]+$/ };

=item * Easy to Check Values

Only legal values can be created.

    my ($alice, $err) = CharacterName->create('Alice');
    croak $err if $err; # Must handle error!

=item * Type::Tiny Based

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

    use kote TYPE_NAME => TYPE_CONSTRAINT;

The first argument is a type name, and the second argument is a type constraint.
Type name must begin with an uppercase letter and can only contain alphabetic letter, digits and underscores.
Type constraints must be a Type::Tiny object or something that can be converted to one.

Using Kote inherits L<Exporter::Tiny> and automatically adds the declared type to C<@EXPORT_OK>.
This means you can import types as follows:

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

If the value is a reference, it will be converted to an immutable:

    $alice->{name} = 'Bob'; # Error
    $alice->{unknown}; # Error

An exception is thrown if an error is not handled. Calling the create method in scalar or void context will throw an exception:

    my $alice = Character->create({name => 'Alice', level => 1});
    # => Exception: Must handle error!!

=head1 TIPS

=head2 Export Functions

You can export functions as well as types by pushing them to C<@EXPORT_OK>.

    package My::Character {
        our @EXPORT_OK;
        push @EXPORT_OK, qw(is_alice);

        use kote CharacterName => Str & sub { /^[A-Z][a-z]+$/ };

        sub is_alice($name) { $name eq 'Alice' }
    }

    package main;
    use My::Character qw(CharacterName is_alice);

=head2 Skip Check Value

If C<$ENV{KOTE_STRICT}> is set to false during the BEGIN phase, the validation of the value and the conversion to make it immutable are skipped. However, be careful not to skip values that need to be validated.

    BEGIN {
        $ENV{KOTE_STRICT} = 0;
    }

    use kote Name => Str & sub { /^[A-Z][a-z]+$/ };

    my ($alice, $err) = Name->create(1234);
    $err; # No Error

If C<$ENV{KOTE_STRICT}> is set to false but you still want to perform validation, you should use the C<strictly_create> method instead of the C<create> method.

    my ($alice, $err) = Name->strictly_create(1234);
    $err; # Error!!

=head1 THANKS

Toby Inkster, the author of L<Type::Tiny>.

=head1 LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kobaken E<lt>kentafly88@gmail.comE<gt>

=cut

