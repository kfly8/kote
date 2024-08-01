package Foo;
use strict;
use warnings;

our @EXPORT_OK;
push @EXPORT_OK, qw(toCharacterName);

use Types::Standard qw(Str Int Dict);

use caseval UnvalidatedCharacterName => Str;
use caseval CharacterName => Str & sub { /^[A-Z][a-z]+$/ };

use caseval MonsterName => Str & sub { /^[A-Z][a-z]+$/ };

sub run {
    my ($class, $name) = @_;
    my ($n, $e) = CharacterName->create($name);
    return ($n, $e);
}

sub toCharacterName {
    my ($name) = @_;
    UnvalidatedCharacterName->assert_valid($name);

    my ($n, $e) = CharacterName->create($name);
    return ($n, $e);
}

1;
