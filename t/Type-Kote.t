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
};

subtest 'into' => sub {
    my $List = CharacterName->into(ArrayRef);
    isa_ok $List, 'Type::Kote', 'Type::Tiny';
    is $List->display_name, 'ArrayRef[CharacterName]', 'display_name';

    my ($names, $err) = $List->create(['Alice', 'Bob']);
    ok !$err, 'No error';
    is $names, ['Alice', 'Bob'];

    ok dies {
        CharacterName->into(Str)
    }, 'not a parameterizable type';
};

subtest 'maybe' => sub {
    my $Maybe = CharacterName->maybe;
    isa_ok $Maybe, 'Type::Kote', 'Type::Tiny';
    is $Maybe->display_name, 'Maybe[CharacterName]', 'display_name';

    my ($name, $err) = $Maybe->create('Alice');
    ok !$err, 'No error';
    is $name, 'Alice';

    ($name, $err) = $Maybe->create(undef);
    ok !$err, 'No error';
    is $name, undef;

    ($name, $err) = $Maybe->create('bob');
    ok $err, 'Error';
    is $name, undef;
};

subtest 'optional' => sub {
    my $Optional = CharacterName->optional;
    isa_ok $Optional, 'Type::Kote', 'Type::Tiny';
    is $Optional->display_name, 'Optional[CharacterName]', 'display_name';

    my ($name, $err) = $Optional->create('Alice');
    ok !$err, 'No error';
    is $name, 'Alice';

    ($name, $err) = $Optional->create('bob');
    ok $err, 'Error';
    is $name, undef;

    my $Dict = Dict[name => $Optional];
    ok $Dict->check({name => 'Alice'}), 'valid';
    ok $Dict->check({}), 'name is optional';
    ok !$Dict->check({name => 'bob'}), 'invalid';
};

done_testing;
