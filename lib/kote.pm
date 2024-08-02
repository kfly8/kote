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

    Charcter->isa('Type::Tiny'); # true

=head1 DESCRIPTION

kote - B<means "gauntlet"🧤 in Japanese> - is a type framework based on Type::Tiny.

=head2 FEATURES

=over 2

=item * 型の宣言が簡潔

型名と制約を一度書くだけで、型を宣言できます。

    use kote CharacterName => Str & sub { /^[A-Z][a-z]+$/ };

=item * 値の検証が容易

値が型を満たしているか簡単に検証できます。

    my ($alice, $err) = CharacterName->create('Alice');

=item * Type::Tiny ベース

koteで宣言した型は、Type::Tinyをベースにしているので、Type::Tinyの機能をそのまま利用できます。

    CharacterName->check('Alice'); # true

=back

=head1 CONCEPTS

koteは、次の書籍に触発されています。L<Domain Modeling Made Functional|https://pragprog.com/titles/swdddf/domain-modeling-made-functional/>
ドメイン空間ごとにとりうる値を型で宣言し、その振る舞いを純粋関数で記述しやすくできないか考え、デザインしています。

=head1 DETAILS

=head2 declare type

koteは、型を宣言するための構文を提供します。

    package My::Character;
    use kote CharacterName => Str & sub { /^[A-Z][a-z]+$/ };

左辺の型名はCamelCaseである必要があります。右辺の制約は、Type::Tinyはもちろんのこと、Type::Tinyになれる制約を指定できます。
koteを利用するとExporter::Tinyを継承し、宣言した型を、C<@EXPORT_OK>に自動追加します。
つまり、次のように型をインポートできます。

    package main;
    use My::Character qw(CharacterName);

    CharacterName->check('Alice'); # true

=head2 create value

koteで宣言した型は、C<create>メソッドを持ちます。

    my ($alice, $err) = Character->create({name => 'Alice', level => 1});
    croak $err if $err;

C<create>メソッドは、与えられた値が型を満たさない場合はエラーメッセージを返し、満たす場合はその値を返します。
ただし、値がリファレンスだった場合は、不変なリファレンスに変換して返します。

    $alice->{name} = 'Bob'; # Error
    $alice->{unknown}; # Error

また、エラーハンドリングを行わなかった場合、例外が発生します。

    my $alice = Character->create({name => 'Alice', level => 1});
    # => Must handle error!!

=head1 TIPS

=head2 export functions

関数のエクスポートが、C<@EXPORT_OK>に関数を追加すればできます。

    pakcage My::Character;

    our @EXPORT_OK;
    push @EXPORT_OK, qw(is_alice);

    use kote CharacterName => Str & sub { /^[A-Z][a-z]+$/ };

    sub is_alice($name) {
        # CharacterName->assert_valid($name);
        $name eq 'Alice';
    }

    package main;
    use My::Character qw(CharacterName is_alice);

=head2 skip check value

パフォーマンスの都合、値の検証や不変なリファレンスへの変換をスキップしたい場合、C<$kote::STRICT>を0に設定します。
ただし、検証すべき値をスキップしないように十分注意してください。

    local $kote::STRICT = 0;
    my ($alice, $err) = CharacterName->create(1234);
    $err; # No Error

=head1 THANKS

L<Type::Tiny>の作者、Toby Inkster氏に感謝します。

=head1 LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kobaken E<lt>kentafly88@gmail.comE<gt>

=cut

