use Test2::V0;
use Test2::Require::Module 'Devel::StrictMode';

package My::Character {
    use strict;
    use warnings;

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

    sub summary {
        my ($character) = @_;
        STRICT && Character->assert_valid($character);
        return "Name: $character->{name}, Level: $character->{level}";
    }
}

use My::Character qw(Character);

my $err;

(my $alice, $err) = Character->create({name => 'Alice', level => 99});
is $err, undef; # undef
is $alice->{name}, 'Alice';
is $alice->{level}, '99';
is My::Character::summary($alice), 'Name: Alice, Level: 99';

(my $bob, $err) = Character->create({name => 'bob', level => 0});
ok $err;
is $bob, undef;

done_testing;
