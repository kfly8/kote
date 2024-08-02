use Test2::V0;

use Types::Standard qw(Str Int Dict ArrayRef);

use kote CharacterName => Str & sub { /^[A-Z][a-z]+$/ };
use kote MonsterName => Str & sub { /^[A-Z][a-z]+$/ };
use kote CharacterLevel => Int & sub { $_ >= 1 && $_ <= 100 };

use kote Character => Dict[
    name => CharacterName,
    level => CharacterLevel,
];

use kote CharacterList => ArrayRef[Character];

subtest 'name' => sub {
    is +CharacterName->name, 'CharacterName';
};

subtest 'library' => sub {
    is +CharacterName->library, 'main';
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

    subtest 'When type is arrayref' => sub {
        my $err;

        (my $list, $err) = CharacterList->create([
            {name => 'Alice', level => 99},
            {name => 'Bob', level => 1},
        ]);
        is $err, undef, 'No error';

        is $list, [
            {
                name => 'Alice',
                level => 99,
            },
            {
                name => 'Bob',
                level => 1,
            },
        ];
        is $list->[0]{name}, 'Alice', 'access to field';
        ok dies { $list->[0]{name} = 'Bob' }, 'assign to readonly field';
        ok dies { $list->[0]{foo} }, 'access to unknown field';

        (my $list2, $err) = CharacterList->create([
            {name => 'Alice', level => 99},
            {name => 'Bob', level => 0},
        ]);
        is $list2, undef, 'invalid value';
        ok $err, 'Error';
    };

    subtest '$kote::STRICT' => sub {
        my $err;

        local $kote::STRICT = 0;
        (my $bob, $err) = Character->create({name => 'bob', level => 0});
        is $bob, { name => 'bob', level => 0 }, 'Invalid value but no error';
        ok !$err, 'No Error';

        ok lives { $bob->{name} = 'Bob' }, 'writable';
    };
};

done_testing;
