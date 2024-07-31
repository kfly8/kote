use Test2::V0;

use Types::Standard qw(Str Int Dict);

use caseval CharacterName => Str & sub { /^[A-Z][a-z]+$/ };
use caseval MonsterName => Str & sub { /^[A-Z][a-z]+$/ };
use caseval CharacterLevel => Int & sub { $_ >= 1 && $_ <= 100 };

use caseval Character => Dict[
    name => CharacterName,
    level => CharacterLevel,
];

subtest 'name' => sub {
    is +CharacterName->name, 'CharacterName';
};

subtest 'create' => sub {
    subtest 'Must handle error' => sub {
        ok dies { CharacterName->create('Alice') }, 'not in list context';
        ok dies {
            my $alice = CharacterName->create('Alice');
        }, 'not in list context';
    };

    subtest 'When type is string' => sub {
        my $err;

        (my $alice, $err) = CharacterName->create('Alice');
        is $err, undef, 'No error';
        is $alice, 'Alice';

        (my $bob, $err) = CharacterName->create('bob');
        is $bob, undef, 'invalid value';
        ok $err, 'Error';
    };

    subtest 'When type is number' => sub {
        my $err;

        (my $level, $err) = CharacterLevel->create(3);
        is $err, undef, 'No error';
        is $level, 3;

        (my $level2, $err) = CharacterLevel->create(0);
        is $level2, undef, 'invalid value';
        ok $err, 'Error';
    };

    subtest 'When type is dictionary' => sub {
        my $err;

        (my $alice, $err) = Character->create({name => 'Alice', level => 99});
        is $err, undef, 'No error';

        is $alice, {
            name => 'Alice',
            level => 99,
        };
        is $alice->{name}, 'Alice', 'access to field';
        ok dies { $alice->{name} = 'Bob' }, 'assign to readonly field';
        ok dies { $alice->{foo} }, 'access to unknown field';

        (my $bob, $err) = Character->create({name => 'bob', level => 0});
        is $bob, undef, 'invalid value';
        ok $err, 'Error';
    };
};

done_testing;
