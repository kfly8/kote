package Character;

use strict;
use warnings;

our @EXPORT_OK;
push @EXPORT_OK, qw(character_summary_message);

use Types::Standard qw(Str Int Dict);

use kote UnvalidatedCharacter => Dict[
    name => Str,
    level => Str,
];

use kote CharacterName => Str & sub { /^[A-Z][a-z]+$/ };
use kote CharacterLevel => Int & sub { $_ >= 1 && $_ <= 100 };

use kote Character => Dict[
    name => CharacterName,
    level => CharacterLevel,
];

sub character_summary_message {
    my ($character) = @_;
    # Character->assert_valid($character);
    return "Name: $character->{name}, Level: $character->{level}";
}

1;
