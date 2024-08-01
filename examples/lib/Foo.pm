package Foo;
use strict;
use warnings;

our @EXPORT_OK;
push @EXPORT_OK, qw(toCharacterName);

use Types::Standard qw(Str Int Dict);

use kote UnvalidatedCharacterName => Str;
use kote CharacterName => Str & sub { /^[A-Z][a-z]+$/ };

use kote MonsterName => Str & sub { /^[A-Z][a-z]+$/ };

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
